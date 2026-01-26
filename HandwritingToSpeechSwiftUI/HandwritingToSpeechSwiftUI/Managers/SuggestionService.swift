//
//  SuggestionService.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.2: Multi-Suggestion Generation
//  Service for generating and managing AI response suggestions.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Service for generating AI-powered response suggestions.
/// Uses OpenAICompatibleLLMProvider to generate multiple suggestions
/// based on conversation context.
///
/// Usage:
/// ```swift
/// let service = SuggestionService.shared
/// await service.generateSuggestions(for: "Comment ça va ?")
/// // service.suggestions: ["Très bien, merci !", "Ça va bien, et toi ?", ...]
/// ```
@MainActor
class SuggestionService: ObservableObject {

    // MARK: - Singleton

    static let shared = SuggestionService()

    // MARK: - Published Properties

    /// Current list of generated suggestions (AC1: 3-5 distinct suggestions)
    @Published private(set) var suggestions: [String] = []

    /// Loading state for UI binding (AC2)
    @Published private(set) var isLoading = false

    /// Error display flag for UI binding (AC4)
    @Published private(set) var showError = false

    /// Error message for display (AC4: French messages)
    @Published private(set) var errorMessage = ""

    // MARK: - Guidance Properties (Story 4.2)

    /// Current guidance context for suggestions (AC1, AC2)
    @Published var currentGuidance: GuidanceContext?

    /// Last selected suggestion for "more like this" feature (AC3)
    @Published private(set) var lastSelectedSuggestion: String?

    // MARK: - Private Properties

    /// LLM provider for generating suggestions
    private let llmProvider: LLMProvider

    /// Conversation history for context-aware suggestions (AC3)
    private var conversationHistory: [String] = []

    /// Maximum number of exchanges to keep in history (6 exchanges = 12 messages)
    private let maxHistoryExchanges = 6

    /// Last prompt used for "different" feature (Story 4.2 - AC4)
    private var lastPrompt: String = ""

    // MARK: - Initialization

    /// Private initializer for singleton pattern
    private init() {
        self.llmProvider = OpenAICompatibleLLMProvider()
    }

    /// Initializer for dependency injection (used in tests only)
    /// - Note: Internal access to preserve singleton pattern while enabling testability
    internal init(llmProvider: LLMProvider) {
        self.llmProvider = llmProvider
    }

    // MARK: - Public Methods

    /// Generates response suggestions from the LLM.
    ///
    /// AC1: Returns 3-5 distinct suggestions
    /// AC2: Shows loading indicator while waiting
    /// AC3: Includes conversation history for context
    /// AC5: Handles partial text input
    ///
    /// - Parameters:
    ///   - prompt: The text to generate suggestions for
    ///   - context: Optional explicit context (overrides internal history)
    func generateSuggestions(for prompt: String, context: [String]? = nil) async {
        // AC5: Empty or whitespace-only prompt returns empty suggestions
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPrompt.isEmpty else {
            suggestions = []
            return
        }

        // AC2: Set loading state (AC4: keep previous suggestions visible until new ones arrive)
        isLoading = true
        showError = false
        // Note: Don't clear suggestions here - AC4 requires previous suggestions remain visible

        do {
            // AC3: Use provided context or fall back to conversation history
            let historyContext = context ?? conversationHistory

            // Story 4.2: Pass guidance context to provider before generation
            if let concreteProvider = llmProvider as? OpenAICompatibleLLMProvider {
                concreteProvider.guidanceContext = currentGuidance
                concreteProvider.moreLikeThis = lastSelectedSuggestion
            }

            // AC2: Generate suggestions (target < 500ms, 2s timeout handled by provider)
            let newSuggestions = try await llmProvider.generateSuggestions(
                prompt: prompt,
                context: historyContext.isEmpty ? nil : historyContext
            )

            // AC1: Ensure distinct suggestions, limited to configured count
            let uniqueSuggestions = newSuggestions.removingDuplicates()
            suggestions = Array(uniqueSuggestions.prefix(AppConfig.LLM.suggestionCount))
            isLoading = false

            // AC1: Log warning if fewer than 3 suggestions (minimum expected)
            if suggestions.count < 3 {
                print("SuggestionService [WARNING]: Only \(suggestions.count) suggestions returned (expected 3-5)")
            }

            print("SuggestionService: Generated \(suggestions.count) suggestions for: \(prompt.prefix(30))...")

        } catch {
            handleError(error)
        }
    }

    /// Adds a user message and optional AI response to conversation history.
    ///
    /// AC3: Maintains context for relevant suggestions.
    /// The history alternates user/assistant messages for proper LLM context.
    ///
    /// - Parameters:
    ///   - userMessage: The user's message to add
    ///   - aiResponse: Optional AI response to add after user message
    func addToHistory(userMessage: String, aiResponse: String? = nil) {
        conversationHistory.append(userMessage)
        if let response = aiResponse {
            conversationHistory.append(response)
        }

        // Limit history to maxHistoryExchanges exchanges (2 messages per exchange)
        let maxMessages = maxHistoryExchanges * 2
        if conversationHistory.count > maxMessages {
            conversationHistory = Array(conversationHistory.suffix(maxMessages))
        }

        print("SuggestionService: History updated, now \(conversationHistory.count) messages")
    }

    /// Clears conversation history for a new conversation.
    func clearHistory() {
        conversationHistory = []
        print("SuggestionService: Conversation history cleared")
    }

    /// Clears current suggestions (for UI reset).
    func clearSuggestions() {
        suggestions = []
    }

    /// Dismisses the current error state.
    func dismissError() {
        showError = false
        errorMessage = ""
    }

    /// Returns the current conversation history count for debugging.
    var historyCount: Int {
        conversationHistory.count
    }

    // MARK: - Guided Generation Methods (Story 4.2)

    /// Generates suggestions with a specific guidance context.
    /// AC2: Guidance context influences the type of suggestions generated.
    /// AC6: Conversation history is still considered.
    ///
    /// - Parameters:
    ///   - context: The guidance context to apply
    ///   - prompt: Optional custom prompt (defaults to context displayName)
    func generateGuidedSuggestions(context: GuidanceContext, prompt: String? = nil) async {
        currentGuidance = context
        lastSelectedSuggestion = nil  // Clear "more like this" state
        let effectivePrompt = prompt ?? context.displayName
        lastPrompt = effectivePrompt
        await generateSuggestions(for: effectivePrompt)
    }

    /// Generates variations of a specific suggestion (AC3: "More like this").
    /// The reference suggestion is stored and used by the LLM provider
    /// to generate similar suggestions in tone and content.
    ///
    /// - Parameter suggestion: The suggestion to generate variations of
    func generateVariations(of suggestion: String) async {
        lastSelectedSuggestion = suggestion
        // Use last prompt if available, otherwise use the suggestion itself
        let effectivePrompt = lastPrompt.isEmpty ? suggestion : lastPrompt
        await generateSuggestions(for: effectivePrompt)
    }

    /// Generates completely different suggestions (AC4: "Different").
    /// Clears the "more like this" reference and requests fresh suggestions.
    /// M2 Fix: If no previous prompt exists, uses current guidance or logs warning.
    func generateDifferentSuggestions() async {
        // Clear last selected to signal "different" mode
        lastSelectedSuggestion = nil
        if !lastPrompt.isEmpty {
            await generateSuggestions(for: lastPrompt)
        } else if let guidance = currentGuidance {
            // M2 Fix: Fallback to current guidance context if no lastPrompt
            await generateSuggestions(for: guidance.displayName)
        } else {
            // M2 Fix: Log warning when no context available for "different"
            print("SuggestionService [WARNING]: generateDifferentSuggestions() called with no lastPrompt or guidance context")
        }
    }

    /// Clears guidance context and related state.
    func clearGuidance() {
        currentGuidance = nil
        lastSelectedSuggestion = nil
        lastPrompt = ""
    }

    // MARK: - Private Methods

    /// AC4: Handle errors with French messages and recovery suggestions.
    /// Maps various error types to LLMError and displays user-friendly messages.
    /// H3 Fix: Also clears guidance state to prevent inconsistent UI state after errors.
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

        // AC4: Include both error description AND recovery suggestion
        if let suggestion = llmError.recoverySuggestion {
            errorMessage = "\(llmError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = llmError.localizedDescription
        }

        showError = true
        isLoading = false

        // H3 Fix: Clear guidance state on error to prevent inconsistent UI
        clearGuidance()

        // Never silent - always log for debugging (AC4)
        print("SuggestionService [ERROR]: \(llmError.failureReason ?? "unknown") - \(errorMessage)")
    }
}

// MARK: - Array Extension for Distinct Suggestions

private extension Array where Element: Hashable {
    /// Removes duplicate elements while preserving order (AC1: distinct suggestions)
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
