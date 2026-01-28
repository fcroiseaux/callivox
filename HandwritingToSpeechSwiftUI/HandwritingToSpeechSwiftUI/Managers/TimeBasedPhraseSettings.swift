//
//  TimeBasedPhraseSettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.1: Time-Based Predictive Phrases
//  Story 11.2: Time-Based Phrase Customization
//  Task 1: Model for managing time-based phrase suggestions
//

import Foundation
import SwiftUI  // L3 Fix: Required for Color in iconColor property

// MARK: - Story 11.1 Task 1.2: TimePeriod Enum

/// Time periods for contextual phrase suggestions (AC: 2, 3, 4, 5)
/// Each period defines a specific 2-hour window when its phrases are relevant.
///
/// Code Review Fix M1: Clarified hour ranges
/// - Period ranges are INCLUSIVE of start hour, through end of that hour
/// - Example: morning 7...8 means 7:00:00 to 8:59:59 (2 hours)
enum TimePeriod: String, CaseIterable {
    case morning   // 7:00-8:59 (2h window, AC2)
    case lunch     // 12:00-13:59 (2h window, AC3)
    case evening   // 18:00-19:59 (2h window, AC4)
    case night     // 21:00-22:59 (2h window, AC5)
    case none      // Outside active periods

    /// Story 11.1 AC2-5: Hour range for each period
    /// Returns the hour range (0-23) when this period is active
    var hourRange: ClosedRange<Int>? {
        switch self {
        case .morning: return 7...8   // 7h00-8h59
        case .lunch: return 12...13   // 12h00-13h59
        case .evening: return 18...19 // 18h00-19h59
        case .night: return 21...22   // 21h00-22h59
        case .none: return nil
        }
    }

    /// Display name for header (French)
    var displayName: String {
        switch self {
        case .morning: return "Matin"
        case .lunch: return "Midi"
        case .evening: return "Soir"
        case .night: return "Nuit"
        case .none: return ""
        }
    }

    /// Icon for header display
    var icon: String {
        switch self {
        case .morning: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .evening: return "sunset.fill"
        case .night: return "moon.stars.fill"
        case .none: return "clock"
        }
    }

    /// Story 11.2: Time range display for settings UI (French)
    /// Code Review Fix M1: Display matches actual hourRange (inclusive start, end of hour)
    var timeRangeDisplay: String {
        switch self {
        case .morning: return "7h-8h59"
        case .lunch: return "12h-13h59"
        case .evening: return "18h-19h59"
        case .night: return "21h-22h59"
        case .none: return ""
        }
    }

    /// L3 Fix: Centralized iconColor property to avoid duplication across views
    var iconColor: Color {
        switch self {
        case .morning: return .orange
        case .lunch: return .yellow
        case .evening: return .orange
        case .night: return .indigo
        case .none: return .gray
        }
    }

    /// Story 11.1 Task 1.4: Determine current time period based on current hour
    static func current() -> TimePeriod {
        let hour = Calendar.current.component(.hour, from: Date())
        for period in [TimePeriod.morning, .lunch, .evening, .night] {
            if let range = period.hourRange, range.contains(hour) {
                return period
            }
        }
        return .none
    }

    /// For testing: determine period for a specific hour
    /// - Parameter hour: Hour value (0-23). Values outside range are clamped.
    /// - Returns: The time period for the given hour, or .none if outside active periods
    static func period(for hour: Int) -> TimePeriod {
        // Code Review Fix M4: Validate input - clamp to valid hour range
        let validHour = max(0, min(23, hour))

        for period in [TimePeriod.morning, .lunch, .evening, .night] {
            if let range = period.hourRange, range.contains(validHour) {
                return period
            }
        }
        return .none
    }
}

// MARK: - Story 11.1 Task 1: TimeBasedPhraseSettings Manager

/// Manager for time-based predictive phrases (AC: 1, 2, 3, 4, 5)
/// Follows PresetSentenceManager singleton pattern with UserDefaults persistence.
///
/// Usage:
/// ```swift
/// let settings = TimeBasedPhraseSettings.shared
/// if let phrases = settings.phrasesForCurrentPeriod() {
///     // Display phrases in UI
/// }
/// ```
@MainActor
class TimeBasedPhraseSettings: ObservableObject {

    // MARK: - Story 11.1 Task 1.7: Singleton Instance

    static let shared = TimeBasedPhraseSettings()

    // MARK: - Story 11.1 Task 1.6: Published Properties with Persistence

    /// Whether time-based phrases feature is enabled
    /// Defaults to true for new feature discovery
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
        }
    }

    // MARK: - Private Constants

    // Code Review Fix M2: Namespaced UserDefaults key to avoid conflicts
    private static let enabledKey = "com.callivox.time_based_phrases_enabled"
    // Story 11.2 Task 1.2: Custom phrases UserDefaults key
    private static let customPhrasesKey = "com.callivox.time_based_custom_phrases"

    // MARK: - Story 11.2 Task 1.1: Custom Phrases Storage

    /// Custom phrases per period, overrides defaults when set
    /// Stored as [String: [String]] where key is TimePeriod.rawValue
    @Published var customPhrases: [String: [String]] = [:] {
        didSet {
            saveCustomPhrases()
        }
    }

    // MARK: - Story 11.1 Task 1.3: Default Phrases

    /// Default phrases for each time period (French)
    /// AC2: Morning phrases (7h-9h)
    /// AC3: Lunch phrases (12h-14h)
    /// AC4: Evening phrases (18h-20h)
    /// AC5: Night phrases (21h-23h)
    private let defaultPhrases: [TimePeriod: [String]] = [
        .morning: ["Bonjour", "Café", "Médicaments", "Petit-déjeuner"],
        .lunch: ["J'ai faim", "Repas", "Merci", "C'est bon"],
        .evening: ["Dîner", "Fatigué", "Télévision", "Merci"],
        .night: ["Bonne nuit", "Lit", "Lumière", "Toilettes"]
    ]

    // MARK: - Initialization

    /// Story 11.1 Task 1.1: Initialize with UserDefaults persistence
    /// Story 11.2: Load custom phrases from UserDefaults
    init() {
        // Default to true for new feature discovery
        // Use object(forKey:) to detect if key doesn't exist (nil)
        self.isEnabled = UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true
        // Story 11.2: Load custom phrases
        loadCustomPhrases()
    }

    // MARK: - Story 11.2: Custom Phrases Persistence

    /// Save custom phrases to UserDefaults as JSON
    private func saveCustomPhrases() {
        if let data = try? JSONEncoder().encode(customPhrases) {
            UserDefaults.standard.set(data, forKey: Self.customPhrasesKey)
        }
    }

    /// Load custom phrases from UserDefaults
    /// Code Review Fix M3: Note that assignment triggers didSet (acceptable one-time re-save on init)
    private func loadCustomPhrases() {
        guard let data = UserDefaults.standard.data(forKey: Self.customPhrasesKey),
              let phrases = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return
        }
        // Note: This triggers didSet which re-saves to UserDefaults (acceptable overhead on init)
        self.customPhrases = phrases
    }

    // MARK: - Story 11.1 Task 1.4 & 1.5: Public Methods

    /// Returns the current time period based on system time
    var currentTimePeriod: TimePeriod {
        TimePeriod.current()
    }

    /// Story 11.1 Task 1.5: Get phrases for current time period
    /// Story 11.2 Task 1.7: Returns custom phrases if set, else defaults
    /// Returns nil if outside active periods or feature is disabled
    /// - Returns: Array of 3-6 contextual phrases, or nil if not applicable
    func phrasesForCurrentPeriod() -> [String]? {
        guard isEnabled else { return nil }

        let period = currentTimePeriod
        guard period != .none else { return nil }

        return phrases(for: period)
    }

    /// Story 11.2 Task 1.8: Get phrases for a specific period
    /// Returns custom phrases if set, otherwise returns defaults
    /// - Parameter period: The time period to get phrases for
    /// - Returns: Array of phrases for the period, or nil if none defined
    func phrases(for period: TimePeriod) -> [String]? {
        guard period != .none else { return nil }
        // Return custom phrases if set and non-empty, otherwise defaults
        if let custom = customPhrases[period.rawValue], !custom.isEmpty {
            return custom
        }
        return defaultPhrases[period]
    }

    /// Check if there are phrases available for current period
    var hasPhrasesForCurrentPeriod: Bool {
        guard isEnabled else { return false }
        return phrasesForCurrentPeriod() != nil
    }

    // MARK: - Story 11.2 Task 1.3-1.6: Custom Phrase Management

    /// Story 11.2 Task 1.3: Update all phrases for a period
    /// - Parameters:
    ///   - period: The time period to update
    ///   - phrases: The new phrases array (will be limited to 6 phrases)
    func updatePhrases(for period: TimePeriod, phrases: [String]) {
        guard period != .none else { return }
        // Limit to maximum 6 phrases
        let limitedPhrases = Array(phrases.prefix(6))
        customPhrases[period.rawValue] = limitedPhrases
    }

    /// Story 11.2 Task 1.4: Add phrase to period (max 6)
    /// - Parameters:
    ///   - period: The time period to add phrase to
    ///   - phrase: The phrase to add
    /// - Returns: true if phrase was added, false if period is .none or limit reached
    @discardableResult
    func addPhrase(to period: TimePeriod, phrase: String) -> Bool {
        guard period != .none else { return false }
        var current = phrases(for: period) ?? []
        guard current.count < 6 else { return false }
        current.append(phrase)
        customPhrases[period.rawValue] = current
        return true
    }

    /// Story 11.2 Task 1.5: Remove phrase from period (min 1)
    /// - Parameters:
    ///   - period: The time period to remove phrase from
    ///   - index: The index of the phrase to remove
    /// - Returns: true if phrase was removed, false if period is .none, index invalid, or only 1 phrase remains
    @discardableResult
    func removePhrase(from period: TimePeriod, at index: Int) -> Bool {
        guard period != .none else { return false }
        var current = phrases(for: period) ?? []
        guard current.count > 1, index >= 0, index < current.count else { return false }
        current.remove(at: index)
        customPhrases[period.rawValue] = current
        return true
    }

    /// Story 11.2 Task 1.6: Reset all custom phrases to defaults
    /// Clears all custom phrases, reverting to default phrases for all periods
    func resetToDefaults() {
        customPhrases = [:]
        UserDefaults.standard.removeObject(forKey: Self.customPhrasesKey)
    }

    /// Story 11.2: Check if a period has custom phrases
    /// - Parameter period: The time period to check
    /// - Returns: true if custom phrases are set for this period
    func hasCustomPhrases(for period: TimePeriod) -> Bool {
        guard period != .none else { return false }
        return customPhrases[period.rawValue] != nil && !(customPhrases[period.rawValue]?.isEmpty ?? true)
    }

    /// Story 11.2: Get the phrase count for a period
    /// - Parameter period: The time period to get count for
    /// - Returns: Number of phrases for the period
    func phraseCount(for period: TimePeriod) -> Int {
        return phrases(for: period)?.count ?? 0
    }
}
