//
//  LLMProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.1: LLM Service Integration
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Protocol abstraction for LLM (Large Language Model) providers.
/// Enables switching between Cerebras, OpenAI, and other OpenAI-compatible providers
/// without changing the service layer interface.
///
/// Implementations must handle:
/// - Secure API key retrieval from Keychain
/// - Network availability checking before API calls
/// - OpenAI-compatible chat completion format
/// - French localized error messages via LLMError
protocol LLMProvider {

    /// Generates response suggestions from the LLM.
    ///
    /// - Parameters:
    ///   - prompt: The user's input text or context requiring suggestions
    ///   - context: Optional conversation history for better context-aware suggestions
    ///
    /// - Returns: Array of suggestion strings (typically 3-5 suggestions)
    ///
    /// - Throws: LLMError if generation fails (network unavailable, invalid API key, etc.)
    ///
    /// - Note: The implementation should parse numbered suggestions from the LLM response
    ///         (e.g., "1. Suggestion one\n2. Suggestion two") into separate strings.
    func generateSuggestions(prompt: String, context: [String]?) async throws -> [String]
}
