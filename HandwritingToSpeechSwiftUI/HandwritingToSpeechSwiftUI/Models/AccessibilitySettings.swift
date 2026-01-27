//
//  AccessibilitySettings.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 7.1: Accessibility Settings Model (AC3, AC4)
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

    // Story 7.1 Task 1.4: UserDefaults key constant
    private static let userDefaultsKey = "enhanced_accessibility_enabled"

    // Story 7.1 Task 1.5: Load persisted state on initialization
    init() {
        self.isEnhancedModeEnabled = UserDefaults.standard.bool(forKey: Self.userDefaultsKey)
    }

    // MARK: - Future Enhancement Properties (Stories 7.2, 7.3, 7.4)
    // These computed properties will be used in subsequent stories:
    // Story 7.2: var touchTargetSize: CGFloat { isEnhancedModeEnabled ? 80 : 60 }
    // Story 7.3: var useHighContrast: Bool
    // Story 7.3: var useReducedAnimations: Bool
    // Story 7.4: var requireConfirmationDialogs: Bool
}
