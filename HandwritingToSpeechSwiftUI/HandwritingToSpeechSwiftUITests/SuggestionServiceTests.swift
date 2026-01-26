//
//  SuggestionServiceTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 3.2: Multi-Suggestion Generation
//  Unit tests for SuggestionService suggestion generation and history management.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

// MARK: - Mock LLM Provider for Testing

/// Mock LLM provider that returns configurable suggestions or errors.
/// Used to test SuggestionService without actual network calls.
@MainActor
class MockLLMProvider: LLMProvider {
    var suggestionsToReturn: [String] = [
        "Très bien, merci !",
        "Ça va bien, et toi ?",
        "Je vais bien.",
        "Parfait, merci de demander."
    ]
    var errorToThrow: LLMError?
    var lastPrompt: String?
    var lastContext: [String]?
    var generateCallCount = 0

    func generateSuggestions(prompt: String, context: [String]?) async throws -> [String] {
        generateCallCount += 1
        lastPrompt = prompt
        lastContext = context

        if let error = errorToThrow {
            throw error
        }
        return suggestionsToReturn
    }
}

// MARK: - SuggestionService Tests

@MainActor
final class SuggestionServiceTests: XCTestCase {

    var mockProvider: MockLLMProvider!
    var service: SuggestionService!

    override func setUp() async throws {
        mockProvider = MockLLMProvider()
        service = SuggestionService(llmProvider: mockProvider)
    }

    override func tearDown() async throws {
        mockProvider = nil
        service = nil
    }

    // MARK: - AC1: Suggestion Generation Tests

    func testGenerateSuggestions_ReturnsExpectedSuggestions() async {
        // Given
        let prompt = "Comment ça va ?"

        // When
        await service.generateSuggestions(for: prompt)

        // Then
        XCTAssertEqual(service.suggestions.count, 4)
        XCTAssertEqual(service.suggestions[0], "Très bien, merci !")
        XCTAssertEqual(service.suggestions[1], "Ça va bien, et toi ?")
        XCTAssertFalse(service.isLoading)
        XCTAssertFalse(service.showError)
    }

    func testGenerateSuggestions_LimitsToFiveSuggestions() async {
        // Given - provider returns more than 5
        mockProvider.suggestionsToReturn = [
            "One", "Two", "Three", "Four", "Five", "Six", "Seven"
        ]

        // When
        await service.generateSuggestions(for: "Test")

        // Then - should be limited to 5 (AC1)
        XCTAssertEqual(service.suggestions.count, 5)
        XCTAssertEqual(service.suggestions[4], "Five")
    }

    func testGenerateSuggestions_PassesPromptToProvider() async {
        // Given
        let prompt = "Bonjour, comment vas-tu ?"

        // When
        await service.generateSuggestions(for: prompt)

        // Then
        XCTAssertEqual(mockProvider.lastPrompt, prompt)
        XCTAssertEqual(mockProvider.generateCallCount, 1)
    }

    // MARK: - AC2: Loading State Tests

    func testGenerateSuggestions_SetsLoadingStateCorrectly() async {
        // Given
        XCTAssertFalse(service.isLoading)

        // When
        await service.generateSuggestions(for: "Test")

        // Then - isLoading should be false after completion
        XCTAssertFalse(service.isLoading)
    }

    func testGenerateSuggestions_ClearsPreviousSuggestions() async {
        // Given - first generation
        await service.generateSuggestions(for: "First")
        XCTAssertEqual(service.suggestions.count, 4)

        // When - second generation with different suggestions
        mockProvider.suggestionsToReturn = ["New one", "New two"]
        await service.generateSuggestions(for: "Second")

        // Then - previous suggestions replaced
        XCTAssertEqual(service.suggestions.count, 2)
        XCTAssertEqual(service.suggestions[0], "New one")
    }

    // MARK: - AC3: Conversation History Tests

    func testAddToHistory_AddsUserMessage() async {
        // When
        service.addToHistory(userMessage: "Bonjour")

        // Then
        XCTAssertEqual(service.historyCount, 1)
    }

    func testAddToHistory_AddsUserAndAIMessages() async {
        // When
        service.addToHistory(userMessage: "Bonjour", aiResponse: "Salut !")

        // Then - both messages added
        XCTAssertEqual(service.historyCount, 2)
    }

    func testAddToHistory_LimitsToSixExchanges() async {
        // Given - add 7 exchanges (14 messages)
        for i in 1...7 {
            service.addToHistory(userMessage: "User \(i)", aiResponse: "AI \(i)")
        }

        // Then - limited to 6 exchanges (12 messages)
        XCTAssertEqual(service.historyCount, 12)
    }

    func testGenerateSuggestions_UsesConversationHistory() async {
        // Given - add history
        service.addToHistory(userMessage: "Bonjour", aiResponse: "Salut !")
        service.addToHistory(userMessage: "Comment ça va ?")

        // When
        await service.generateSuggestions(for: "Test prompt")

        // Then - context passed to provider
        XCTAssertNotNil(mockProvider.lastContext)
        XCTAssertEqual(mockProvider.lastContext?.count, 3) // 2 from first exchange + 1 from second
        XCTAssertEqual(mockProvider.lastContext?[0], "Bonjour")
        XCTAssertEqual(mockProvider.lastContext?[1], "Salut !")
        XCTAssertEqual(mockProvider.lastContext?[2], "Comment ça va ?")
    }

    func testGenerateSuggestions_ExplicitContextOverridesHistory() async {
        // Given - add history
        service.addToHistory(userMessage: "Ignored", aiResponse: "Also ignored")

        // When - use explicit context
        let explicitContext = ["Custom context"]
        await service.generateSuggestions(for: "Test", context: explicitContext)

        // Then - explicit context used instead of history
        XCTAssertEqual(mockProvider.lastContext, explicitContext)
    }

    func testClearHistory_RemovesAllHistory() async {
        // Given
        service.addToHistory(userMessage: "One", aiResponse: "Two")
        service.addToHistory(userMessage: "Three")
        XCTAssertEqual(service.historyCount, 3)

        // When
        service.clearHistory()

        // Then
        XCTAssertEqual(service.historyCount, 0)
    }

    // MARK: - AC4: Error Handling Tests

    func testGenerateSuggestions_HandlesInvalidApiKeyError() async {
        // Given
        mockProvider.errorToThrow = .invalidApiKey

        // When
        await service.generateSuggestions(for: "Test")

        // Then
        XCTAssertTrue(service.showError)
        XCTAssertTrue(service.errorMessage.contains("Clé API LLM invalide ou manquante"))
        XCTAssertTrue(service.errorMessage.contains("Vérifiez votre clé API"))
        XCTAssertFalse(service.isLoading)
        XCTAssertTrue(service.suggestions.isEmpty)
    }

    func testGenerateSuggestions_HandlesNetworkUnavailableError() async {
        // Given
        mockProvider.errorToThrow = .networkUnavailable

        // When
        await service.generateSuggestions(for: "Test")

        // Then
        XCTAssertTrue(service.showError)
        XCTAssertTrue(service.errorMessage.contains("Connexion internet indisponible"))
        XCTAssertFalse(service.isLoading)
    }

    func testGenerateSuggestions_HandlesTimeoutError() async {
        // Given
        mockProvider.errorToThrow = .timeout

        // When
        await service.generateSuggestions(for: "Test")

        // Then
        XCTAssertTrue(service.showError)
        XCTAssertTrue(service.errorMessage.contains("service IA"))
        XCTAssertFalse(service.isLoading)
    }

    func testGenerateSuggestions_HandlesRateLimitedError() async {
        // Given
        mockProvider.errorToThrow = .rateLimited

        // When
        await service.generateSuggestions(for: "Test")

        // Then
        XCTAssertTrue(service.showError)
        XCTAssertTrue(service.errorMessage.contains("Trop de requêtes"))
        XCTAssertFalse(service.isLoading)
    }

    func testGenerateSuggestions_ErrorMessageIncludesRecoverySuggestion() async {
        // Given
        mockProvider.errorToThrow = .invalidApiKey

        // When
        await service.generateSuggestions(for: "Test")

        // Then - message should include both description and recovery
        XCTAssertTrue(service.errorMessage.contains("Clé API"))
        XCTAssertTrue(service.errorMessage.contains("Vérifiez"))
    }

    func testDismissError_ClearsErrorState() async {
        // Given
        mockProvider.errorToThrow = .invalidApiKey
        await service.generateSuggestions(for: "Test")
        XCTAssertTrue(service.showError)

        // When
        service.dismissError()

        // Then
        XCTAssertFalse(service.showError)
        XCTAssertTrue(service.errorMessage.isEmpty)
    }

    // MARK: - AC5: Empty Prompt Tests

    func testGenerateSuggestions_EmptyPromptClearsSuggestions() async {
        // Given - have existing suggestions
        await service.generateSuggestions(for: "First")
        XCTAssertFalse(service.suggestions.isEmpty)

        // When
        await service.generateSuggestions(for: "")

        // Then
        XCTAssertTrue(service.suggestions.isEmpty)
        XCTAssertEqual(mockProvider.generateCallCount, 1) // Only first call
    }

    func testGenerateSuggestions_PromptWithTextAndWhitespaceIsValid() async {
        // Given - prompt with actual content surrounded by whitespace
        let prompt = "  Hello  "

        // When
        await service.generateSuggestions(for: prompt)

        // Then - valid prompt with content, provider is called
        XCTAssertEqual(mockProvider.generateCallCount, 1)
        XCTAssertFalse(service.suggestions.isEmpty)
    }

    // MARK: - Clear Suggestions Tests

    func testClearSuggestions_RemovesAllSuggestions() async {
        // Given
        await service.generateSuggestions(for: "Test")
        XCTAssertFalse(service.suggestions.isEmpty)

        // When
        service.clearSuggestions()

        // Then
        XCTAssertTrue(service.suggestions.isEmpty)
    }

    // MARK: - Retry Tests (AC4: can retry after error)

    func testGenerateSuggestions_CanRetryAfterError() async {
        // Given - first call fails
        mockProvider.errorToThrow = .networkUnavailable
        await service.generateSuggestions(for: "Test")
        XCTAssertTrue(service.showError)
        XCTAssertTrue(service.suggestions.isEmpty)

        // When - retry succeeds
        mockProvider.errorToThrow = nil
        await service.generateSuggestions(for: "Test")

        // Then
        XCTAssertFalse(service.showError)
        XCTAssertFalse(service.suggestions.isEmpty)
        XCTAssertEqual(mockProvider.generateCallCount, 2)
    }

    // MARK: - Distinct Suggestions Tests (AC1)

    func testGenerateSuggestions_RemovesDuplicates() async {
        // Given - provider returns duplicates
        mockProvider.suggestionsToReturn = [
            "Same response",
            "Different response",
            "Same response",  // Duplicate
            "Another response"
        ]

        // When
        await service.generateSuggestions(for: "Test")

        // Then - duplicates removed (AC1: distinct suggestions)
        XCTAssertEqual(service.suggestions.count, 3)
        XCTAssertEqual(service.suggestions[0], "Same response")
        XCTAssertEqual(service.suggestions[1], "Different response")
        XCTAssertEqual(service.suggestions[2], "Another response")
    }

    func testGenerateSuggestions_WhitespaceOnlyPromptReturnsEmpty() async {
        // Given - whitespace-only prompt
        let whitespacePrompt = "   \t\n  "

        // When
        await service.generateSuggestions(for: whitespacePrompt)

        // Then - treated as empty, no API call
        XCTAssertTrue(service.suggestions.isEmpty)
        XCTAssertEqual(mockProvider.generateCallCount, 0)
    }
}
