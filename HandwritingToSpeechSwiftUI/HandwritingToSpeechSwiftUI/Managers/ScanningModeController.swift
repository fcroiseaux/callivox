//
//  ScanningModeController.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.3: Scanning Mode Controller
//  Story 11.4: Added sound feedback and scan direction support
//  Runtime state machine managing the active scan cycle across views.
//  Coordinates highlighting, selection, and pause/resume behavior.
//

import SwiftUI
import UIKit
// Story 11.4 Task 2.1: Import AudioToolbox for sound feedback
import AudioToolbox

// MARK: - Task 2.1, 2.2: ScanningModeController

/// Story 11.3: Runtime controller for scanning mode state management
/// Manages the active scan cycle: highlighting, selection, pause, resume
@MainActor
class ScanningModeController: ObservableObject {

    // Task 2.2: Singleton instance
    static let shared = ScanningModeController()

    // MARK: - Task 2.3, 2.4, 2.5: Published State Properties

    /// Task 2.3: Currently highlighted button index (nil when paused or stopped)
    @Published var currentHighlightedIndex: Int?

    /// Task 2.4: Whether scanning is actively running
    @Published var isScanning: Bool = false

    /// Task 2.5: Whether scanning is paused (after full cycle with autoRestart = false)
    @Published var isPaused: Bool = false

    // MARK: - Task 2.6, 2.7: Private State

    /// Task 2.6: Timer for cycling through buttons
    private var scanTimer: Timer?

    /// Task 2.7: Total number of scannable items in current group
    private var itemCount: Int = 0

    /// Tracks whether a full cycle has completed (for AC4 pause behavior)
    private var cycleCompleted: Bool = false

    /// Debounce flag to prevent rapid double-selection
    private var isSelectionInProgress: Bool = false

    /// Story 11.4 Task 3.1: Direction for forward/backward scanning (1 = forward, -1 = backward)
    private var direction: Int = 1

    // MARK: - Settings Reference

    /// Reference to settings (computed to always get latest values)
    private var settings: ScanningModeSettings { ScanningModeSettings.shared }

    // MARK: - Haptic Generators (L1 learning: prepare for optimal timing)

    private let highlightHaptic = UIImpactFeedbackGenerator(style: .light)
    private let selectionHaptic = UIImpactFeedbackGenerator(style: .medium)

    // MARK: - Initialization

    init() {
        // Prepare haptic generators
        highlightHaptic.prepare()
        selectionHaptic.prepare()
    }

    // MARK: - Task 2.8: Start Scanning

    /// Story 11.3 AC2: Begin scanning a button group
    /// - Parameter itemCount: Number of items to scan through
    func startScanning(itemCount: Int) {
        // Edge case: Don't start if disabled or no items
        guard settings.isEnabled, itemCount > 0 else { return }

        // Stop any existing scan first
        stopScanningInternal()

        self.itemCount = itemCount
        currentHighlightedIndex = 0
        isScanning = true
        isPaused = false
        cycleCompleted = false
        isSelectionInProgress = false
        // Story 11.4 Task 3: Always start scanning in forward direction
        direction = 1

        // VoiceOver announcement (L1 learning: delay for timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Mode scanning actif")
        }

        startTimer()
    }

    // MARK: - Task 2.9: Stop Scanning

    /// Story 11.3: Stop scanning and reset state
    func stopScanning() {
        stopScanningInternal()

        // VoiceOver announcement
        if UIAccessibility.isVoiceOverRunning {
            UIAccessibility.post(notification: .announcement, argument: "Mode scanning arrêté")
        }
    }

    /// Internal stop without VoiceOver (for restarts)
    private func stopScanningInternal() {
        scanTimer?.invalidate()
        scanTimer = nil
        currentHighlightedIndex = nil
        isScanning = false
        isPaused = false
        cycleCompleted = false
        isSelectionInProgress = false
    }

    // MARK: - Task 2.10: Select Current Item

    /// Story 11.3 AC3: Select the currently highlighted item
    /// - Returns: The index of the selected item, or nil if no selection possible
    func selectCurrentItem() -> Int? {
        // Prevent double-selection (edge case: rapid taps)
        guard !isSelectionInProgress else { return nil }
        guard isScanning, let index = currentHighlightedIndex else { return nil }

        isSelectionInProgress = true

        // AC3: Medium haptic feedback on selection
        selectionHaptic.impactOccurred()

        // Brief pause before resuming
        scanTimer?.invalidate()

        // AC3: Resume scanning after 0.5s delay, advancing to next item
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, self.isScanning else { return }
            self.isSelectionInProgress = false

            // Advance to next item
            let nextIndex = (index + 1) % self.itemCount
            self.currentHighlightedIndex = nextIndex
            self.startTimer()
        }

        return index
    }

    // MARK: - Task 2.11: Resume Scanning

    /// Story 11.3 AC4: Resume scanning after pause
    func resumeScanning() {
        guard isPaused else { return }

        isPaused = false
        cycleCompleted = false
        currentHighlightedIndex = 0

        // VoiceOver announcement
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Scanning repris")
        }

        startTimer()
    }

    // MARK: - Story 11.4 Task 2.2: Sound Feedback

    /// Story 11.4 AC3: Play subtle audio cue on highlight change
    private func playHighlightSound() {
        // Task 2.4: Don't play sound during VoiceOver (VoiceOver handles its own audio)
        guard !UIAccessibility.isVoiceOverRunning else { return }
        // Task 2.3: Only play if sound feedback is enabled
        guard settings.soundFeedbackEnabled else { return }

        // M4 Fix: SystemSoundID 1057 = "Tink" - more distinct than "Tock" (1103)
        // Better for accessibility users who rely on audio feedback
        AudioServicesPlaySystemSound(1057)
    }

    // MARK: - Task 2.12: Advance Highlight (Story 11.3 + 11.4 direction support)

    /// Story 11.3 AC2, Story 11.4 AC1: Timer-based advancement through buttons with direction support
    private func advanceHighlight() {
        guard isScanning, !isPaused, let current = currentHighlightedIndex else { return }

        // Story 11.4 Task 3.2: Calculate next position based on direction
        let next = current + direction

        switch settings.scanDirection {
        case .forwardOnly:
            // Story 11.3 original behavior: wrap around at end
            if next >= itemCount {
                if settings.autoRestart {
                    currentHighlightedIndex = 0
                    provideFeedback()
                } else {
                    pauseAfterCycle()
                }
            } else if next < 0 {
                // Edge case: if somehow going backward in forwardOnly, wrap to end
                currentHighlightedIndex = itemCount - 1
                provideFeedback()
            } else {
                currentHighlightedIndex = next
                provideFeedback()
            }

        case .forwardAndBackward:
            // Story 11.4 Task 3.3, 3.4: Reverse direction at boundaries
            if next >= itemCount {
                // Hit the end going forward
                direction = -1  // Start going backward
                // Edge case: if only 1 or 2 items, handle gracefully
                if itemCount > 1 {
                    currentHighlightedIndex = itemCount - 2  // Go to second-to-last
                } else {
                    currentHighlightedIndex = 0  // Stay at first item
                }
                provideFeedback()
            } else if next < 0 {
                // Hit the beginning going backward
                if settings.autoRestart {
                    direction = 1  // Start going forward again
                    // Edge case: if only 1 or 2 items, handle gracefully
                    if itemCount > 1 {
                        currentHighlightedIndex = 1  // Go to second item
                    } else {
                        currentHighlightedIndex = 0  // Stay at first item
                    }
                    provideFeedback()
                } else {
                    pauseAfterCycle()
                }
            } else {
                currentHighlightedIndex = next
                provideFeedback()
            }
        }
    }

    /// Provide haptic and sound feedback on highlight change
    private func provideFeedback() {
        highlightHaptic.impactOccurred()
        playHighlightSound()
    }

    /// Pause scanning after completing a full cycle
    private func pauseAfterCycle() {
        cycleCompleted = true
        isPaused = true
        scanTimer?.invalidate()

        // VoiceOver announcement for pause
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Scanning en pause. Tapez pour reprendre.")
        }
    }

    // MARK: - Private Timer Management

    /// Start the scan timer with current speed setting
    /// M2 Fix: Removed redundant Task @MainActor wrapper - class is already @MainActor
    private func startTimer() {
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(
            withTimeInterval: settings.scanSpeed.interval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.advanceHighlight()
            }
        }
    }

    // MARK: - Settings Change Handler

    /// Called when isEnabled changes in settings
    func handleEnabledChange(_ newValue: Bool, itemCount: Int) {
        if newValue {
            startScanning(itemCount: itemCount)
        } else {
            stopScanning()
        }
    }

    // MARK: - Story 11.4 Task 5.4: Test Mode Support

    /// Story 11.4 AC4: Begin scanning for test mode (ignores isEnabled setting)
    /// - Parameter itemCount: Number of items to scan through
    func startScanningForTest(itemCount: Int) {
        // Edge case: Don't start if no items
        guard itemCount > 0 else { return }

        // Stop any existing scan first
        stopScanningInternal()

        self.itemCount = itemCount
        currentHighlightedIndex = 0
        isScanning = true
        isPaused = false
        cycleCompleted = false
        isSelectionInProgress = false
        direction = 1  // Always start forward

        // VoiceOver announcement (L1 learning: delay for timing)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Mode test scanning actif")
        }

        startTimer()
    }
}
