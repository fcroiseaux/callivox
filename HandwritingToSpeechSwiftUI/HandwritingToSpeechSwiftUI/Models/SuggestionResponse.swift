//
//  SuggestionResponse.swift
//  HandwritingToSpeechSwiftUI
//
//  InvincibleVoice Integration: JSON response model for LLM suggestions.
//  Contains both quick keywords (10) and full answer suggestions (4).
//  Created by CalliVox on 2026-01-27.
//

import Foundation

/// Response model for LLM suggestions in JSON format.
/// Matches InvincibleVoice schema with keywords for quick responses
/// and full answers for detailed suggestions.
///
/// JSON Format:
/// ```json
/// {
///   "suggested_keywords": ["Oui", "Non", "Peut-être", ...],
///   "suggested_answers": ["Très bien, merci !", "Ça va bien, et toi ?", ...]
/// }
/// ```
struct SuggestionResponse: Codable {
    /// Quick response keywords (target: 10 items)
    /// Short words or phrases for immediate responses.
    let suggestedKeywords: [String]

    /// Full answer suggestions (target: 4 items)
    /// Complete sentences for detailed responses.
    let suggestedAnswers: [String]

    enum CodingKeys: String, CodingKey {
        case suggestedKeywords = "suggested_keywords"
        case suggestedAnswers = "suggested_answers"
    }

    /// Creates an empty response (used for error fallback)
    static var empty: SuggestionResponse {
        SuggestionResponse(suggestedKeywords: [], suggestedAnswers: [])
    }

    /// F2 Fix: Centralized default keywords for fallback scenarios.
    /// Used when LLM response doesn't include keywords or when using non-OpenAI providers.
    static let defaultKeywords: [String] = [
        "Oui", "Non", "D'accord", "Merci", "S'il vous plaît",
        "Je ne sais pas", "Peut-être", "Bien sûr", "Pardon", "Au revoir"
    ]
}
