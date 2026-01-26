//
//  OpenAICompatibleLLMProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.1: LLM Service Integration
//  Connects to Cerebras or other OpenAI-compatible LLM services.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// OpenAI-compatible LLM API client implementation.
/// Connects to Cerebras API (default) or other OpenAI-compatible endpoints
/// for generating response suggestions.
///
/// Note: Network availability should be checked by the caller before invoking
/// generateSuggestions(). Network errors during the request are properly mapped
/// to LLMError.networkUnavailable in error handling.
///
/// Usage:
/// ```swift
/// let provider = OpenAICompatibleLLMProvider()
/// let suggestions = try await provider.generateSuggestions(
///     prompt: "Comment ça va ?",
///     context: nil
/// )
/// // suggestions: ["Très bien, merci !", "Ça va bien, et toi ?", ...]
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

            // Build OpenAI-compatible request
            let request = try buildRequest(prompt: prompt, context: context, apiKey: apiKey)

            // Perform request and parse response
            let suggestions = try await performRequest(request: request)

            isLoading = false
            return suggestions
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
    private func buildRequest(prompt: String, context: [String]?, apiKey: String) throws -> URLRequest {
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
            ["role": "system", "content": buildSystemPrompt()]
        ]

        // Add conversation context if available
        if let context = context {
            for (index, message) in context.enumerated() {
                let role = index % 2 == 0 ? "user" : "assistant"
                messages.append(["role": role, "content": message])
            }
        }

        // Add current prompt
        messages.append(["role": "user", "content": buildUserPrompt(prompt)])

        let body: [String: Any] = [
            "model": AppConfig.LLM.defaultModel,
            "messages": messages,
            "temperature": AppConfig.LLM.temperature,
            "max_completion_tokens": AppConfig.LLM.maxTokens
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw LLMError.apiError(statusCode: 0, message: "Erreur de sérialisation JSON")
        }

        return request
    }

    /// System prompt for the LLM to generate suggestions.
    /// Now includes personalization settings (Story 4.1, AC5).
    private func buildSystemPrompt() -> String {
        // Load user's personalization settings
        let config = PersonalizationConfig.loadFromUserDefaults()

        // Build base prompt
        var prompt = """
        Tu es un assistant d'aide à la communication pour une personne qui ne peut pas parler. \
        Tu génères des suggestions de réponses courtes et naturelles en français. \
        Génère exactement \(AppConfig.LLM.suggestionCount) suggestions différentes, \
        une par ligne, numérotées de 1 à \(AppConfig.LLM.suggestionCount).
        """

        // Add tone instruction (Story 4.1)
        prompt += " \(config.tone.promptInstruction)"

        // Add response length instruction (Story 4.1)
        prompt += " \(config.responseLength.promptInstruction)"

        // Add personal context if provided (Story 4.1)
        let trimmedContext = config.personalContext.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedContext.isEmpty {
            prompt += " Contexte personnel de l'utilisateur: \(trimmedContext)"
        }

        return prompt
    }

    /// User prompt requesting suggestions.
    private func buildUserPrompt(_ prompt: String) -> String {
        "Génère \(AppConfig.LLM.suggestionCount) suggestions de réponses pour: \(prompt)"
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
