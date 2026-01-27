//
//  OpenAICompatibleLLMProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.1: LLM Service Integration
//  InvincibleVoice: JSON output with keywords + answers
//  Connects to Cerebras or other OpenAI-compatible LLM services.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// OpenAI-compatible LLM API client implementation.
/// Connects to Cerebras API (default) or other OpenAI-compatible endpoints
/// for generating response suggestions.
///
/// InvincibleVoice Integration:
/// - Returns JSON with `suggested_keywords` (10) and `suggested_answers` (4)
/// - Keywords are short words/phrases for quick responses
/// - Answers are full sentences for detailed responses
///
/// Note: Network availability should be checked by the caller before invoking
/// generateSuggestions(). Network errors during the request are properly mapped
/// to LLMError.networkUnavailable in error handling.
///
/// Usage:
/// ```swift
/// let provider = OpenAICompatibleLLMProvider()
/// let response = try await provider.generateSuggestionsWithKeywords(
///     prompt: "Comment ça va ?",
///     context: nil
/// )
/// // response.suggestedKeywords: ["Oui", "Non", "Bien", ...]
/// // response.suggestedAnswers: ["Très bien, merci !", "Ça va bien, et toi ?", ...]
/// ```
@MainActor
class OpenAICompatibleLLMProvider: ObservableObject, LLMProvider {

    // MARK: - Published Properties (internal state tracking)
    // Note: These properties are used internally for error state tracking.
    // UI display is handled by the calling service which catches errors.

    @Published private(set) var isLoading = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""

    // MARK: - Private Properties

    private let keychainKey = AppConfig.LLM.keychainKey
    private let endpointKeychainKey = "\(AppConfig.LLM.keychainKey)_endpoint"

    // MARK: - Guidance Properties (Story 4.2)

    /// Current guidance context for generating context-specific suggestions (AC2)
    var guidanceContext: GuidanceContext?

    /// Reference suggestion for "more like this" feature (AC3)
    var moreLikeThis: String?

    // MARK: - Initialization

    init() {
        // No initialization needed - network checks delegated to caller
    }

    // MARK: - Endpoint Configuration

    /// Returns the API endpoint to use - custom endpoint from Keychain if configured,
    /// otherwise falls back to AppConfig.LLM.apiEndpoint (Cerebras default).
    /// AC4: User can optionally change the endpoint URL.
    private func getAPIEndpoint() -> String {
        if let data = try? KeychainManager.load(key: endpointKeychainKey),
           let customEndpoint = String(data: data, encoding: .utf8),
           !customEndpoint.isEmpty {
            print("OpenAICompatibleLLMProvider: Using custom endpoint: \(customEndpoint)")
            return customEndpoint
        }
        return AppConfig.LLM.apiEndpoint
    }

    // MARK: - LLMProvider Protocol

    /// Generates response suggestions from the LLM.
    /// AC1: Connects via HTTPS using OpenAI-compatible format with API key from Keychain.
    func generateSuggestions(prompt: String, context: [String]?) async throws -> [String] {
        isLoading = true
        showError = false

        do {
            // AC1: Get API key from Keychain
            let apiKey = try getAPIKey()

            // Build OpenAI-compatible request with JSON format
            let request = try buildRequest(prompt: prompt, context: context, apiKey: apiKey, useJsonFormat: true)

            // Perform request and parse JSON response
            let response = try await performRequestWithKeywords(request: request)

            isLoading = false
            // Return only answers for backward compatibility
            return response.suggestedAnswers
        } catch {
            handleError(error)
            throw error
        }
    }

    // MARK: - InvincibleVoice: Keywords + Answers

    /// Generates response suggestions with keywords from the LLM.
    /// Returns both quick keywords (10) and full answer suggestions (4).
    ///
    /// - Parameters:
    ///   - prompt: The text to generate suggestions for
    ///   - context: Optional conversation history
    /// - Returns: SuggestionResponse with keywords and answers
    func generateSuggestionsWithKeywords(prompt: String, context: [String]?) async throws -> SuggestionResponse {
        isLoading = true
        showError = false

        do {
            let apiKey = try getAPIKey()
            let request = try buildRequest(prompt: prompt, context: context, apiKey: apiKey, useJsonFormat: true)
            let response = try await performRequestWithKeywords(request: request)

            isLoading = false
            return response
        } catch {
            handleError(error)
            throw error
        }
    }

    // MARK: - Private Methods

    /// Retrieves the LLM API key from Keychain.
    /// AC1: API key is retrieved securely from Keychain.
    /// AC2: Throws invalidApiKey if not found.
    private func getAPIKey() throws -> String {
        do {
            let data = try KeychainManager.load(key: keychainKey)
            guard let apiKey = String(data: data, encoding: .utf8), !apiKey.isEmpty else {
                throw LLMError.invalidApiKey
            }
            return apiKey
        } catch KeychainManager.KeychainError.unknown {
            throw LLMError.invalidApiKey
        } catch {
            throw LLMError.invalidApiKey
        }
    }

    /// Builds an OpenAI-compatible chat completion request.
    /// AC1: Uses OpenAI-compatible API format.
    /// AC4: Uses custom endpoint if configured, otherwise default Cerebras endpoint.
    /// InvincibleVoice: Supports JSON format for keywords + answers output.
    private func buildRequest(prompt: String, context: [String]?, apiKey: String, useJsonFormat: Bool = false) throws -> URLRequest {
        let endpoint = getAPIEndpoint()
        guard let url = URL(string: endpoint) else {
            throw LLMError.apiError(statusCode: 0, message: "URL invalide: \(endpoint)")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = AppConfig.LLM.timeout

        // Build messages array following OpenAI chat completion format
        var messages: [[String: String]] = [
            ["role": "system", "content": buildSystemPrompt(useJsonFormat: useJsonFormat)]
        ]

        // Add conversation context if available
        if let context = context {
            for (index, message) in context.enumerated() {
                let role = index % 2 == 0 ? "user" : "assistant"
                messages.append(["role": role, "content": message])
            }
        }

        // Add current prompt
        messages.append(["role": "user", "content": buildUserPrompt(prompt, useJsonFormat: useJsonFormat)])

        var body: [String: Any] = [
            "model": AppConfig.LLM.defaultModel,
            "messages": messages,
            "temperature": AppConfig.LLM.temperature,
            "max_completion_tokens": AppConfig.LLM.maxTokens
        ]

        // InvincibleVoice: Request JSON output format if supported by API
        if useJsonFormat {
            body["response_format"] = ["type": "json_object"]
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw LLMError.apiError(statusCode: 0, message: "Erreur de sérialisation JSON")
        }

        return request
    }

    /// System prompt for the LLM to generate suggestions.
    /// Includes personalization settings (Story 4.1) and guidance context (Story 4.2).
    /// InvincibleVoice: Supports JSON format for keywords + answers.
    private func buildSystemPrompt(useJsonFormat: Bool = false) -> String {
        // Load user's personalization settings
        let config = PersonalizationConfig.loadFromUserDefaults()

        // Build base prompt
        var prompt: String
        if useJsonFormat {
            // InvincibleVoice JSON format: keywords + answers
            prompt = """
            Tu es un assistant d'aide à la communication pour une personne qui ne peut pas parler. \
            Tu génères des suggestions de réponses en français au format JSON. \
            IMPORTANT: Ta réponse DOIT être un objet JSON valide avec exactement cette structure: \
            {"suggested_keywords": [...], "suggested_answers": [...]}. \
            - suggested_keywords: exactement 10 mots-clés ou phrases très courtes (1-3 mots) pour des réponses rapides. \
            Inclus toujours des mots basiques variés: affirmatifs (Oui, D'accord, Bien sûr), \
            négatifs (Non, Pas vraiment, Je ne sais pas), neutres (Peut-être, On verra), \
            et quelques mots contextuels liés à la question. \
            - suggested_answers: exactement \(AppConfig.LLM.suggestionCount) phrases complètes et naturelles. \
            IMPORTANT: Pour les questions, propose des alternatives variées: \
            pour une question fermée (oui/non), inclus des réponses positives ET négatives; \
            pour une question ouverte, propose des réponses reflétant différents états ou opinions.
            """
        } else {
            prompt = """
            Tu es un assistant d'aide à la communication pour une personne qui ne peut pas parler. \
            Tu génères des suggestions de réponses courtes et naturelles en français. \
            Génère exactement \(AppConfig.LLM.suggestionCount) suggestions différentes, \
            une par ligne, numérotées de 1 à \(AppConfig.LLM.suggestionCount). \
            IMPORTANT: Quand l'interlocuteur pose une question, propose des alternatives variées: \
            pour une question fermée (oui/non, ça va?), inclus des réponses positives ET négatives; \
            pour une question ouverte, propose des réponses reflétant différents états ou opinions. \
            Par exemple, pour "Comment ça va?", propose à la fois des réponses positives ("Très bien, merci!") \
            et des réponses plus nuancées ou négatives ("Pas terrible aujourd'hui", "Ça pourrait aller mieux").
            """
        }

        // Add tone instruction (Story 4.1)
        prompt += " \(config.tone.promptInstruction)"

        // Add response length instruction (Story 4.1)
        prompt += " \(config.responseLength.promptInstruction)"

        // Add personal context if provided (Story 4.1)
        let trimmedContext = config.personalContext.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedContext.isEmpty {
            prompt += " Contexte personnel de l'utilisateur: \(trimmedContext)"
        }

        // Add guidance context (Story 4.2 - AC2)
        if let guidance = guidanceContext {
            prompt += " \(guidance.promptInstruction)"
        }

        // Add "more like this" instruction (Story 4.2 - AC3)
        if let reference = moreLikeThis {
            prompt += " Génère des variations similaires à: \"\(reference)\""
        }

        return prompt
    }

    /// User prompt requesting suggestions.
    /// InvincibleVoice: Supports JSON format for keywords + answers.
    private func buildUserPrompt(_ prompt: String, useJsonFormat: Bool = false) -> String {
        if useJsonFormat {
            return "Génère des suggestions de réponses au format JSON pour: \(prompt)"
        }
        return "Génère \(AppConfig.LLM.suggestionCount) suggestions de réponses pour: \(prompt)"
    }

    /// Performs the HTTP request and parses the response.
    private func performRequest(request: URLRequest) async throws -> [String] {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.apiError(statusCode: 0, message: "Réponse invalide")
        }

        // Handle HTTP errors - AC3: Map to appropriate LLMError
        try validateHTTPResponse(httpResponse)

        // Parse JSON response to extract suggestions
        return try parseResponse(data)
    }

    /// InvincibleVoice: Performs HTTP request and parses JSON response with keywords.
    /// Returns a SuggestionResponse with keywords and answers.
    private func performRequestWithKeywords(request: URLRequest) async throws -> SuggestionResponse {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.apiError(statusCode: 0, message: "Réponse invalide")
        }

        try validateHTTPResponse(httpResponse)

        return try parseJsonResponse(data)
    }

    /// InvincibleVoice: Parses JSON response to extract keywords and answers.
    /// Handles both strict JSON and markdown-wrapped JSON formats.
    private func parseJsonResponse(_ data: Data) throws -> SuggestionResponse {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.invalidResponse
        }

        // Try to parse as JSON directly
        if let jsonData = content.data(using: .utf8) {
            // First try direct JSON parsing
            if let response = try? JSONDecoder().decode(SuggestionResponse.self, from: jsonData) {
                return validateAndCleanResponse(response)
            }

            // Try extracting JSON from markdown code block
            let jsonPattern = "```(?:json)?\\s*\\n?([\\s\\S]*?)\\n?```"
            if let regex = try? NSRegularExpression(pattern: jsonPattern, options: []),
               let match = regex.firstMatch(in: content, options: [], range: NSRange(content.startIndex..., in: content)),
               let jsonRange = Range(match.range(at: 1), in: content) {
                let jsonString = String(content[jsonRange])
                if let extractedData = jsonString.data(using: .utf8),
                   let response = try? JSONDecoder().decode(SuggestionResponse.self, from: extractedData) {
                    return validateAndCleanResponse(response)
                }
            }
        }

        // Fallback: Parse numbered list format and return as answers with default keywords
        print("OpenAICompatibleLLMProvider: JSON parsing failed, falling back to numbered list parsing")
        let suggestions = try parseResponse(data)
        // F2 Fix: Use centralized default keywords
        return SuggestionResponse(
            suggestedKeywords: SuggestionResponse.defaultKeywords,
            suggestedAnswers: suggestions
        )
    }

    /// Validates and cleans the suggestion response.
    /// Ensures keywords and answers are not empty and removes duplicates.
    private func validateAndCleanResponse(_ response: SuggestionResponse) -> SuggestionResponse {
        let cleanedKeywords = response.suggestedKeywords
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()

        let cleanedAnswers = response.suggestedAnswers
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()

        // F2 Fix: Provide default keywords if empty (use centralized constant)
        let finalKeywords = cleanedKeywords.isEmpty
            ? SuggestionResponse.defaultKeywords
            : cleanedKeywords

        return SuggestionResponse(
            suggestedKeywords: finalKeywords,
            suggestedAnswers: cleanedAnswers
        )
    }

    /// Validates the HTTP response status code.
    /// Maps HTTP errors to appropriate LLMError cases.
    private func validateHTTPResponse(_ response: HTTPURLResponse) throws {
        guard (200...299).contains(response.statusCode) else {
            switch response.statusCode {
            case 401:
                throw LLMError.invalidApiKey
            case 429:
                throw LLMError.rateLimited
            case 408:
                throw LLMError.timeout
            default:
                throw LLMError.apiError(
                    statusCode: response.statusCode,
                    message: HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                )
            }
        }
    }

    /// Parses the OpenAI-compatible JSON response to extract suggestions.
    private func parseResponse(_ data: Data) throws -> [String] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.invalidResponse
        }

        // Parse numbered suggestions from content
        // Format expected: "1. Suggestion one\n2. Suggestion two\n..."
        let suggestions = content
            .components(separatedBy: "\n")
            .map { line in
                // Remove numbering prefix (1., 2., etc.)
                line.replacingOccurrences(
                    of: "^\\d+\\.\\s*",
                    with: "",
                    options: .regularExpression
                ).trimmingCharacters(in: .whitespaces)
            }
            .filter { !$0.isEmpty }

        guard !suggestions.isEmpty else {
            throw LLMError.invalidResponse
        }

        return suggestions
    }

    /// Story 2.3 pattern: Handle errors with French messages AND recovery suggestions.
    /// AC3: User-friendly error message is displayed in French.
    @MainActor
    private func handleError(_ error: Error) {
        let llmError: LLMError

        if let existing = error as? LLMError {
            llmError = existing
        } else if (error as NSError).code == NSURLErrorTimedOut {
            llmError = .timeout
        } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            llmError = .networkUnavailable
        } else {
            llmError = .apiError(statusCode: 0, message: error.localizedDescription)
        }

        // AC3: Include both error description AND recovery suggestion
        if let suggestion = llmError.recoverySuggestion {
            errorMessage = "\(llmError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = llmError.localizedDescription
        }

        showError = true
        isLoading = false

        // Never silent - always log for debugging
        print("OpenAICompatibleLLMProvider Error: \(llmError.failureReason ?? "unknown") - \(errorMessage)")
    }
}

// MARK: - Array Extension for Removing Duplicates

private extension Array where Element == String {
    /// Removes duplicate strings while preserving order.
    func removingDuplicates() -> [String] {
        var seen = Set<String>()
        return filter { seen.insert($0).inserted }
    }
}
