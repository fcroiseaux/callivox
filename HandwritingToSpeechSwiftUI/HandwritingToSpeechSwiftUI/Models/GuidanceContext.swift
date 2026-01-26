//
//  GuidanceContext.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 4.2: UI Guidance Controls
//  Quick context options for guiding AI suggestions in real-time.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Quick context options for guiding AI suggestions (Story 4.2)
/// Allows users to quickly select a conversation context type
/// to receive more relevant suggestions.
///
/// Usage:
/// ```swift
/// let context = GuidanceContext.greeting
/// // Display: "Salutation"
/// // Icon: "hand.wave"
/// // Prompt: "Génère des salutations appropriées..."
/// ```
enum GuidanceContext: String, CaseIterable, Identifiable {
    case greeting = "greeting"      // Salutation
    case question = "question"      // Question
    case answer = "answer"          // Réponse
    case thanks = "thanks"          // Remerciement
    case goodbye = "goodbye"        // Au revoir

    var id: String { rawValue }

    // MARK: - Display Properties

    /// French display name for UI (AC1)
    var displayName: String {
        switch self {
        case .greeting: return "Salutation"
        case .question: return "Question"
        case .answer: return "Réponse"
        case .thanks: return "Remerciement"
        case .goodbye: return "Au revoir"
        }
    }

    /// SF Symbol icon for button (AC1)
    var icon: String {
        switch self {
        case .greeting: return "hand.wave"
        case .question: return "questionmark.bubble"
        case .answer: return "text.bubble"
        case .thanks: return "heart"
        case .goodbye: return "hand.raised"
        }
    }

    // MARK: - LLM Prompt Instructions

    /// Prompt instruction for LLM to generate context-appropriate suggestions (AC2)
    /// These instructions are appended to the system prompt when guidance is active.
    var promptInstruction: String {
        switch self {
        case .greeting:
            return "Génère des salutations appropriées (Bonjour, Salut, Bonsoir, etc.)"
        case .question:
            return "Génère des questions pertinentes au contexte"
        case .answer:
            return "Génère des réponses adaptées à la conversation"
        case .thanks:
            return "Génère des expressions de remerciement (Merci, Je vous remercie, etc.)"
        case .goodbye:
            return "Génère des formules de départ (Au revoir, À bientôt, Bonne journée, etc.)"
        }
    }
}
