//
//  EmergencyMessageSettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 9.3: Emergency Message Customization Settings
//  Manages customizable emergency panel messages with UserDefaults persistence
//

import SwiftUI
import os.log

// MARK: - Task 1.2: Custom Emergency Message Model
/// Story 9.3 AC2, AC3: Customizable emergency message with fixed emoji and color
struct CustomEmergencyMessage: Identifiable, Codable, Hashable {
    let id: UUID
    let emoji: String           // Fixed per message type (AC3: icons remain consistent)
    var displayText: String     // Button label text (editable)
    var spokenText: String      // TTS spoken text (editable)
    let backgroundColor: String // Color name for Codable (fixed)

    // Convert backgroundColor string to SwiftUI Color
    var color: Color {
        switch backgroundColor {
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        default: return .gray
        }
    }
}

// MARK: - Task 4.1: Predefined Emergency Option
/// Story 9.3 AC2: Predefined message options for each emergency type
struct PredefinedEmergencyOption: Identifiable {
    let id = UUID()
    let displayText: String
    let spokenText: String
}

// MARK: - Task 1.3, 1.7: Emergency Message Settings Manager
/// Story 9.3: Manages customizable emergency messages with UserDefaults persistence
@MainActor
class EmergencyMessageSettings: ObservableObject {

    // Task 1.7: Singleton instance
    static let shared = EmergencyMessageSettings()

    // Error logging (pattern from PresetSentenceManager)
    private static let logger = Logger(subsystem: "com.callivox", category: "EmergencyMessageSettings")

    // Task 1.5: UserDefaults key
    private let userDefaultsKey = "emergency_messages_custom"

    // Task 1.4: Published array of customizable messages
    /// Story 9.3 AC2, AC3: 4 customizable emergency messages
    @Published var customMessages: [CustomEmergencyMessage] = []

    // MARK: - Task 1.8: Default Messages (from Story 9.2)
    /// Story 9.3 AC4: Original 4 emergency messages for reset functionality
    static let defaultMessages: [CustomEmergencyMessage] = [
        CustomEmergencyMessage(
            id: UUID(),
            emoji: "🚨",
            displayText: "APPELER À L'AIDE",
            spokenText: "Aidez-moi ! J'ai besoin d'aide !",
            backgroundColor: "orange"
        ),
        CustomEmergencyMessage(
            id: UUID(),
            emoji: "😰",
            displayText: "J'AI MAL",
            spokenText: "J'ai mal. J'ai très mal.",
            backgroundColor: "red"
        ),
        CustomEmergencyMessage(
            id: UUID(),
            emoji: "🏥",
            displayText: "MÉDECIN",
            spokenText: "Appelez un médecin s'il vous plaît.",
            backgroundColor: "blue"
        ),
        CustomEmergencyMessage(
            id: UUID(),
            emoji: "😵",
            displayText: "MALAISE",
            spokenText: "Je me sens mal. Je fais un malaise.",
            backgroundColor: "purple"
        )
    ]

    // MARK: - Task 4.2: Predefined Options per Message Type
    /// Story 9.3 AC2: Predefined message options for quick selection
    static let predefinedOptions: [[PredefinedEmergencyOption]] = [
        // Index 0: Appeler à l'aide options
        [
            PredefinedEmergencyOption(displayText: "APPELER À L'AIDE", spokenText: "Aidez-moi ! J'ai besoin d'aide !"),
            PredefinedEmergencyOption(displayText: "AU SECOURS", spokenText: "Au secours ! Venez m'aider !"),
            PredefinedEmergencyOption(displayText: "À L'AIDE", spokenText: "À l'aide ! J'ai besoin d'assistance !")
        ],
        // Index 1: J'ai mal options
        [
            PredefinedEmergencyOption(displayText: "J'AI MAL", spokenText: "J'ai mal. J'ai très mal."),
            PredefinedEmergencyOption(displayText: "DOULEUR", spokenText: "J'ai une douleur intense."),
            PredefinedEmergencyOption(displayText: "SOUFFRANCE", spokenText: "Je souffre beaucoup. Aidez-moi.")
        ],
        // Index 2: Médecin options
        [
            PredefinedEmergencyOption(displayText: "MÉDECIN", spokenText: "Appelez un médecin s'il vous plaît."),
            PredefinedEmergencyOption(displayText: "DOCTEUR", spokenText: "J'ai besoin d'un docteur."),
            PredefinedEmergencyOption(displayText: "URGENCE MÉDICALE", spokenText: "Urgence médicale. Appelez les secours.")
        ],
        // Index 3: Malaise options
        [
            PredefinedEmergencyOption(displayText: "MALAISE", spokenText: "Je me sens mal. Je fais un malaise."),
            PredefinedEmergencyOption(displayText: "VERTIGE", spokenText: "J'ai des vertiges. Je me sens mal."),
            PredefinedEmergencyOption(displayText: "PAS BIEN", spokenText: "Je ne me sens pas bien du tout.")
        ]
    ]

    // MARK: - Initialization

    init() {
        loadMessages()
    }

    // MARK: - Task 1.5: Persistence Methods

    /// Load messages from UserDefaults or use defaults
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let saved = try JSONDecoder().decode([CustomEmergencyMessage].self, from: data)
                // Validate we have exactly 4 messages with correct structure
                if saved.count == 4 {
                    customMessages = saved
                    return
                }
            } catch {
                Self.logger.error("Failed to decode customMessages: \(error.localizedDescription)")
            }
        }
        // First launch, corrupted data, or wrong count - use defaults
        customMessages = Self.defaultMessages
        saveMessages()
    }

    /// Save messages to UserDefaults
    func saveMessages() {
        do {
            let data = try JSONEncoder().encode(customMessages)
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        } catch {
            Self.logger.error("Failed to encode customMessages: \(error.localizedDescription)")
        }
    }

    // MARK: - Story 9.3 AC2: Update Message

    /// Update a specific message's display and spoken text
    /// - Parameters:
    ///   - index: Message index (0-3)
    ///   - displayText: New button label text
    ///   - spokenText: New TTS spoken text
    func updateMessage(at index: Int, displayText: String, spokenText: String) {
        guard index >= 0 && index < customMessages.count else { return }
        guard !displayText.isEmpty && !spokenText.isEmpty else { return }

        // Create new message preserving id, emoji, backgroundColor
        var updatedMessage = customMessages[index]
        updatedMessage.displayText = displayText
        updatedMessage.spokenText = spokenText
        customMessages[index] = updatedMessage

        // AC2: Save immediately
        saveMessages()
    }

    // MARK: - Task 1.6: Reset to Defaults (AC4)

    /// Story 9.3 AC4: Restore original 4 emergency messages
    func resetToDefaults() {
        customMessages = Self.defaultMessages
        saveMessages()
    }
}
