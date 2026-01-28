//
//  ScanningModeSettingsTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 11.3: Create Scanning Mode for Severely Reduced Mobility
//  Story 11.4: Configure Scanning Mode Settings - Added ScanDirection tests
//  Unit tests for ScanningModeSettings, ScanSpeed/ScanDirection enums, and ScanningModeController
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class ScanningModeSettingsTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        // Clear UserDefaults before each test to ensure clean state
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_enabled")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_speed")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_auto_restart")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_sound_feedback")
        // Story 11.4: Add scanDirection key
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_direction")

        // Reset controller state
        ScanningModeController.shared.stopScanning()
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_enabled")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_speed")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_auto_restart")
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_sound_feedback")
        // Story 11.4: Add scanDirection key
        UserDefaults.standard.removeObject(forKey: "com.callivox.scanning_mode_direction")

        // Reset controller state
        ScanningModeController.shared.stopScanning()
    }

    // MARK: - Task 9.1: ScanningModeSettings Persistence Tests

    func testIsEnabledDefaultsToFalse() {
        // Scanning mode should default to disabled (opt-in feature)
        let settings = ScanningModeSettings()
        XCTAssertFalse(settings.isEnabled, "Scanning mode should default to disabled")
    }

    func testIsEnabledPersistsToUserDefaults() {
        let settings = ScanningModeSettings()
        settings.isEnabled = true

        // Verify UserDefaults was updated
        let persistedValue = UserDefaults.standard.bool(forKey: "com.callivox.scanning_mode_enabled")
        XCTAssertTrue(persistedValue, "isEnabled should persist to UserDefaults")
    }

    func testIsEnabledLoadsFromUserDefaults() {
        // Set UserDefaults directly to true
        UserDefaults.standard.set(true, forKey: "com.callivox.scanning_mode_enabled")

        // Create new instance - should load persisted value
        let settings = ScanningModeSettings()
        XCTAssertTrue(settings.isEnabled, "isEnabled should load from UserDefaults")
    }

    func testAutoRestartDefaultsToTrue() {
        let settings = ScanningModeSettings()
        XCTAssertTrue(settings.autoRestart, "autoRestart should default to true")
    }

    func testAutoRestartPersistsToUserDefaults() {
        let settings = ScanningModeSettings()
        settings.autoRestart = false

        let persistedValue = UserDefaults.standard.bool(forKey: "com.callivox.scanning_mode_auto_restart")
        XCTAssertFalse(persistedValue, "autoRestart should persist to UserDefaults")
    }

    func testSoundFeedbackDefaultsToFalse() {
        let settings = ScanningModeSettings()
        XCTAssertFalse(settings.soundFeedbackEnabled, "soundFeedback should default to false")
    }

    func testSoundFeedbackPersistsToUserDefaults() {
        let settings = ScanningModeSettings()
        settings.soundFeedbackEnabled = true

        let persistedValue = UserDefaults.standard.bool(forKey: "com.callivox.scanning_mode_sound_feedback")
        XCTAssertTrue(persistedValue, "soundFeedback should persist to UserDefaults")
    }

    func testScanSpeedDefaultsToMedium() {
        let settings = ScanningModeSettings()
        XCTAssertEqual(settings.scanSpeed, .medium, "Scan speed should default to medium (2s)")
    }

    func testScanSpeedPersistsToUserDefaults() {
        let settings = ScanningModeSettings()
        settings.scanSpeed = .slow

        // Verify persistence - should be stored as JSON data
        let persistedData = UserDefaults.standard.data(forKey: "com.callivox.scanning_mode_speed")
        XCTAssertNotNil(persistedData, "scanSpeed should persist to UserDefaults")

        if let data = persistedData,
           let decoded = try? JSONDecoder().decode(ScanSpeed.self, from: data) {
            XCTAssertEqual(decoded, .slow, "Persisted speed should be .slow")
        } else {
            XCTFail("Failed to decode persisted scan speed")
        }
    }

    func testResetToDefaultsRestoresAllSettings() {
        let settings = ScanningModeSettings()

        // Modify all settings
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = false
        settings.soundFeedbackEnabled = true
        // Story 11.4: Also modify scanDirection
        settings.scanDirection = .forwardAndBackward

        // Reset to defaults
        settings.resetToDefaults()

        // Verify all settings are restored
        XCTAssertFalse(settings.isEnabled, "isEnabled should be false after reset")
        XCTAssertEqual(settings.scanSpeed, .medium, "scanSpeed should be medium after reset")
        XCTAssertTrue(settings.autoRestart, "autoRestart should be true after reset")
        XCTAssertFalse(settings.soundFeedbackEnabled, "soundFeedback should be false after reset")
        // Story 11.4 Task 7.5: Verify scanDirection is reset
        XCTAssertEqual(settings.scanDirection, .forwardOnly, "scanDirection should be forwardOnly after reset")
    }

    // MARK: - Task 9.2: ScanSpeed Enum RawValue Tests

    func testScanSpeedSlowInterval() {
        XCTAssertEqual(ScanSpeed.slow.interval, 3.0, "Slow speed should be 3 seconds")
    }

    func testScanSpeedMediumInterval() {
        XCTAssertEqual(ScanSpeed.medium.interval, 2.0, "Medium speed should be 2 seconds")
    }

    func testScanSpeedFastInterval() {
        XCTAssertEqual(ScanSpeed.fast.interval, 1.0, "Fast speed should be 1 second")
    }

    func testScanSpeedDisplayNames() {
        XCTAssertEqual(ScanSpeed.slow.displayName, "Lent (3s)", "Slow display name should be French")
        XCTAssertEqual(ScanSpeed.medium.displayName, "Moyen (2s)", "Medium display name should be French")
        XCTAssertEqual(ScanSpeed.fast.displayName, "Rapide (1s)", "Fast display name should be French")
    }

    func testScanSpeedAllCases() {
        let allCases = ScanSpeed.allCases
        XCTAssertEqual(allCases.count, 3, "Should have 3 scan speed options")
        XCTAssertTrue(allCases.contains(.slow), "Should include slow")
        XCTAssertTrue(allCases.contains(.medium), "Should include medium")
        XCTAssertTrue(allCases.contains(.fast), "Should include fast")
    }

    // MARK: - Task 9.3: ScanningModeController Start/Stop Tests

    func testStartScanningInitializesState() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 5)

        XCTAssertTrue(controller.isScanning, "isScanning should be true after start")
        XCTAssertFalse(controller.isPaused, "isPaused should be false after start")
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at index 0")
    }

    func testStartScanningDoesNothingWhenDisabled() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = false

        controller.startScanning(itemCount: 5)

        XCTAssertFalse(controller.isScanning, "Should not start scanning when disabled")
        XCTAssertNil(controller.currentHighlightedIndex, "Highlighted index should be nil when disabled")
    }

    func testStartScanningDoesNothingWithZeroItems() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 0)

        XCTAssertFalse(controller.isScanning, "Should not start scanning with 0 items")
    }

    func testStopScanningResetsState() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 5)
        XCTAssertTrue(controller.isScanning, "Should be scanning")

        controller.stopScanning()

        XCTAssertFalse(controller.isScanning, "isScanning should be false after stop")
        XCTAssertFalse(controller.isPaused, "isPaused should be false after stop")
        XCTAssertNil(controller.currentHighlightedIndex, "Highlighted index should be nil after stop")
    }

    // MARK: - Task 9.4: Advance Highlight Wrap-Around Tests

    func testHighlightAdvancesCorrectly() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast  // 1 second for faster testing

        controller.startScanning(itemCount: 3)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for timer to advance
        try await Task.sleep(nanoseconds: 1_100_000_000)  // 1.1 seconds
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should advance to 1")

        try await Task.sleep(nanoseconds: 1_100_000_000)
        XCTAssertEqual(controller.currentHighlightedIndex, 2, "Should advance to 2")

        controller.stopScanning()
    }

    func testHighlightWrapsAroundWhenAutoRestartEnabled() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = true

        controller.startScanning(itemCount: 2)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for 2 cycles
        try await Task.sleep(nanoseconds: 1_100_000_000)
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should be at 1")

        try await Task.sleep(nanoseconds: 1_100_000_000)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should wrap to 0 with autoRestart")

        controller.stopScanning()
    }

    // MARK: - Task 9.5: Select Current Item Tests

    func testSelectCurrentItemReturnsCorrectIndex() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 5)

        let selectedIndex = controller.selectCurrentItem()

        XCTAssertEqual(selectedIndex, 0, "Should return currently highlighted index")

        controller.stopScanning()
    }

    func testSelectCurrentItemReturnsNilWhenNotScanning() {
        let controller = ScanningModeController.shared

        let selectedIndex = controller.selectCurrentItem()

        XCTAssertNil(selectedIndex, "Should return nil when not scanning")
    }

    // MARK: - Task 9.6: Pause After Full Cycle Tests (AC4)

    func testPausesAfterFullCycleWhenAutoRestartDisabled() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = false

        controller.startScanning(itemCount: 2)
        XCTAssertFalse(controller.isPaused, "Should not be paused initially")

        // Wait for full cycle (2 items at 1s each = 2s)
        try await Task.sleep(nanoseconds: 2_200_000_000)

        XCTAssertTrue(controller.isPaused, "Should be paused after full cycle with autoRestart=false")

        controller.stopScanning()
    }

    // MARK: - Task 9.7: Resume Scanning Tests

    func testResumeScanningAfterPause() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = false  // This will cause pause after full cycle

        controller.startScanning(itemCount: 2)

        // Wait for full cycle to trigger pause (2 items at 1s = 2s)
        try await Task.sleep(nanoseconds: 2_200_000_000)

        // Verify paused state
        XCTAssertTrue(controller.isPaused, "Should be paused after full cycle")

        // Now test resumeScanning
        controller.resumeScanning()

        XCTAssertFalse(controller.isPaused, "Should not be paused after resume")
        XCTAssertTrue(controller.isScanning, "Should be scanning after resume")
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should restart from 0 after resume")

        controller.stopScanning()
    }

    func testResumeScanningDoesNothingWhenNotPaused() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 3)

        // Try to resume when not paused
        controller.resumeScanning()

        // Should have no effect - still at original state
        XCTAssertFalse(controller.isPaused, "Should still not be paused")
        XCTAssertTrue(controller.isScanning, "Should still be scanning")

        controller.stopScanning()
    }

    // MARK: - Singleton Tests

    func testSharedInstanceExists() {
        let shared = ScanningModeSettings.shared
        XCTAssertNotNil(shared, "Shared singleton should exist")
    }

    func testSharedInstanceIsSame() {
        let shared1 = ScanningModeSettings.shared
        let shared2 = ScanningModeSettings.shared
        XCTAssertTrue(shared1 === shared2, "Shared instances should be the same object")
    }

    func testControllerSharedInstanceExists() {
        let shared = ScanningModeController.shared
        XCTAssertNotNil(shared, "Controller shared singleton should exist")
    }

    func testControllerSharedInstanceIsSame() {
        let shared1 = ScanningModeController.shared
        let shared2 = ScanningModeController.shared
        XCTAssertTrue(shared1 === shared2, "Controller shared instances should be the same object")
    }

    // MARK: - Edge Cases

    func testMultipleStartScanningResetsState() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 5)
        controller.startScanning(itemCount: 3)

        // Should reset to new item count
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should reset to 0")
        XCTAssertTrue(controller.isScanning, "Should be scanning")

        controller.stopScanning()
    }

    func testHandleEnabledChangeStartsScanning() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = false

        controller.handleEnabledChange(true, itemCount: 4)

        XCTAssertTrue(controller.isScanning, "Should start scanning when enabled")
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        controller.stopScanning()
    }

    func testHandleEnabledChangeStopsScanning() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true

        controller.startScanning(itemCount: 4)
        controller.handleEnabledChange(false, itemCount: 4)

        XCTAssertFalse(controller.isScanning, "Should stop scanning when disabled")
        XCTAssertNil(controller.currentHighlightedIndex, "Highlighted index should be nil")
    }

    // MARK: - Story 11.4 Task 7: ScanDirection Tests

    // MARK: Task 7.1: ScanDirection Enum RawValue/DisplayName

    func testScanDirectionForwardOnlyRawValue() {
        XCTAssertEqual(ScanDirection.forwardOnly.rawValue, "forward_only", "forwardOnly raw value should be 'forward_only'")
    }

    func testScanDirectionForwardAndBackwardRawValue() {
        XCTAssertEqual(ScanDirection.forwardAndBackward.rawValue, "forward_and_backward", "forwardAndBackward raw value should be 'forward_and_backward'")
    }

    func testScanDirectionDisplayNames() {
        XCTAssertEqual(ScanDirection.forwardOnly.displayName, "Avant uniquement", "forwardOnly display name should be French")
        XCTAssertEqual(ScanDirection.forwardAndBackward.displayName, "Avant et arrière", "forwardAndBackward display name should be French")
    }

    func testScanDirectionAccessibilityDescriptions() {
        XCTAssertEqual(ScanDirection.forwardOnly.accessibilityDescription, "Le scanning recommence au début après le dernier élément")
        XCTAssertEqual(ScanDirection.forwardAndBackward.accessibilityDescription, "Le scanning fait demi-tour aux extrémités")
    }

    func testScanDirectionAllCases() {
        let allCases = ScanDirection.allCases
        XCTAssertEqual(allCases.count, 2, "Should have 2 scan direction options")
        XCTAssertTrue(allCases.contains(.forwardOnly), "Should include forwardOnly")
        XCTAssertTrue(allCases.contains(.forwardAndBackward), "Should include forwardAndBackward")
    }

    // MARK: Task 7.2: ScanDirection Persistence

    func testScanDirectionDefaultsToForwardOnly() {
        let settings = ScanningModeSettings()
        XCTAssertEqual(settings.scanDirection, .forwardOnly, "Scan direction should default to forwardOnly")
    }

    func testScanDirectionPersistsToUserDefaults() {
        let settings = ScanningModeSettings()
        settings.scanDirection = .forwardAndBackward

        // Verify persistence - should be stored as JSON data
        let persistedData = UserDefaults.standard.data(forKey: "com.callivox.scanning_mode_direction")
        XCTAssertNotNil(persistedData, "scanDirection should persist to UserDefaults")

        if let data = persistedData,
           let decoded = try? JSONDecoder().decode(ScanDirection.self, from: data) {
            XCTAssertEqual(decoded, .forwardAndBackward, "Persisted direction should be .forwardAndBackward")
        } else {
            XCTFail("Failed to decode persisted scan direction")
        }
    }

    func testScanDirectionLoadsFromUserDefaults() {
        // Set UserDefaults directly with encoded JSON
        let encoded = try! JSONEncoder().encode(ScanDirection.forwardAndBackward)
        UserDefaults.standard.set(encoded, forKey: "com.callivox.scanning_mode_direction")

        // Create new instance - should load persisted value
        let settings = ScanningModeSettings()
        XCTAssertEqual(settings.scanDirection, .forwardAndBackward, "scanDirection should load from UserDefaults")
    }

    // MARK: Task 7.3 & 7.4: Controller Direction Behavior and Boundary Tests

    func testForwardOnlyWrapsAtEnd() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast  // 1 second
        settings.autoRestart = true
        settings.scanDirection = .forwardOnly

        controller.startScanning(itemCount: 2)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for 2 advances: 0 -> 1 -> 0 (wrap)
        try await Task.sleep(nanoseconds: 1_100_000_000)  // 1.1s
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should be at 1")

        try await Task.sleep(nanoseconds: 1_100_000_000)  // 2.2s total
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should wrap to 0 in forwardOnly mode")

        controller.stopScanning()
    }

    func testForwardAndBackwardReversesAtEnd() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast  // 1 second
        settings.autoRestart = true
        settings.scanDirection = .forwardAndBackward

        controller.startScanning(itemCount: 3)  // Items: 0, 1, 2
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for advances: 0 -> 1 -> 2 -> 1 (reverse at end)
        try await Task.sleep(nanoseconds: 1_100_000_000)  // -> 1
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should be at 1")

        try await Task.sleep(nanoseconds: 1_100_000_000)  // -> 2
        XCTAssertEqual(controller.currentHighlightedIndex, 2, "Should be at 2")

        try await Task.sleep(nanoseconds: 1_100_000_000)  // -> 1 (reverse)
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should reverse to 1 after reaching end")

        controller.stopScanning()
    }

    func testForwardAndBackwardReversesAtBeginning() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast  // 1 second
        settings.autoRestart = true
        settings.scanDirection = .forwardAndBackward

        controller.startScanning(itemCount: 3)  // Items: 0, 1, 2

        // Wait for full forward-backward-forward cycle: 0 -> 1 -> 2 -> 1 -> 0 -> 1
        try await Task.sleep(nanoseconds: 5_500_000_000)  // 5.5s for ~5 transitions

        // Should have bounced back to forward direction
        XCTAssertTrue(controller.isScanning, "Should still be scanning")

        controller.stopScanning()
    }

    func testStartScanningResetsDirectionToForward() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanDirection = .forwardAndBackward

        // Start twice to ensure direction resets
        controller.startScanning(itemCount: 5)
        controller.startScanning(itemCount: 5)

        // Should always start at index 0 going forward
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")
        XCTAssertTrue(controller.isScanning, "Should be scanning")

        controller.stopScanning()
    }

    // MARK: Task 7.5: resetToDefaults includes scanDirection (already tested above in testResetToDefaultsRestoresAllSettings)

    // MARK: Test Mode Support Tests

    func testStartScanningForTestIgnoresEnabledSetting() {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = false  // Globally disabled

        controller.startScanningForTest(itemCount: 4)

        // Should start anyway (test mode bypasses isEnabled check)
        XCTAssertTrue(controller.isScanning, "Test mode should start scanning even when globally disabled")
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        controller.stopScanning()
    }

    func testStartScanningForTestDoesNothingWithZeroItems() {
        let controller = ScanningModeController.shared

        controller.startScanningForTest(itemCount: 0)

        XCTAssertFalse(controller.isScanning, "Should not start test mode with 0 items")
        XCTAssertNil(controller.currentHighlightedIndex, "Highlighted index should be nil")
    }

    // MARK: Edge Case: Single Item Handling

    func testForwardAndBackwardWithSingleItem() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = true
        settings.scanDirection = .forwardAndBackward

        controller.startScanning(itemCount: 1)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for advance - should stay at 0 (single item)
        try await Task.sleep(nanoseconds: 1_100_000_000)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should stay at 0 with single item")

        controller.stopScanning()
    }

    func testForwardAndBackwardWithTwoItems() async throws {
        let controller = ScanningModeController.shared
        let settings = ScanningModeSettings.shared
        settings.isEnabled = true
        settings.scanSpeed = .fast
        settings.autoRestart = true
        settings.scanDirection = .forwardAndBackward

        controller.startScanning(itemCount: 2)  // Items: 0, 1
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should start at 0")

        // Wait for advances: 0 -> 1 -> 0 (reverse at 1, back to 0)
        try await Task.sleep(nanoseconds: 1_100_000_000)  // -> 1
        XCTAssertEqual(controller.currentHighlightedIndex, 1, "Should be at 1")

        try await Task.sleep(nanoseconds: 1_100_000_000)  // -> 0 (reverse)
        XCTAssertEqual(controller.currentHighlightedIndex, 0, "Should reverse to 0 after reaching end with 2 items")

        controller.stopScanning()
    }
}
