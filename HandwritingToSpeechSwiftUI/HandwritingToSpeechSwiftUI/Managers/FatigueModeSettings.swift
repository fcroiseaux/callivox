//
//  FatigueModeSettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 10.3: Fatigue Mode Button Customization Settings
//  Manages customizable fatigue mode messages with UserDefaults persistence
//  Pattern: Follows EmergencyMessageSettings.swift exactly
//

import SwiftUI
import os.log

// MARK: - Task 1.2: FatigueModeMessage Model
/// Story 10.3 AC1, AC4: Customizable fatigue mode message with text and color
struct FatigueModeMessage: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String           // Button label text (editable)
    var colorName: String      // Color name for Codable ("green", "red", etc.)

    // Convert colorName string to SwiftUI Color
    var color: Color {
        switch colorName {
        case "green": return .green
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return Color.orange.opacity(0.9)
        case "gray": return .gray
        default: return .gray
        }
    }
}

// MARK: - Task 1.3: PredefinedFatigueModeOption
/// Story 10.3 AC2: Predefined message option for quick selection
struct PredefinedFatigueModeOption: Identifiable {
    let id = UUID()
    let text: String
    let colorName: String
}

// MARK: - Task 1.3: FatigueModeOptionCategory
/// Story 10.3 AC2: Category grouping for predefined options
struct FatigueModeOptionCategory: Identifiable {
    let id = UUID()
    let name: String  // French category name
    let icon: String  // SF Symbol icon
    let options: [PredefinedFatigueModeOption]
}

// MARK: - Task 1.4, 1.11: FatigueModeSettings Manager
/// Story 10.3: Manages customizable fatigue mode messages with UserDefaults persistence
@MainActor
class FatigueModeSettings: ObservableObject {

    // Task 1.11: Singleton instance
    static let shared = FatigueModeSettings()

    // Error logging (pattern from EmergencyMessageSettings)
    private static let logger = Logger(subsystem: "com.callivox", category: "FatigueModeSettings")

    // Task 1.6: UserDefaults key
    private let userDefaultsKey = "fatigue_mode_messages_custom"

    // Task 1.5: Published array of customizable messages (5 slots)
    /// Story 10.3 AC1: 5 customizable fatigue mode messages
    @Published var customMessages: [FatigueModeMessage] = []

    // MARK: - Task 1.7: Default Messages (matching current FatigueModeView)
    /// Story 10.3 AC5: Original 5 fatigue mode messages for reset functionality
    static let defaultMessages: [FatigueModeMessage] = [
        FatigueModeMessage(id: UUID(), text: "OUI", colorName: "green"),
        FatigueModeMessage(id: UUID(), text: "NON", colorName: "red"),
        FatigueModeMessage(id: UUID(), text: "APPELER", colorName: "blue"),
        FatigueModeMessage(id: UUID(), text: "DOULEUR", colorName: "purple"),
        FatigueModeMessage(id: UUID(), text: "SOIF / FAIM", colorName: "orange")
    ]

    // MARK: - Task 1.8: Predefined Options by Category (AC2)
    /// Story 10.3 AC2: Predefined message options grouped by category
    static let predefinedCategories: [FatigueModeOptionCategory] = [
        FatigueModeOptionCategory(
            name: "Réponses de base",
            icon: "hand.thumbsup.fill",
            options: [
                PredefinedFatigueModeOption(text: "OUI", colorName: "green"),
                PredefinedFatigueModeOption(text: "NON", colorName: "red"),
                PredefinedFatigueModeOption(text: "PEUT-ÊTRE", colorName: "gray"),
                PredefinedFatigueModeOption(text: "D'ACCORD", colorName: "green")
            ]
        ),
        FatigueModeOptionCategory(
            name: "Besoins",
            icon: "drop.fill",
            options: [
                PredefinedFatigueModeOption(text: "SOIF", colorName: "blue"),
                PredefinedFatigueModeOption(text: "FAIM", colorName: "orange"),
                PredefinedFatigueModeOption(text: "SOIF / FAIM", colorName: "orange"),
                PredefinedFatigueModeOption(text: "TOILETTES", colorName: "purple"),
                PredefinedFatigueModeOption(text: "FATIGUE", colorName: "gray")
            ]
        ),
        FatigueModeOptionCategory(
            name: "Communication",
            icon: "message.fill",
            options: [
                PredefinedFatigueModeOption(text: "APPELER", colorName: "blue"),
                PredefinedFatigueModeOption(text: "AIDE", colorName: "orange"),
                PredefinedFatigueModeOption(text: "MERCI", colorName: "green"),
                PredefinedFatigueModeOption(text: "PARDON", colorName: "purple")
            ]
        ),
        FatigueModeOptionCategory(
            name: "Médical",
            icon: "cross.case.fill",
            options: [
                PredefinedFatigueModeOption(text: "DOULEUR", colorName: "red"),
                PredefinedFatigueModeOption(text: "MALAISE", colorName: "purple"),
                PredefinedFatigueModeOption(text: "MÉDICAMENT", colorName: "blue")
            ]
        )
    ]

    // MARK: - Available Colors for Color Picker (AC3)
    /// Story 10.3 AC3: Limited color palette for accessibility
    static let availableColors: [(name: String, displayName: String, color: Color)] = [
        ("green", "Vert", .green),
        ("red", "Rouge", .red),
        ("blue", "Bleu", .blue),
        ("purple", "Violet", .purple),
        ("orange", "Orange", Color.orange.opacity(0.9)),
        ("gray", "Gris", .gray)
    ]

    // M1 Fix (Code Review): Centralized color lookup to avoid duplicate logic
    /// Convert color name string to SwiftUI Color
    static func color(for name: String) -> Color {
        availableColors.first(where: { $0.name == name })?.color ?? .gray
    }

    // MARK: - Initialization

    init() {
        loadMessages()
    }

    // MARK: - Task 1.6: Persistence Methods

    /// Load messages from UserDefaults or use defaults
    private func loadMessages() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
            do {
                let saved = try JSONDecoder().decode([FatigueModeMessage].self, from: data)
                // Validate we have exactly 5 messages
                if saved.count == 5 {
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

    // MARK: - Task 1.9: Update Message (AC3)

    /// Update a specific message's text and color
    /// - Parameters:
    ///   - index: Message index (0-4)
    ///   - text: New button label text
    ///   - colorName: New color name ("green", "red", etc.)
    func updateMessage(at index: Int, text: String, colorName: String) {
        guard index >= 0 && index < customMessages.count else { return }
        guard !text.isEmpty else { return }

        // Create new message preserving id
        var updatedMessage = customMessages[index]
        updatedMessage.text = text
        updatedMessage.colorName = colorName
        customMessages[index] = updatedMessage

        // AC3: Save immediately
        saveMessages()
    }

    // MARK: - Task 1.10: Reset to Defaults (AC5)

    /// Story 10.3 AC5: Restore original 5 fatigue mode messages
    func resetToDefaults() {
        customMessages = Self.defaultMessages
        saveMessages()
    }
}
