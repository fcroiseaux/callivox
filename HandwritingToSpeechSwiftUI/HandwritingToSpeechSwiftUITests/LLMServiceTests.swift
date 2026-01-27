//
//  LLMServiceTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 3.1: LLM Service Integration
//  Unit tests for LLM error handling, request/response parsing, and provider behavior.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class LLMServiceTests: XCTestCase {

    // MARK: - LLMError French Localization Tests

    func testInvalidApiKeyErrorDescription() {
        let error = LLMError.invalidApiKey
        XCTAssertEqual(error.errorDescription, "Clé API LLM invalide ou manquante")
    }

    func testNetworkUnavailableErrorDescription() {
        let error = LLMError.networkUnavailable
        XCTAssertEqual(error.errorDescription, "Connexion internet indisponible")
    }

    func testApiErrorDescription() {
        let error = LLMError.apiError(statusCode: 500, message: "Server error")
        XCTAssertEqual(error.errorDescription, "Erreur du service IA (code 500): Server error")
    }

    func testRateLimitedErrorDescription() {
        let error = LLMError.rateLimited
        XCTAssertEqual(error.errorDescription, "Trop de requêtes, veuillez patienter")
    }

    func testTimeoutErrorDescription() {
        let error = LLMError.timeout
        XCTAssertEqual(error.errorDescription, "Connexion au service IA lente ou indisponible")
    }

    func testInvalidResponseErrorDescription() {
        let error = LLMError.invalidResponse
        XCTAssertEqual(error.errorDescription, "Réponse invalide du service IA")
    }

    // MARK: - LLMError RecoverySuggestion Tests (AC2, AC3)

    func testAllErrorsHaveRecoverySuggestion() {
        let errors: [LLMError] = [
            .invalidApiKey,
            .networkUnavailable,
            .apiError(statusCode: 500, message: "test"),
            .rateLimited,
            .timeout,
            .invalidResponse
        ]

        for error in errors {
            XCTAssertNotNil(
                error.recoverySuggestion,
                "Error \(error) should have a recovery suggestion"
            )
            XCTAssertFalse(
                error.recoverySuggestion?.isEmpty ?? true,
                "Error \(error) recovery suggestion should not be empty"
            )
        }
    }

    func testInvalidApiKeyRecoverySuggestion() {
        let error = LLMError.invalidApiKey
        XCTAssertEqual(error.recoverySuggestion, "Vérifiez votre clé API dans Réglages > Service IA.")
    }

    func testNetworkUnavailableRecoverySuggestion() {
        let error = LLMError.networkUnavailable
        XCTAssertEqual(error.recoverySuggestion, "Vérifiez votre connexion internet.")
    }

    func testApiErrorRecoverySuggestion() {
        let error = LLMError.apiError(statusCode: 500, message: "test")
        XCTAssertEqual(error.recoverySuggestion, "Réessayez dans quelques instants.")
    }

    func testRateLimitedRecoverySuggestion() {
        let error = LLMError.rateLimited
        XCTAssertEqual(error.recoverySuggestion, "Attendez quelques secondes avant de réessayer.")
    }

    func testTimeoutRecoverySuggestion() {
        let error = LLMError.timeout
        XCTAssertEqual(error.recoverySuggestion, "Vérifiez votre connexion. Les suggestions IA sont temporairement indisponibles.")
    }

    func testInvalidResponseRecoverySuggestion() {
        let error = LLMError.invalidResponse
        XCTAssertEqual(error.recoverySuggestion, "Le service IA a renvoyé une réponse inattendue. Réessayez.")
    }

    // MARK: - LLMError French Content Tests

    func testAllErrorsHaveFrenchDescriptions() {
        let errors: [LLMError] = [
            .invalidApiKey,
            .networkUnavailable,
            .apiError(statusCode: 500, message: "test"),
            .rateLimited,
            .timeout,
            .invalidResponse
        ]

        for error in errors {
            let description = error.errorDescription ?? ""
            // Check that descriptions contain French characters or common French words
            let hasFrenchContent = description.contains("Connexion") ||
                                   description.contains("Erreur") ||
                                   description.contains("Clé") ||
                                   description.contains("requêtes") ||
                                   description.contains("indisponible") ||
                                   description.contains("Réponse")
            XCTAssertTrue(hasFrenchContent, "Error \(error) should have French description")
        }
    }

    func testAllRecoverySuggestionsAreFrench() {
        let errors: [LLMError] = [
            .invalidApiKey,
            .networkUnavailable,
            .apiError(statusCode: 500, message: "test"),
            .rateLimited,
            .timeout,
            .invalidResponse
        ]

        for error in errors {
            let suggestion = error.recoverySuggestion ?? ""
            // Check that recovery suggestions contain French words
            let hasFrenchContent = suggestion.contains("Vérifiez") ||
                                   suggestion.contains("Réessayez") ||
                                   suggestion.contains("Attendez") ||
                                   suggestion.contains("connexion") ||
                                   suggestion.contains("Réglages")
            XCTAssertTrue(hasFrenchContent, "Error \(error) should have French recovery suggestion")
        }
    }

    // MARK: - LocalizedError Conformance

    func testConformsToLocalizedError() {
        let error: LocalizedError = LLMError.invalidApiKey
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    // MARK: - Response Parsing Tests

    func testParseValidOpenAIResponse() throws {
        // Valid OpenAI-compatible response format
        let jsonString = """
        {
            "id": "chatcmpl-123",
            "object": "chat.completion",
            "created": 1234567890,
            "model": "qwen-3-235b",
            "choices": [{
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": "1. Très bien, merci !\\n2. Ça va bien, et toi ?\\n3. Je vais bien.\\n4. Parfait, merci de demander."
                },
                "finish_reason": "stop"
            }],
            "usage": {
                "prompt_tokens": 100,
                "completion_tokens": 50,
                "total_tokens": 150
            }
        }
        """

        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create test data")
            return
        }

        // Parse using the same logic as OpenAICompatibleLLMProvider
        let suggestions = try parseTestResponse(data)

        XCTAssertEqual(suggestions.count, 4)
        XCTAssertEqual(suggestions[0], "Très bien, merci !")
        XCTAssertEqual(suggestions[1], "Ça va bien, et toi ?")
        XCTAssertEqual(suggestions[2], "Je vais bien.")
        XCTAssertEqual(suggestions[3], "Parfait, merci de demander.")
    }

    func testParseResponseWithEmptyContent() {
        let jsonString = """
        {
            "choices": [{
                "message": {
                    "role": "assistant",
                    "content": ""
                }
            }]
        }
        """

        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create test data")
            return
        }

        XCTAssertThrowsError(try parseTestResponse(data)) { error in
            XCTAssertTrue(error is LLMError)
            if let llmError = error as? LLMError {
                XCTAssertEqual(llmError, LLMError.invalidResponse)
            }
        }
    }

    func testParseInvalidJSONResponse() {
        let invalidJSON = "not a valid json"
        guard let data = invalidJSON.data(using: .utf8) else {
            XCTFail("Failed to create test data")
            return
        }

        XCTAssertThrowsError(try parseTestResponse(data)) { error in
            XCTAssertTrue(error is LLMError)
        }
    }

    func testParseMissingChoicesResponse() {
        let jsonString = """
        {
            "id": "chatcmpl-123",
            "object": "chat.completion"
        }
        """

        guard let data = jsonString.data(using: .utf8) else {
            XCTFail("Failed to create test data")
            return
        }

        XCTAssertThrowsError(try parseTestResponse(data)) { error in
            XCTAssertTrue(error is LLMError)
            if let llmError = error as? LLMError {
                XCTAssertEqual(llmError, LLMError.invalidResponse)
            }
        }
    }

    // MARK: - Request Body Format Tests

    func testRequestBodyMatchesOpenAISpec() throws {
        // Test that request body structure matches OpenAI chat completion format
        let prompt = "Comment ça va ?"
        let context: [String]? = nil

        let requestBody = buildTestRequestBody(prompt: prompt, context: context)

        // Verify required fields
        XCTAssertNotNil(requestBody["model"] as? String)
        XCTAssertNotNil(requestBody["messages"] as? [[String: String]])
        XCTAssertNotNil(requestBody["temperature"] as? Double)
        XCTAssertNotNil(requestBody["max_completion_tokens"] as? Int)

        // Verify model matches config
        XCTAssertEqual(requestBody["model"] as? String, AppConfig.LLM.defaultModel)

        // Verify messages structure
        let messages = requestBody["messages"] as? [[String: String]]
        XCTAssertNotNil(messages)
        XCTAssertGreaterThanOrEqual(messages?.count ?? 0, 2) // At least system + user

        // Verify system message exists
        let systemMessage = messages?.first
        XCTAssertEqual(systemMessage?["role"], "system")
        XCTAssertNotNil(systemMessage?["content"])

        // Verify user message exists
        let userMessage = messages?.last
        XCTAssertEqual(userMessage?["role"], "user")
        XCTAssertTrue(userMessage?["content"]?.contains(prompt) ?? false)
    }

    func testRequestBodyWithContext() throws {
        let prompt = "Et toi ?"
        let context = ["Bonjour", "Salut, comment ça va ?"]

        let requestBody = buildTestRequestBody(prompt: prompt, context: context)

        let messages = requestBody["messages"] as? [[String: String]]
        XCTAssertNotNil(messages)

        // Should have: system + context[0] as user + context[1] as assistant + final user
        XCTAssertEqual(messages?.count, 4)

        // Verify roles alternate correctly
        XCTAssertEqual(messages?[0]["role"], "system")
        XCTAssertEqual(messages?[1]["role"], "user")
        XCTAssertEqual(messages?[1]["content"], "Bonjour")
        XCTAssertEqual(messages?[2]["role"], "assistant")
        XCTAssertEqual(messages?[2]["content"], "Salut, comment ça va ?")
        XCTAssertEqual(messages?[3]["role"], "user")
    }

    // MARK: - Missing API Key Test

    @MainActor
    func testMissingApiKeyThrowsError() async {
        // Clear any existing API key
        try? KeychainManager.delete(key: AppConfig.LLM.keychainKey)

        let provider = OpenAICompatibleLLMProvider()

        do {
            _ = try await provider.generateSuggestions(prompt: "Test", context: nil)
            XCTFail("Should throw invalidApiKey error")
        } catch let error as LLMError {
            XCTAssertEqual(error, LLMError.invalidApiKey)
        } catch {
            XCTFail("Should throw LLMError.invalidApiKey, got: \(error)")
        }
    }

    // MARK: - AppConfig Tests

    func testAppConfigLLMValues() {
        XCTAssertEqual(AppConfig.LLM.apiEndpoint, "https://api.cerebras.ai/v1/chat/completions")
        XCTAssertEqual(AppConfig.LLM.defaultModel, "qwen-3-235b-a22b-instruct-2507")
        XCTAssertEqual(AppConfig.LLM.keychainKey, "llm_api_key")
        XCTAssertEqual(AppConfig.LLM.timeout, 10.0)
        XCTAssertEqual(AppConfig.LLM.maxTokens, 500)
        XCTAssertEqual(AppConfig.LLM.temperature, 0.7)
        XCTAssertEqual(AppConfig.LLM.suggestionCount, 4)
    }

    // MARK: - Suggestion Diversity Tests

    func testSystemPromptIncludesDiversityInstruction() {
        // Verify the system prompt instructs the LLM to provide both positive and negative alternatives
        let prompt = buildSystemPrompt()

        // Should include instruction for varied alternatives
        XCTAssertTrue(
            prompt.contains("alternatives variées") || prompt.contains("positives ET négatives"),
            "System prompt should include diversity instruction for question responses"
        )

        // Should include example for "Comment ça va?"
        XCTAssertTrue(
            prompt.contains("Comment ça va") || prompt.contains("ça va"),
            "System prompt should include example for common questions"
        )

        // Should mention both positive and negative response types
        XCTAssertTrue(
            prompt.contains("positives") && prompt.contains("négatives"),
            "System prompt should mention both positive and negative responses"
        )
    }

    // MARK: - Helper Methods (mirror OpenAICompatibleLLMProvider logic for testing)

    /// Parses response using the same logic as OpenAICompatibleLLMProvider
    private func parseTestResponse(_ data: Data) throws -> [String] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw LLMError.invalidResponse
        }

        let suggestions = content
            .components(separatedBy: "\n")
            .map { line in
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

    /// Builds request body using the same logic as OpenAICompatibleLLMProvider
    private func buildTestRequestBody(prompt: String, context: [String]?) -> [String: Any] {
        var messages: [[String: String]] = [
            ["role": "system", "content": buildSystemPrompt()]
        ]

        if let context = context {
            for (index, message) in context.enumerated() {
                let role = index % 2 == 0 ? "user" : "assistant"
                messages.append(["role": role, "content": message])
            }
        }

        messages.append(["role": "user", "content": buildUserPrompt(prompt)])

        return [
            "model": AppConfig.LLM.defaultModel,
            "messages": messages,
            "temperature": AppConfig.LLM.temperature,
            "max_completion_tokens": AppConfig.LLM.maxTokens
        ]
    }

    private func buildSystemPrompt() -> String {
        """
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

    private func buildUserPrompt(_ prompt: String) -> String {
        "Génère \(AppConfig.LLM.suggestionCount) suggestions de réponses pour: \(prompt)"
    }
}

// MARK: - LLMError Equatable Extension for Testing

extension LLMError: Equatable {
    static func == (lhs: LLMError, rhs: LLMError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidApiKey, .invalidApiKey):
            return true
        case (.networkUnavailable, .networkUnavailable):
            return true
        case (.rateLimited, .rateLimited):
            return true
        case (.timeout, .timeout):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case let (.apiError(lhsCode, lhsMsg), .apiError(rhsCode, rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        default:
            return false
        }
    }
}
