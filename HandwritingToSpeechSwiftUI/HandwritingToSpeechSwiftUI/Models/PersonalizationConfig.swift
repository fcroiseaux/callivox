//
//  PersonalizationConfig.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 4.1: LLM Personalization Settings
//  Model for storing user's AI personalization preferences.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

// MARK: - Communication Tone

/// Communication tone options for AI suggestions (AC2)
/// Controls the formality level of generated suggestions.
enum CommunicationTone: String, Codable, CaseIterable {
    case formal = "formal"      // "vous", professional language
    case neutral = "neutral"    // Default, balanced
    case casual = "casual"      // "tu", informal language

    /// Display name for UI (French)
    var displayName: String {
        switch self {
        case .formal: return "Formel"
        case .neutral: return "Neutre"
        case .casual: return "Décontracté"
        }
    }

    /// Instruction text to include in LLM system prompt
    var promptInstruction: String {
        switch self {
        case .formal: return "Utilisez un langage soutenu et le vouvoiement."
        case .neutral: return "Utilisez un langage courant et naturel."
        case .casual: return "Utilisez un langage familier et le tutoiement."
        }
    }
}

// MARK: - Response Length

/// Response length preference for AI suggestions (AC2)
/// Controls how long the generated suggestions should be.
enum ResponseLength: String, Codable, CaseIterable {
    case short = "short"      // 1-2 phrases
    case medium = "medium"    // 2-4 phrases
    case long = "long"        // 4+ phrases

    /// Display name for UI (French)
    var displayName: String {
        switch self {
        case .short: return "Court"
        case .medium: return "Moyen"
        case .long: return "Long"
        }
    }

    /// Instruction text to include in LLM system prompt
    var promptInstruction: String {
        switch self {
        case .short: return "Génère des réponses courtes de 1 à 2 phrases maximum."
        case .medium: return "Génère des réponses de longueur moyenne de 2 à 4 phrases."
        case .long: return "Génère des réponses détaillées de 4 phrases ou plus."
        }
    }
}

// MARK: - PersonalizationConfig

/// Model for storing user's AI personalization settings (Story 4.1)
///
/// Stores user preferences for how the AI generates suggestions:
/// - Communication tone (formal, neutral, casual)
/// - Response length (short, medium, long)
/// - Personal context (free text describing user's situation)
///
/// Settings are persisted to UserDefaults and applied to all LLM requests.
///
/// Usage:
/// ```swift
/// // Load current settings
/// let config = PersonalizationConfig.loadFromUserDefaults()
///
/// // Modify and save
/// var newConfig = config
/// newConfig.tone = .formal
/// newConfig.saveToUserDefaults()
///
/// // Reset to defaults
/// PersonalizationConfig.resetToDefaults()
/// ```
struct PersonalizationConfig: Codable, Equatable {
    /// Communication tone for suggestions (AC2)
    var tone: CommunicationTone

    /// Preferred length of suggestions (AC2)
    var responseLength: ResponseLength

    /// Free text describing user's situation, preferences, etc. (AC3)
    /// Max 500 characters, trimmed on load.
    var personalContext: String

    // MARK: - Default Configuration

    /// Default configuration with neutral settings and empty context
    static let defaultConfig = PersonalizationConfig(
        tone: .neutral,
        responseLength: .medium,
        personalContext: ""
    )

    // MARK: - UserDefaults Persistence

    /// UserDefaults key for storing the configuration
    private static let userDefaultsKey = "llm_personalization_config"

    /// Maximum allowed length for personal context
    static let maxContextLength = 500

    /// Saves the current configuration to UserDefaults (AC4)
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: Self.userDefaultsKey)
        }
    }

    /// Loads configuration from UserDefaults, returning default if not found or invalid (AC4)
    static func loadFromUserDefaults() -> PersonalizationConfig {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let config = try? JSONDecoder().decode(PersonalizationConfig.self, from: data) else {
            return defaultConfig
        }

        // Ensure personal context doesn't exceed max length
        var safeConfig = config
        if safeConfig.personalContext.count > maxContextLength {
            safeConfig.personalContext = String(safeConfig.personalContext.prefix(maxContextLength))
        }

        return safeConfig
    }

    /// Resets configuration to defaults by removing from UserDefaults (AC6)
    static func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    /// Checks if the current configuration differs from defaults
    var isModified: Bool {
        return self != Self.defaultConfig
    }
}
