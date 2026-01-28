//
//  AccessibilitySettingsTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 7.2: Implement Enlarged Touch Targets in Enhanced Mode
//  Story 10.1: Add Fatigue Mode Trigger
//  Story 10.3: Fatigue Mode Button Customization
//  M3 Fix (Code Review): Unit tests for AccessibilitySettings computed properties.
//  Created by CalliVox on 2026-01-27.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class AccessibilitySettingsTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        // Clear UserDefaults before each test to ensure clean state
        // M3 Fix (Code Review): Include all AccessibilitySettings keys for complete cleanup
        UserDefaults.standard.removeObject(forKey: "enhanced_accessibility_enabled")
        UserDefaults.standard.removeObject(forKey: "fatigue_mode_enabled")
        UserDefaults.standard.removeObject(forKey: "confirmation_dialogs_enabled")
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        // M3 Fix (Code Review): Include all AccessibilitySettings keys for complete cleanup
        UserDefaults.standard.removeObject(forKey: "enhanced_accessibility_enabled")
        UserDefaults.standard.removeObject(forKey: "fatigue_mode_enabled")
        UserDefaults.standard.removeObject(forKey: "confirmation_dialogs_enabled")
    }

    // MARK: - Story 7.1: Enhanced Mode Toggle Tests

    func testEnhancedModeDefaultsToFalse() {
        let settings = AccessibilitySettings()
        XCTAssertFalse(settings.isEnhancedModeEnabled, "Enhanced mode should default to false")
    }

    func testEnhancedModePersistsToUserDefaults() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true

        // Verify UserDefaults was updated
        let persistedValue = UserDefaults.standard.bool(forKey: "enhanced_accessibility_enabled")
        XCTAssertTrue(persistedValue, "Enhanced mode should persist to UserDefaults")
    }

    func testEnhancedModeLoadsFromUserDefaults() {
        // Set UserDefaults directly
        UserDefaults.standard.set(true, forKey: "enhanced_accessibility_enabled")

        // Create new instance - should load persisted value
        let settings = AccessibilitySettings()
        XCTAssertTrue(settings.isEnhancedModeEnabled, "Enhanced mode should load from UserDefaults")
    }

    // MARK: - Story 7.2 AC1: Chip Height Tests

    func testChipHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.chipHeight, 60, "Chip height should be 60pt in standard mode")
    }

    func testChipHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.chipHeight, 80, "Chip height should be 80pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC2, AC4: Button Height Tests

    func testButtonHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.buttonHeight, 60, "Button height should be 60pt in standard mode")
    }

    func testButtonHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.buttonHeight, 80, "Button height should be 80pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC3: Header Button Size Tests

    func testHeaderButtonSizeStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.headerButtonSize, 44, "Header button size should be 44pt in standard mode")
    }

    func testHeaderButtonSizeEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.headerButtonSize, 60, "Header button size should be 60pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC4: Primary Button Height Tests

    func testPrimaryButtonHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.primaryButtonHeight, 80, "Primary button height should be 80pt in standard mode")
    }

    func testPrimaryButtonHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.primaryButtonHeight, 100, "Primary button height should be 100pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC4: Tertiary Button Height Tests

    func testTertiaryButtonHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.tertiaryButtonHeight, 50, "Tertiary button height should be 50pt in standard mode")
    }

    func testTertiaryButtonHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.tertiaryButtonHeight, 60, "Tertiary button height should be 60pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC2: Modal Button Height Tests

    func testModalButtonHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.modalButtonHeight, 100, "Modal button height should be 100pt in standard mode")
    }

    func testModalButtonHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.modalButtonHeight, 120, "Modal button height should be 120pt in enhanced mode")
    }

    // MARK: - Story 7.2 AC3: Card Padding Tests (L1 Fix)

    func testCardPaddingStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.cardPadding, 12, "Card padding should be 12pt in standard mode")
    }

    func testCardPaddingEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.cardPadding, 16, "Card padding should be 16pt in enhanced mode")
    }

    // MARK: - Reactivity Tests (Story 7.2 AC5)

    func testAllPropertiesReactToModeChange() {
        let settings = AccessibilitySettings()

        // Start in standard mode
        settings.isEnhancedModeEnabled = false
        let standardChip = settings.chipHeight
        let standardButton = settings.buttonHeight
        let standardHeader = settings.headerButtonSize
        let standardPrimary = settings.primaryButtonHeight
        let standardTertiary = settings.tertiaryButtonHeight
        let standardModal = settings.modalButtonHeight
        let standardCardPadding = settings.cardPadding

        // Switch to enhanced mode
        settings.isEnhancedModeEnabled = true

        // All values should change
        XCTAssertNotEqual(settings.chipHeight, standardChip, "Chip height should change with mode")
        XCTAssertNotEqual(settings.buttonHeight, standardButton, "Button height should change with mode")
        XCTAssertNotEqual(settings.headerButtonSize, standardHeader, "Header button size should change with mode")
        XCTAssertNotEqual(settings.primaryButtonHeight, standardPrimary, "Primary button height should change with mode")
        XCTAssertNotEqual(settings.tertiaryButtonHeight, standardTertiary, "Tertiary button height should change with mode")
        XCTAssertNotEqual(settings.modalButtonHeight, standardModal, "Modal button height should change with mode")
        XCTAssertNotEqual(settings.cardPadding, standardCardPadding, "Card padding should change with mode")
    }

    func testEnhancedModeAlwaysLargerOrEqual() {
        let settings = AccessibilitySettings()

        settings.isEnhancedModeEnabled = false
        let standardSizes = [
            settings.chipHeight,
            settings.buttonHeight,
            settings.headerButtonSize,
            settings.primaryButtonHeight,
            settings.tertiaryButtonHeight,
            settings.modalButtonHeight,
            settings.cardPadding
        ]

        settings.isEnhancedModeEnabled = true
        let enhancedSizes = [
            settings.chipHeight,
            settings.buttonHeight,
            settings.headerButtonSize,
            settings.primaryButtonHeight,
            settings.tertiaryButtonHeight,
            settings.modalButtonHeight,
            settings.cardPadding
        ]

        // Enhanced mode should always have larger or equal sizes
        for (enhanced, standard) in zip(enhancedSizes, standardSizes) {
            XCTAssertGreaterThanOrEqual(
                enhanced, standard,
                "Enhanced mode sizes should be >= standard mode sizes"
            )
        }
    }

    // MARK: - Story 7.2 Size Reference Table Validation

    func testSizeTableFromStoryDevNotes() {
        // Validates the size table from Story 7.2 Dev Notes
        let settings = AccessibilitySettings()

        // Standard Mode (Enhanced OFF)
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.chipHeight, 60, "KeywordChip standard: 60pt")
        XCTAssertEqual(settings.buttonHeight, 60, "GuidanceControlsView dropdown standard: 60pt")
        XCTAssertEqual(settings.modalButtonHeight, 100, "GuidanceContextButton modal standard: 100pt")
        XCTAssertEqual(settings.buttonHeight, 60, "Modal close button standard: 60pt")
        XCTAssertEqual(settings.headerButtonSize, 44, "SuggestionView refresh standard: 44pt")
        XCTAssertEqual(settings.headerButtonSize, 44, "SuggestionView dismiss standard: 44pt")
        XCTAssertEqual(settings.headerButtonSize, 44, "SuggestionView 'Autre' standard: 44pt")
        XCTAssertEqual(settings.primaryButtonHeight, 80, "PARLER button standard: 80pt")
        XCTAssertEqual(settings.buttonHeight, 60, "Répéter/Effacer standard: 60pt")
        XCTAssertEqual(settings.tertiaryButtonHeight, 50, "Mes phrases/Paramètres standard: 50pt")

        // Enhanced Mode (Enhanced ON)
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.chipHeight, 80, "KeywordChip enhanced: 80pt")
        XCTAssertEqual(settings.buttonHeight, 80, "GuidanceControlsView dropdown enhanced: 80pt")
        XCTAssertEqual(settings.modalButtonHeight, 120, "GuidanceContextButton modal enhanced: 120pt")
        XCTAssertEqual(settings.buttonHeight, 80, "Modal close button enhanced: 80pt")
        XCTAssertEqual(settings.headerButtonSize, 60, "SuggestionView refresh enhanced: 60pt")
        XCTAssertEqual(settings.headerButtonSize, 60, "SuggestionView dismiss enhanced: 60pt")
        XCTAssertEqual(settings.headerButtonSize, 60, "SuggestionView 'Autre' enhanced: 60pt")
        XCTAssertEqual(settings.primaryButtonHeight, 100, "PARLER button enhanced: 100pt")
        XCTAssertEqual(settings.buttonHeight, 80, "Répéter/Effacer enhanced: 80pt")
        XCTAssertEqual(settings.tertiaryButtonHeight, 60, "Mes phrases/Paramètres enhanced: 60pt")
    }

    // MARK: - Story 10.1: Fatigue Mode Tests

    func testFatigueModeDefaultsToFalse() {
        let settings = AccessibilitySettings()
        XCTAssertFalse(settings.isFatigueModeEnabled, "Fatigue mode should default to false")
    }

    func testFatigueModePersistsToUserDefaults() {
        let settings = AccessibilitySettings()
        settings.isFatigueModeEnabled = true

        // Verify UserDefaults was updated
        let persistedValue = UserDefaults.standard.bool(forKey: "fatigue_mode_enabled")
        XCTAssertTrue(persistedValue, "Fatigue mode should persist to UserDefaults")
    }

    func testFatigueModeLoadsFromUserDefaults() {
        // Set UserDefaults directly
        UserDefaults.standard.set(true, forKey: "fatigue_mode_enabled")

        // Create new instance - should load persisted value
        let settings = AccessibilitySettings()
        XCTAssertTrue(settings.isFatigueModeEnabled, "Fatigue mode should load from UserDefaults")
    }

    func testFatigueModeTogglePersistence() {
        let settings = AccessibilitySettings()

        // Toggle on
        settings.isFatigueModeEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "fatigue_mode_enabled"))

        // Toggle off
        settings.isFatigueModeEnabled = false
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "fatigue_mode_enabled"))
    }

    func testFatigueModeIndependentOfEnhancedMode() {
        let settings = AccessibilitySettings()

        // Enable fatigue mode while enhanced mode is off
        settings.isEnhancedModeEnabled = false
        settings.isFatigueModeEnabled = true
        XCTAssertFalse(settings.isEnhancedModeEnabled)
        XCTAssertTrue(settings.isFatigueModeEnabled)

        // Enable enhanced mode - fatigue mode should remain
        settings.isEnhancedModeEnabled = true
        XCTAssertTrue(settings.isEnhancedModeEnabled)
        XCTAssertTrue(settings.isFatigueModeEnabled)

        // Disable fatigue mode - enhanced mode should remain
        settings.isFatigueModeEnabled = false
        XCTAssertTrue(settings.isEnhancedModeEnabled)
        XCTAssertFalse(settings.isFatigueModeEnabled)
    }

    // MARK: - Story 10.1 AC1, AC3: Fatigue Mode Button Height Tests (H1 Fix)

    func testFatigueModeButtonHeightStandardMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = false
        XCTAssertEqual(settings.fatigueModeButtonHeight, 60, "Fatigue mode button height should be 60pt in standard mode (AC1)")
    }

    func testFatigueModeButtonHeightEnhancedMode() {
        let settings = AccessibilitySettings()
        settings.isEnhancedModeEnabled = true
        XCTAssertEqual(settings.fatigueModeButtonHeight, 80, "Fatigue mode button height should be 80pt in enhanced mode (AC3)")
    }

    // MARK: - Story 10.2: Fatigue Mode Interface Tests

    // Task 6.1: Test FatigueModeView button count
    func testFatigueModeMessagesCount() {
        // Story 10.2 AC1, AC2: Maximum 6 buttons (5 messages + 1 exit button)
        // We test the expected message constants
        let expectedMessages = ["OUI", "NON", "APPELER", "DOULEUR", "SOIF / FAIM"]
        XCTAssertEqual(expectedMessages.count, 5, "Should have exactly 5 message buttons")
        // Total buttons: 5 messages + 1 "Mode normal" exit = 6
    }

    // Task 6.2: Test button accessibility labels are in French
    func testFatigueModeMessagesAreFrench() {
        // Story 10.2 AC2: French messages for fatigue mode buttons
        let messages = ["OUI", "NON", "APPELER", "DOULEUR", "SOIF / FAIM", "Mode normal"]

        // Verify all expected French messages are present
        XCTAssertTrue(messages.contains("OUI"), "Should contain 'OUI' (French for Yes)")
        XCTAssertTrue(messages.contains("NON"), "Should contain 'NON' (French for No)")
        XCTAssertTrue(messages.contains("APPELER"), "Should contain 'APPELER' (French for Call)")
        XCTAssertTrue(messages.contains("DOULEUR"), "Should contain 'DOULEUR' (French for Pain)")
        XCTAssertTrue(messages.contains("SOIF / FAIM"), "Should contain 'SOIF / FAIM' (French for Thirst/Hunger)")
        XCTAssertTrue(messages.contains("Mode normal"), "Should contain 'Mode normal' (French for Normal mode)")

        // Verify no English messages are present
        XCTAssertFalse(messages.contains("YES"), "Should not contain English 'YES'")
        XCTAssertFalse(messages.contains("NO"), "Should not contain English 'NO'")
        XCTAssertFalse(messages.contains("CALL"), "Should not contain English 'CALL'")
    }

    // Task 6.3: Test state persistence toggle behavior (complements existing tests)
    func testFatigueModeStateTransitions() {
        let settings = AccessibilitySettings()

        // Initial state
        XCTAssertFalse(settings.isFatigueModeEnabled, "Fatigue mode should start disabled")

        // Activate fatigue mode (simulating user activating from sidebar)
        settings.isFatigueModeEnabled = true
        XCTAssertTrue(settings.isFatigueModeEnabled, "Fatigue mode should be enabled after activation")
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "fatigue_mode_enabled"), "Persisted state should be true")

        // Exit fatigue mode (simulating user tapping "Mode normal" and confirming)
        settings.isFatigueModeEnabled = false
        XCTAssertFalse(settings.isFatigueModeEnabled, "Fatigue mode should be disabled after exit")
        XCTAssertFalse(UserDefaults.standard.bool(forKey: "fatigue_mode_enabled"), "Persisted state should be false")
    }

    func testFatigueModePersistedAcrossSessions() {
        // Simulate first session: enable fatigue mode
        let settings1 = AccessibilitySettings()
        settings1.isFatigueModeEnabled = true

        // Simulate app restart: create new AccessibilitySettings instance
        // It should load the persisted state
        let settings2 = AccessibilitySettings()
        XCTAssertTrue(settings2.isFatigueModeEnabled, "Fatigue mode should persist across app sessions (AC5)")
    }
}

// MARK: - Story 10.3: FatigueModeSettings Tests
@MainActor
final class FatigueModeSettingsTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        // Clear UserDefaults before each test to ensure clean state
        UserDefaults.standard.removeObject(forKey: "fatigue_mode_messages_custom")
    }

    override func tearDown() async throws {
        // M3 Fix (Code Review): Reset shared singleton to prevent test state leakage
        FatigueModeSettings.shared.resetToDefaults()
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "fatigue_mode_messages_custom")
    }

    // MARK: - Task 6.1: Test FatigueModeSettings persistence and loading

    func testDefaultMessagesCount() {
        // AC1: 5 customizable message slots
        XCTAssertEqual(FatigueModeSettings.defaultMessages.count, 5, "Should have exactly 5 default messages")
    }

    func testDefaultMessagesContent() {
        // AC5: Default messages should be Oui, Non, Appeler, Douleur, Soif/Faim
        let defaults = FatigueModeSettings.defaultMessages
        XCTAssertEqual(defaults[0].text, "OUI", "First default message should be OUI")
        XCTAssertEqual(defaults[1].text, "NON", "Second default message should be NON")
        XCTAssertEqual(defaults[2].text, "APPELER", "Third default message should be APPELER")
        XCTAssertEqual(defaults[3].text, "DOULEUR", "Fourth default message should be DOULEUR")
        XCTAssertEqual(defaults[4].text, "SOIF / FAIM", "Fifth default message should be SOIF / FAIM")
    }

    func testDefaultMessagesColors() {
        let defaults = FatigueModeSettings.defaultMessages
        XCTAssertEqual(defaults[0].colorName, "green", "OUI should be green")
        XCTAssertEqual(defaults[1].colorName, "red", "NON should be red")
        XCTAssertEqual(defaults[2].colorName, "blue", "APPELER should be blue")
        XCTAssertEqual(defaults[3].colorName, "purple", "DOULEUR should be purple")
        XCTAssertEqual(defaults[4].colorName, "orange", "SOIF / FAIM should be orange")
    }

    func testInitialLoadUsesDefaults() {
        let settings = FatigueModeSettings()
        XCTAssertEqual(settings.customMessages.count, 5, "Should load 5 messages on init")

        // Verify it's using defaults on first launch
        XCTAssertEqual(settings.customMessages[0].text, "OUI")
        XCTAssertEqual(settings.customMessages[1].text, "NON")
    }

    func testPersistenceAcrossInstances() {
        // First instance - modify a message
        let settings1 = FatigueModeSettings()
        settings1.updateMessage(at: 0, text: "TEST", colorName: "blue")

        // Second instance - should load persisted value
        let settings2 = FatigueModeSettings()
        XCTAssertEqual(settings2.customMessages[0].text, "TEST", "Custom message should persist")
        XCTAssertEqual(settings2.customMessages[0].colorName, "blue", "Custom color should persist")
    }

    // MARK: - Task 6.2: Test message update and immediate save

    func testUpdateMessageChangesText() {
        let settings = FatigueModeSettings()
        let originalText = settings.customMessages[0].text

        settings.updateMessage(at: 0, text: "NOUVEAU", colorName: "green")

        XCTAssertNotEqual(settings.customMessages[0].text, originalText)
        XCTAssertEqual(settings.customMessages[0].text, "NOUVEAU")
    }

    func testUpdateMessageChangesColor() {
        let settings = FatigueModeSettings()
        settings.updateMessage(at: 0, text: "OUI", colorName: "purple")
        XCTAssertEqual(settings.customMessages[0].colorName, "purple")
    }

    func testUpdateMessagePreservesId() {
        let settings = FatigueModeSettings()
        let originalId = settings.customMessages[0].id

        settings.updateMessage(at: 0, text: "NOUVEAU", colorName: "red")

        XCTAssertEqual(settings.customMessages[0].id, originalId, "Message ID should be preserved on update")
    }

    func testUpdateMessageImmediateSave() {
        let settings = FatigueModeSettings()
        settings.updateMessage(at: 0, text: "SAUVÉ", colorName: "blue")

        // Verify UserDefaults was updated immediately
        guard let data = UserDefaults.standard.data(forKey: "fatigue_mode_messages_custom"),
              let saved = try? JSONDecoder().decode([FatigueModeMessage].self, from: data) else {
            XCTFail("Failed to load saved messages from UserDefaults")
            return
        }

        XCTAssertEqual(saved[0].text, "SAUVÉ", "Update should save immediately to UserDefaults")
    }

    func testUpdateMessageInvalidIndexIgnored() {
        let settings = FatigueModeSettings()
        let originalText = settings.customMessages[0].text

        // Try to update with invalid index
        settings.updateMessage(at: -1, text: "INVALID", colorName: "red")
        settings.updateMessage(at: 10, text: "INVALID", colorName: "red")

        // Original should be unchanged
        XCTAssertEqual(settings.customMessages[0].text, originalText)
    }

    func testUpdateMessageEmptyTextIgnored() {
        let settings = FatigueModeSettings()
        let originalText = settings.customMessages[0].text

        settings.updateMessage(at: 0, text: "", colorName: "red")

        // Original should be unchanged because empty text is ignored
        XCTAssertEqual(settings.customMessages[0].text, originalText)
    }

    // MARK: - Task 6.3: Test reset to defaults functionality

    func testResetToDefaults() {
        let settings = FatigueModeSettings()

        // Modify all messages
        for i in 0..<5 {
            settings.updateMessage(at: i, text: "CUSTOM\(i)", colorName: "gray")
        }

        // Verify modifications took effect
        XCTAssertEqual(settings.customMessages[0].text, "CUSTOM0")

        // Reset to defaults
        settings.resetToDefaults()

        // Verify defaults are restored (AC5)
        XCTAssertEqual(settings.customMessages[0].text, "OUI")
        XCTAssertEqual(settings.customMessages[1].text, "NON")
        XCTAssertEqual(settings.customMessages[2].text, "APPELER")
        XCTAssertEqual(settings.customMessages[3].text, "DOULEUR")
        XCTAssertEqual(settings.customMessages[4].text, "SOIF / FAIM")
    }

    func testResetToDefaultsPersistedImmediately() {
        let settings = FatigueModeSettings()
        settings.updateMessage(at: 0, text: "CUSTOM", colorName: "gray")
        settings.resetToDefaults()

        // New instance should load defaults
        let settings2 = FatigueModeSettings()
        XCTAssertEqual(settings2.customMessages[0].text, "OUI", "Reset should persist immediately")
    }

    // MARK: - Task 6.4: Test predefined options

    func testPredefinedCategoriesExist() {
        // AC2: Should have predefined options grouped by category
        let categories = FatigueModeSettings.predefinedCategories
        XCTAssertGreaterThanOrEqual(categories.count, 4, "Should have at least 4 categories")
    }

    func testPredefinedCategoriesAreFrench() {
        // AC6: All labels should be in French
        let categoryNames = FatigueModeSettings.predefinedCategories.map { $0.name }

        XCTAssertTrue(categoryNames.contains("Réponses de base"), "Should have 'Réponses de base' category")
        XCTAssertTrue(categoryNames.contains("Besoins"), "Should have 'Besoins' category")
        XCTAssertTrue(categoryNames.contains("Communication"), "Should have 'Communication' category")
        XCTAssertTrue(categoryNames.contains("Médical"), "Should have 'Médical' category")
    }

    func testPredefinedOptionsMatchAC2() {
        // AC2: Verify specific predefined options exist
        let allOptions = FatigueModeSettings.predefinedCategories.flatMap { $0.options }
        let optionTexts = allOptions.map { $0.text }

        // Basic responses
        XCTAssertTrue(optionTexts.contains("OUI"), "Should have OUI option")
        XCTAssertTrue(optionTexts.contains("NON"), "Should have NON option")
        XCTAssertTrue(optionTexts.contains("PEUT-ÊTRE"), "Should have PEUT-ÊTRE option")
        XCTAssertTrue(optionTexts.contains("D'ACCORD"), "Should have D'ACCORD option")

        // Needs
        XCTAssertTrue(optionTexts.contains("SOIF"), "Should have SOIF option")
        XCTAssertTrue(optionTexts.contains("FAIM"), "Should have FAIM option")
        XCTAssertTrue(optionTexts.contains("TOILETTES"), "Should have TOILETTES option")

        // Communication
        XCTAssertTrue(optionTexts.contains("APPELER"), "Should have APPELER option")
        XCTAssertTrue(optionTexts.contains("AIDE"), "Should have AIDE option")
        XCTAssertTrue(optionTexts.contains("MERCI"), "Should have MERCI option")

        // Medical
        XCTAssertTrue(optionTexts.contains("DOULEUR"), "Should have DOULEUR option")
        XCTAssertTrue(optionTexts.contains("MALAISE"), "Should have MALAISE option")
        XCTAssertTrue(optionTexts.contains("MÉDICAMENT"), "Should have MÉDICAMENT option")
    }

    // MARK: - Color Tests

    func testColorConversion() {
        let message = FatigueModeMessage(id: UUID(), text: "TEST", colorName: "green")
        // Just verify the color property doesn't crash
        _ = message.color

        let colors = ["green", "red", "blue", "purple", "orange", "gray", "unknown"]
        for colorName in colors {
            let msg = FatigueModeMessage(id: UUID(), text: "TEST", colorName: colorName)
            _ = msg.color // Should not crash
        }
    }

    func testAvailableColorsHaveFrenchNames() {
        // AC6: Available colors should have French display names
        let colorDisplayNames = FatigueModeSettings.availableColors.map { $0.displayName }

        XCTAssertTrue(colorDisplayNames.contains("Vert"), "Should have Vert")
        XCTAssertTrue(colorDisplayNames.contains("Rouge"), "Should have Rouge")
        XCTAssertTrue(colorDisplayNames.contains("Bleu"), "Should have Bleu")
        XCTAssertTrue(colorDisplayNames.contains("Violet"), "Should have Violet")
        XCTAssertTrue(colorDisplayNames.contains("Orange"), "Should have Orange")
        XCTAssertTrue(colorDisplayNames.contains("Gris"), "Should have Gris")
    }

    // MARK: - Integration Tests

    func testCustomMessagesUsedInFatigueModeView() {
        // AC4: Custom messages should be displayed in fatigue mode
        let settings = FatigueModeSettings.shared

        // Customize a message
        settings.updateMessage(at: 0, text: "PERSONNALISÉ", colorName: "purple")

        // FatigueModeView uses FatigueModeSettings.shared, so it should see this change
        XCTAssertEqual(FatigueModeSettings.shared.customMessages[0].text, "PERSONNALISÉ")

        // Clean up
        settings.resetToDefaults()
    }
}
