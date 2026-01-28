//
//  AccessibilitySettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 7.1: Accessibility Settings Model (AC3, AC4)
//  Story 10.1: Fatigue Mode state management (AC2)
//  Manages the Enhanced Accessibility mode state with UserDefaults persistence
//

import SwiftUI

// Story 7.1: Accessibility settings model with immediate reactivity (AC4)
// Uses ObservableObject pattern for iOS 16.0+ compatibility
@MainActor
final class AccessibilitySettings: ObservableObject {

    // Story 7.1 AC3: Toggle state with automatic persistence
    @Published var isEnhancedModeEnabled: Bool {
        didSet {
            // Story 7.1 AC3: Persist to UserDefaults on every change
            UserDefaults.standard.set(isEnhancedModeEnabled, forKey: Self.userDefaultsKey)
        }
    }

    // Story 7.4 AC4 Task 1.1: Confirmation dialogs toggle with UserDefaults persistence
    // Defaults to true (confirmations enabled for safety)
    @Published var requireConfirmationDialogs: Bool {
        didSet {
            UserDefaults.standard.set(requireConfirmationDialogs, forKey: Self.confirmationDialogsKey)
        }
    }

    // Story 10.1 Task 1.1: Fatigue mode toggle with UserDefaults persistence
    // Defaults to false (fatigue mode disabled by default)
    @Published var isFatigueModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isFatigueModeEnabled, forKey: Self.fatigueModeKey)
        }
    }

    // Story 7.1 Task 1.4: UserDefaults key constant
    private static let userDefaultsKey = "enhanced_accessibility_enabled"
    // Story 7.4 Task 1.3: UserDefaults key for confirmation dialogs
    private static let confirmationDialogsKey = "confirmation_dialogs_enabled"
    // Story 10.1 Task 1.2: UserDefaults key for fatigue mode
    private static let fatigueModeKey = "fatigue_mode_enabled"

    // Story 7.1 Task 1.5: Load persisted state on initialization
    // Story 7.4 Task 1.2: Load confirmation dialogs setting (default to true)
    // Story 10.1 Task 1.3: Load fatigue mode setting (default to false)
    init() {
        self.isEnhancedModeEnabled = UserDefaults.standard.bool(forKey: Self.userDefaultsKey)
        // Story 7.4: Use object(forKey:) as? Bool ?? true to default to true when key doesn't exist
        // (bool(forKey:) would return false for missing key)
        self.requireConfirmationDialogs = UserDefaults.standard.object(forKey: Self.confirmationDialogsKey) as? Bool ?? true
        // Story 10.1: bool(forKey:) returns false for missing key, which is our desired default
        self.isFatigueModeEnabled = UserDefaults.standard.bool(forKey: Self.fatigueModeKey)
    }

    // MARK: - Story 7.2: Conditional Touch Target Sizes

    /// Story 7.2 AC1: Keyword chip height (80pt enhanced, 60pt standard)
    var chipHeight: CGFloat {
        isEnhancedModeEnabled ? 80 : 60
    }

    /// Story 7.2 AC2, AC4: Standard button height (80pt enhanced, 60pt standard)
    var buttonHeight: CGFloat {
        isEnhancedModeEnabled ? 80 : 60
    }

    /// Story 7.2 AC3: Header button size (60pt enhanced, 44pt standard)
    var headerButtonSize: CGFloat {
        isEnhancedModeEnabled ? 60 : 44
    }

    /// Story 7.2 AC4: Primary PARLER button height (100pt enhanced, 80pt standard)
    var primaryButtonHeight: CGFloat {
        isEnhancedModeEnabled ? 100 : 80
    }

    /// Story 7.2 AC4: Tertiary button height (60pt enhanced, 50pt standard)
    var tertiaryButtonHeight: CGFloat {
        isEnhancedModeEnabled ? 60 : 50
    }

    /// Story 10.1 AC1, AC3: Fatigue mode button height (80pt enhanced, 60pt standard)
    /// Distinct from tertiaryButtonHeight to meet specific AC requirements
    var fatigueModeButtonHeight: CGFloat {
        isEnhancedModeEnabled ? 80 : 60
    }

    /// Story 7.2 AC2: Modal button height (120pt enhanced, 100pt standard)
    var modalButtonHeight: CGFloat {
        isEnhancedModeEnabled ? 120 : 100
    }

    /// Story 7.2 AC3: Card padding for suggestion cards (16pt enhanced, 12pt standard)
    /// L1 Fix (Code Review): Extracted from magic numbers in SuggestionCard
    var cardPadding: CGFloat {
        isEnhancedModeEnabled ? 16 : 12
    }

    // MARK: - Story 7.3: High Contrast and Reduced Animations

    /// Story 7.3 AC1: Secondary text opacity (0.8 enhanced, 0.6 standard)
    /// Used for secondary/hint text to improve readability in enhanced mode
    var secondaryTextOpacity: Double {
        isEnhancedModeEnabled ? 0.8 : 0.6
    }

    /// Story 7.3 AC2: Scale animation amount (0.98 enhanced/minimal, 0.95 standard)
    /// Reduces visual motion for users with motion sensitivity
    var scaleAnimationAmount: CGFloat {
        isEnhancedModeEnabled ? 0.98 : 0.95
    }

    /// Story 7.3 AC2: Animation duration (0.1s enhanced/faster, 0.2s standard)
    /// Shorter animations reduce visual distraction
    var animationDuration: Double {
        isEnhancedModeEnabled ? 0.1 : 0.2
    }

    /// Story 7.3 AC3: Whether to reduce/disable motion animations
    /// True when Enhanced mode is enabled (pulsing animations disabled)
    /// Note: Views should also check @Environment(\.accessibilityReduceMotion) for AC4
    var shouldReduceMotion: Bool {
        isEnhancedModeEnabled
    }

}
