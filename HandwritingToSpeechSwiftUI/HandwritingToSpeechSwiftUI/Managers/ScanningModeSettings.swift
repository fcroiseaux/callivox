//
//  ScanningModeSettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.3: Scanning Mode Settings Manager
//  Story 11.4: Added ScanDirection enum and property
//  Manages scanning mode configuration with UserDefaults persistence.
//  Pattern: Follows FatigueModeSettings.swift exactly.
//

import SwiftUI
import os.log

// MARK: - Story 11.3 Task 1.7: ScanSpeed Enum

/// Story 11.3 AC2: Scan speed configuration with TimeInterval values
enum ScanSpeed: String, CaseIterable, Codable {
    case slow = "slow"
    case medium = "medium"
    case fast = "fast"

    /// Interval in seconds between button highlights
    var interval: TimeInterval {
        switch self {
        case .slow: return 3.0
        case .medium: return 2.0
        case .fast: return 1.0
        }
    }

    /// French display name for settings UI (Story 11.4)
    var displayName: String {
        switch self {
        case .slow: return "Lent (3s)"
        case .medium: return "Moyen (2s)"
        case .fast: return "Rapide (1s)"
        }
    }
}

// MARK: - Story 11.4 Task 1.1: ScanDirection Enum

/// Story 11.4 AC1: Scan direction configuration
enum ScanDirection: String, CaseIterable, Codable {
    case forwardOnly = "forward_only"
    case forwardAndBackward = "forward_and_backward"

    /// French display name for settings UI
    var displayName: String {
        switch self {
        case .forwardOnly: return "Avant uniquement"
        case .forwardAndBackward: return "Avant et arrière"
        }
    }

    /// Accessibility description for footer text
    var accessibilityDescription: String {
        switch self {
        case .forwardOnly: return "Le scanning recommence au début après le dernier élément"
        case .forwardAndBackward: return "Le scanning fait demi-tour aux extrémités"
        }
    }
}

// MARK: - Story 11.3 Task 1.1, 1.2: ScanningModeSettings Manager

/// Story 11.3: Manages scanning mode configuration with UserDefaults persistence
/// Singleton pattern following FatigueModeSettings.swift
@MainActor
class ScanningModeSettings: ObservableObject {

    // Task 1.2: Singleton instance
    static let shared = ScanningModeSettings()

    // Logger for error tracking (pattern from FatigueModeSettings)
    private static let logger = Logger(subsystem: "com.callivox", category: "ScanningModeSettings")

    // MARK: - UserDefaults Keys (Story 11.3 Task 1.3, 1.8 + Story 11.4 Task 1.3)
    // M2 Learning from 11.2: Use namespaced UserDefaults keys

    private static let isEnabledKey = "com.callivox.scanning_mode_enabled"
    private static let scanSpeedKey = "com.callivox.scanning_mode_speed"
    private static let autoRestartKey = "com.callivox.scanning_mode_auto_restart"
    private static let soundFeedbackKey = "com.callivox.scanning_mode_sound_feedback"
    // Story 11.4 Task 1.3: Scan direction key
    private static let scanDirectionKey = "com.callivox.scanning_mode_direction"

    // MARK: - Published Properties

    /// Task 1.3: Scanning mode enabled state with UserDefaults persistence
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.isEnabledKey)
        }
    }

    /// Task 1.4: Scan speed setting (default: medium = 2 seconds)
    @Published var scanSpeed: ScanSpeed {
        didSet {
            saveScanSpeed()
        }
    }

    /// Task 1.5: Auto-restart scanning after full cycle (default: true)
    @Published var autoRestart: Bool {
        didSet {
            UserDefaults.standard.set(autoRestart, forKey: Self.autoRestartKey)
        }
    }

    /// Task 1.6: Sound feedback on highlight (default: false) - for Story 11.4
    @Published var soundFeedbackEnabled: Bool {
        didSet {
            UserDefaults.standard.set(soundFeedbackEnabled, forKey: Self.soundFeedbackKey)
        }
    }

    /// Story 11.4 Task 1.2: Scan direction setting (default: forwardOnly)
    @Published var scanDirection: ScanDirection {
        didSet {
            saveScanDirection()
        }
    }

    // MARK: - Initialization

    init() {
        // Task 1.3: Load isEnabled (defaults to false)
        self.isEnabled = UserDefaults.standard.bool(forKey: Self.isEnabledKey)

        // Task 1.4: Load scanSpeed (defaults to medium)
        self.scanSpeed = Self.loadScanSpeed()

        // Task 1.5: Load autoRestart (defaults to true when key doesn't exist)
        // Use object(forKey:) as? Bool ?? true pattern (like requireConfirmationDialogs)
        self.autoRestart = UserDefaults.standard.object(forKey: Self.autoRestartKey) as? Bool ?? true

        // Task 1.6: Load soundFeedbackEnabled (defaults to false)
        self.soundFeedbackEnabled = UserDefaults.standard.bool(forKey: Self.soundFeedbackKey)

        // Story 11.4 Task 1.2: Load scanDirection (defaults to forwardOnly)
        self.scanDirection = Self.loadScanDirection()
    }

    // MARK: - Task 1.8: Persistence Methods

    /// Save scanSpeed to UserDefaults using JSON encoding
    private func saveScanSpeed() {
        do {
            let data = try JSONEncoder().encode(scanSpeed)
            UserDefaults.standard.set(data, forKey: Self.scanSpeedKey)
        } catch {
            Self.logger.error("Failed to encode scanSpeed: \(error.localizedDescription)")
        }
    }

    /// Load scanSpeed from UserDefaults with JSON decoding
    private static func loadScanSpeed() -> ScanSpeed {
        guard let data = UserDefaults.standard.data(forKey: scanSpeedKey) else {
            return .medium  // Default value
        }
        do {
            return try JSONDecoder().decode(ScanSpeed.self, from: data)
        } catch {
            logger.error("Failed to decode scanSpeed: \(error.localizedDescription)")
            return .medium  // Default on error
        }
    }

    /// Story 11.4 Task 1.2: Save scanDirection to UserDefaults using JSON encoding
    private func saveScanDirection() {
        do {
            let data = try JSONEncoder().encode(scanDirection)
            UserDefaults.standard.set(data, forKey: Self.scanDirectionKey)
        } catch {
            Self.logger.error("Failed to encode scanDirection: \(error.localizedDescription)")
        }
    }

    /// Story 11.4 Task 1.2: Load scanDirection from UserDefaults with JSON decoding
    private static func loadScanDirection() -> ScanDirection {
        guard let data = UserDefaults.standard.data(forKey: scanDirectionKey) else {
            return .forwardOnly  // Default value
        }
        do {
            return try JSONDecoder().decode(ScanDirection.self, from: data)
        } catch {
            logger.error("Failed to decode scanDirection: \(error.localizedDescription)")
            return .forwardOnly  // Default on error
        }
    }

    // MARK: - Task 1.9: Reset to Defaults

    /// Story 11.3, 11.4: Reset all scanning mode settings to defaults
    func resetToDefaults() {
        isEnabled = false
        scanSpeed = .medium
        autoRestart = true
        soundFeedbackEnabled = false
        // Story 11.4 Task 1.4: Reset scanDirection to forwardOnly
        scanDirection = .forwardOnly

        // Clear all UserDefaults keys
        UserDefaults.standard.removeObject(forKey: Self.isEnabledKey)
        UserDefaults.standard.removeObject(forKey: Self.scanSpeedKey)
        UserDefaults.standard.removeObject(forKey: Self.autoRestartKey)
        UserDefaults.standard.removeObject(forKey: Self.soundFeedbackKey)
        UserDefaults.standard.removeObject(forKey: Self.scanDirectionKey)
    }
}
