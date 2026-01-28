//
//  TimeBasedPhraseSettingsTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 11.1: Implement Time-Based Predictive Phrases
//  Story 11.2: Time-Based Phrase Customization
//  Unit tests for TimeBasedPhraseSettings and TimePeriod
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class TimeBasedPhraseSettingsTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        // Clear UserDefaults before each test to ensure clean state
        UserDefaults.standard.removeObject(forKey: "com.callivox.time_based_phrases_enabled")
        // Story 11.2: Clear custom phrases
        UserDefaults.standard.removeObject(forKey: "com.callivox.time_based_custom_phrases")
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "com.callivox.time_based_phrases_enabled")
        // Story 11.2: Clear custom phrases
        UserDefaults.standard.removeObject(forKey: "com.callivox.time_based_custom_phrases")
    }

    // MARK: - Story 11.1 Task 1.6: isEnabled Toggle Tests

    func testIsEnabledDefaultsToTrue() {
        // New feature should default to enabled for discovery
        let settings = TimeBasedPhraseSettings()
        XCTAssertTrue(settings.isEnabled, "Time-based phrases should default to enabled for new feature discovery")
    }

    func testIsEnabledPersistsToUserDefaults() {
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = false

        // Verify UserDefaults was updated
        let persistedValue = UserDefaults.standard.bool(forKey: "com.callivox.time_based_phrases_enabled")
        XCTAssertFalse(persistedValue, "isEnabled should persist to UserDefaults")
    }

    func testIsEnabledLoadsFromUserDefaults() {
        // Set UserDefaults directly to false
        UserDefaults.standard.set(false, forKey: "com.callivox.time_based_phrases_enabled")

        // Create new instance - should load persisted value
        let settings = TimeBasedPhraseSettings()
        XCTAssertFalse(settings.isEnabled, "isEnabled should load from UserDefaults")
    }

    func testIsEnabledTogglePersistence() {
        let settings = TimeBasedPhraseSettings()

        // Toggle off
        settings.isEnabled = false
        XCTAssertFalse(UserDefaults.standard.object(forKey: "com.callivox.time_based_phrases_enabled") as? Bool ?? true)

        // Toggle on
        settings.isEnabled = true
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "com.callivox.time_based_phrases_enabled"))
    }

    // MARK: - Story 11.1 Task 1.2: TimePeriod Enum Tests

    func testTimePeriodMorningHourRange() {
        // AC2: Morning is 7h-9h
        XCTAssertEqual(TimePeriod.morning.hourRange, 7...8, "Morning hour range should be 7-8 (7h00-8h59)")
    }

    func testTimePeriodLunchHourRange() {
        // AC3: Lunch is 12h-14h
        XCTAssertEqual(TimePeriod.lunch.hourRange, 12...13, "Lunch hour range should be 12-13 (12h00-13h59)")
    }

    func testTimePeriodEveningHourRange() {
        // AC4: Evening is 18h-20h
        XCTAssertEqual(TimePeriod.evening.hourRange, 18...19, "Evening hour range should be 18-19 (18h00-19h59)")
    }

    func testTimePeriodNightHourRange() {
        // AC5: Night is 21h-23h
        XCTAssertEqual(TimePeriod.night.hourRange, 21...22, "Night hour range should be 21-22 (21h00-22h59)")
    }

    func testTimePeriodNoneHasNoRange() {
        XCTAssertNil(TimePeriod.none.hourRange, "None period should have no hour range")
    }

    func testTimePeriodDisplayNames() {
        XCTAssertEqual(TimePeriod.morning.displayName, "Matin")
        XCTAssertEqual(TimePeriod.lunch.displayName, "Midi")
        XCTAssertEqual(TimePeriod.evening.displayName, "Soir")
        XCTAssertEqual(TimePeriod.night.displayName, "Nuit")
        XCTAssertEqual(TimePeriod.none.displayName, "")
    }

    func testTimePeriodIcons() {
        XCTAssertEqual(TimePeriod.morning.icon, "sunrise.fill")
        XCTAssertEqual(TimePeriod.lunch.icon, "sun.max.fill")
        XCTAssertEqual(TimePeriod.evening.icon, "sunset.fill")
        XCTAssertEqual(TimePeriod.night.icon, "moon.stars.fill")
        XCTAssertEqual(TimePeriod.none.icon, "clock")
    }

    // MARK: - Story 11.1 Task 1.4: Period Detection Tests

    func testPeriodForHour7IsMorning() {
        XCTAssertEqual(TimePeriod.period(for: 7), .morning, "Hour 7 should be morning")
    }

    func testPeriodForHour8IsMorning() {
        XCTAssertEqual(TimePeriod.period(for: 8), .morning, "Hour 8 should be morning")
    }

    func testPeriodForHour9IsNone() {
        // 9h is outside the 7-8 (7h00-8h59) range
        XCTAssertEqual(TimePeriod.period(for: 9), .none, "Hour 9 should be none (outside morning)")
    }

    func testPeriodForHour12IsLunch() {
        XCTAssertEqual(TimePeriod.period(for: 12), .lunch, "Hour 12 should be lunch")
    }

    func testPeriodForHour13IsLunch() {
        XCTAssertEqual(TimePeriod.period(for: 13), .lunch, "Hour 13 should be lunch")
    }

    func testPeriodForHour14IsNone() {
        XCTAssertEqual(TimePeriod.period(for: 14), .none, "Hour 14 should be none (outside lunch)")
    }

    func testPeriodForHour18IsEvening() {
        XCTAssertEqual(TimePeriod.period(for: 18), .evening, "Hour 18 should be evening")
    }

    func testPeriodForHour19IsEvening() {
        XCTAssertEqual(TimePeriod.period(for: 19), .evening, "Hour 19 should be evening")
    }

    func testPeriodForHour20IsNone() {
        XCTAssertEqual(TimePeriod.period(for: 20), .none, "Hour 20 should be none (outside evening)")
    }

    func testPeriodForHour21IsNight() {
        XCTAssertEqual(TimePeriod.period(for: 21), .night, "Hour 21 should be night")
    }

    func testPeriodForHour22IsNight() {
        XCTAssertEqual(TimePeriod.period(for: 22), .night, "Hour 22 should be night")
    }

    func testPeriodForHour23IsNone() {
        XCTAssertEqual(TimePeriod.period(for: 23), .none, "Hour 23 should be none (outside night)")
    }

    func testPeriodForHour0IsNone() {
        XCTAssertEqual(TimePeriod.period(for: 0), .none, "Midnight should be none")
    }

    func testPeriodForHour15IsNone() {
        XCTAssertEqual(TimePeriod.period(for: 15), .none, "Hour 15 (afternoon) should be none")
    }

    // MARK: - Story 11.1 Task 1.3: Default Phrases Tests

    func testMorningPhrasesExist() {
        // AC2: Morning phrases
        let settings = TimeBasedPhraseSettings()
        let phrases = settings.phrases(for: .morning)

        XCTAssertNotNil(phrases, "Morning phrases should exist")
        XCTAssertEqual(phrases?.count, 4, "Should have 4 morning phrases")
        XCTAssertTrue(phrases?.contains("Bonjour") ?? false, "Should contain 'Bonjour'")
        XCTAssertTrue(phrases?.contains("Café") ?? false, "Should contain 'Café'")
        XCTAssertTrue(phrases?.contains("Médicaments") ?? false, "Should contain 'Médicaments'")
        XCTAssertTrue(phrases?.contains("Petit-déjeuner") ?? false, "Should contain 'Petit-déjeuner'")
    }

    func testLunchPhrasesExist() {
        // AC3: Lunch phrases
        let settings = TimeBasedPhraseSettings()
        let phrases = settings.phrases(for: .lunch)

        XCTAssertNotNil(phrases, "Lunch phrases should exist")
        XCTAssertEqual(phrases?.count, 4, "Should have 4 lunch phrases")
        XCTAssertTrue(phrases?.contains("J'ai faim") ?? false, "Should contain 'J'ai faim'")
        XCTAssertTrue(phrases?.contains("Repas") ?? false, "Should contain 'Repas'")
        XCTAssertTrue(phrases?.contains("Merci") ?? false, "Should contain 'Merci'")
        XCTAssertTrue(phrases?.contains("C'est bon") ?? false, "Should contain 'C'est bon'")
    }

    func testEveningPhrasesExist() {
        // AC4: Evening phrases
        let settings = TimeBasedPhraseSettings()
        let phrases = settings.phrases(for: .evening)

        XCTAssertNotNil(phrases, "Evening phrases should exist")
        XCTAssertEqual(phrases?.count, 4, "Should have 4 evening phrases")
        XCTAssertTrue(phrases?.contains("Dîner") ?? false, "Should contain 'Dîner'")
        XCTAssertTrue(phrases?.contains("Fatigué") ?? false, "Should contain 'Fatigué'")
        XCTAssertTrue(phrases?.contains("Télévision") ?? false, "Should contain 'Télévision'")
        XCTAssertTrue(phrases?.contains("Merci") ?? false, "Should contain 'Merci'")
    }

    func testNightPhrasesExist() {
        // AC5: Night phrases
        let settings = TimeBasedPhraseSettings()
        let phrases = settings.phrases(for: .night)

        XCTAssertNotNil(phrases, "Night phrases should exist")
        XCTAssertEqual(phrases?.count, 4, "Should have 4 night phrases")
        XCTAssertTrue(phrases?.contains("Bonne nuit") ?? false, "Should contain 'Bonne nuit'")
        XCTAssertTrue(phrases?.contains("Lit") ?? false, "Should contain 'Lit'")
        XCTAssertTrue(phrases?.contains("Lumière") ?? false, "Should contain 'Lumière'")
        XCTAssertTrue(phrases?.contains("Toilettes") ?? false, "Should contain 'Toilettes'")
    }

    func testPhrasesForNonePeriodIsNil() {
        let settings = TimeBasedPhraseSettings()
        let phrases = settings.phrases(for: .none)
        XCTAssertNil(phrases, "None period should have no phrases")
    }

    // MARK: - Story 11.1 Task 1.5: phrasesForCurrentPeriod Tests
    // Code Review Fix H1: Made tests deterministic by testing logic directly

    func testPhrasesForSpecificPeriodReturnsNilWhenDisabled() {
        // Code Review Fix H1: Test disabled state with known periods instead of current time
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = true

        // Verify phrases exist when enabled (for a known period)
        let morningPhrases = settings.phrases(for: .morning)
        XCTAssertNotNil(morningPhrases, "Should return phrases for morning when enabled")

        // Now test the isEnabled guard logic
        settings.isEnabled = false

        // The phrases(for:) method doesn't check isEnabled, but phrasesForCurrentPeriod does
        // Test the logic: when disabled, hasPhrasesForCurrentPeriod should be false
        XCTAssertFalse(settings.hasPhrasesForCurrentPeriod, "Should return false when disabled regardless of time")
    }

    func testPhrasesForCurrentPeriodLogicWithKnownPeriods() {
        // Code Review Fix H1: Test the logic deterministically using period(for:) and phrases(for:)
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = true

        // Test that each active hour returns the expected phrases
        let testCases: [(hour: Int, expectedPeriod: TimePeriod)] = [
            (7, .morning), (8, .morning),
            (12, .lunch), (13, .lunch),
            (18, .evening), (19, .evening),
            (21, .night), (22, .night)
        ]

        for testCase in testCases {
            let period = TimePeriod.period(for: testCase.hour)
            XCTAssertEqual(period, testCase.expectedPeriod, "Hour \(testCase.hour) should be \(testCase.expectedPeriod)")

            let phrases = settings.phrases(for: period)
            XCTAssertNotNil(phrases, "Period \(period) should have phrases")
            XCTAssertTrue(phrases!.count >= 3 && phrases!.count <= 4, "Period should have 3-4 phrases")
        }
    }

    func testHasPhrasesForCurrentPeriodReturnsFalseWhenDisabled() {
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = false

        XCTAssertFalse(settings.hasPhrasesForCurrentPeriod, "hasPhrasesForCurrentPeriod should be false when disabled")
    }

    func testPhrasesForNonePeriodReturnsNilEvenWhenEnabled() {
        // Code Review Fix H1: Test that non-active hours return nil
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = true

        let inactiveHours = [0, 1, 2, 3, 4, 5, 6, 9, 10, 11, 14, 15, 16, 17, 20, 23]
        for hour in inactiveHours {
            let period = TimePeriod.period(for: hour)
            XCTAssertEqual(period, .none, "Hour \(hour) should be .none period")

            let phrases = settings.phrases(for: period)
            XCTAssertNil(phrases, "Hour \(hour) (.none period) should have no phrases")
        }
    }

    // MARK: - Edge Cases

    func testAllPhrasesAreFrench() {
        let settings = TimeBasedPhraseSettings()

        // Verify all phrases are in French (no English keywords)
        let allPhrases = [
            settings.phrases(for: .morning) ?? [],
            settings.phrases(for: .lunch) ?? [],
            settings.phrases(for: .evening) ?? [],
            settings.phrases(for: .night) ?? []
        ].flatMap { $0 }

        // Common English words that should NOT appear
        let englishWords = ["Good morning", "Breakfast", "Lunch", "Dinner", "Good night", "Sleep"]

        for englishWord in englishWords {
            XCTAssertFalse(allPhrases.contains(englishWord), "Should not contain English word: \(englishWord)")
        }
    }

    func testEachPeriodHas3To4Phrases() {
        // AC1: 3-4 phrases per period
        let settings = TimeBasedPhraseSettings()

        for period in [TimePeriod.morning, .lunch, .evening, .night] {
            let phrases = settings.phrases(for: period) ?? []
            XCTAssertTrue(
                phrases.count >= 3 && phrases.count <= 4,
                "\(period) should have 3-4 phrases, but has \(phrases.count)"
            )
        }
    }

    // MARK: - Singleton Tests

    func testSharedInstanceExists() {
        let shared = TimeBasedPhraseSettings.shared
        XCTAssertNotNil(shared, "Shared singleton should exist")
    }

    func testSharedInstanceIsSame() {
        let shared1 = TimeBasedPhraseSettings.shared
        let shared2 = TimeBasedPhraseSettings.shared
        XCTAssertTrue(shared1 === shared2, "Shared instances should be the same object")
    }

    // MARK: - Story 11.2 Task 5.1: Custom Phrases Persistence Tests

    func testCustomPhrasesPersistToUserDefaults() {
        // Task 5.1: Test customPhrases persistence to UserDefaults
        let settings = TimeBasedPhraseSettings()
        let customMorningPhrases = ["Bonjour!", "Réveil", "Médicaments du matin"]

        settings.updatePhrases(for: .morning, phrases: customMorningPhrases)

        // Verify data was persisted to UserDefaults
        let persistedData = UserDefaults.standard.data(forKey: "com.callivox.time_based_custom_phrases")
        XCTAssertNotNil(persistedData, "Custom phrases should be persisted to UserDefaults")

        // Decode and verify the content
        if let data = persistedData,
           let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) {
            XCTAssertEqual(decoded["morning"], customMorningPhrases, "Persisted phrases should match")
        } else {
            XCTFail("Failed to decode persisted custom phrases")
        }
    }

    func testCustomPhrasesLoadFromUserDefaults() {
        // Set custom phrases directly in UserDefaults
        let customPhrases = ["morning": ["Test1", "Test2", "Test3"]]
        if let data = try? JSONEncoder().encode(customPhrases) {
            UserDefaults.standard.set(data, forKey: "com.callivox.time_based_custom_phrases")
        }

        // Create new instance - should load persisted custom phrases
        let settings = TimeBasedPhraseSettings()
        let loadedPhrases = settings.phrases(for: .morning)

        XCTAssertEqual(loadedPhrases, ["Test1", "Test2", "Test3"], "Custom phrases should be loaded from UserDefaults")
    }

    // MARK: - Story 11.2 Task 5.2: Add Phrase Limit Tests

    func testAddPhraseRespectsMaximum6Limit() {
        // Task 5.2: Test addPhrase respects 6-phrase limit
        let settings = TimeBasedPhraseSettings()

        // Start with default 4 phrases, add 2 more (should succeed)
        XCTAssertTrue(settings.addPhrase(to: .morning, phrase: "Phrase 5"), "Adding 5th phrase should succeed")
        XCTAssertTrue(settings.addPhrase(to: .morning, phrase: "Phrase 6"), "Adding 6th phrase should succeed")

        // Try to add 7th phrase (should fail)
        XCTAssertFalse(settings.addPhrase(to: .morning, phrase: "Phrase 7"), "Adding 7th phrase should fail")

        // Verify count is 6
        XCTAssertEqual(settings.phraseCount(for: .morning), 6, "Should have exactly 6 phrases")
    }

    func testAddPhraseToNonePeriodFails() {
        let settings = TimeBasedPhraseSettings()
        XCTAssertFalse(settings.addPhrase(to: .none, phrase: "Test"), "Adding phrase to .none period should fail")
    }

    // MARK: - Story 11.2 Task 5.3: Remove Phrase Minimum Tests

    func testRemovePhraseMaintainsMinimum1() {
        // Task 5.3: Test removePhrase maintains minimum 1 phrase
        let settings = TimeBasedPhraseSettings()

        // Set a period with only 1 phrase
        settings.updatePhrases(for: .morning, phrases: ["Only Phrase"])

        // Try to remove the only phrase (should fail)
        XCTAssertFalse(settings.removePhrase(from: .morning, at: 0), "Removing last phrase should fail")

        // Verify phrase still exists
        XCTAssertEqual(settings.phraseCount(for: .morning), 1, "Should still have 1 phrase")
        XCTAssertEqual(settings.phrases(for: .morning)?.first, "Only Phrase", "Original phrase should remain")
    }

    func testRemovePhraseSucceedsWithMultiple() {
        let settings = TimeBasedPhraseSettings()
        settings.updatePhrases(for: .morning, phrases: ["Phrase 1", "Phrase 2", "Phrase 3"])

        // Remove middle phrase
        XCTAssertTrue(settings.removePhrase(from: .morning, at: 1), "Removing phrase should succeed when count > 1")
        XCTAssertEqual(settings.phraseCount(for: .morning), 2, "Should have 2 phrases remaining")
        XCTAssertEqual(settings.phrases(for: .morning), ["Phrase 1", "Phrase 3"], "Correct phrase should be removed")
    }

    func testRemovePhraseFromNonePeriodFails() {
        let settings = TimeBasedPhraseSettings()
        XCTAssertFalse(settings.removePhrase(from: .none, at: 0), "Removing from .none period should fail")
    }

    func testRemovePhraseWithInvalidIndexFails() {
        let settings = TimeBasedPhraseSettings()
        settings.updatePhrases(for: .morning, phrases: ["Phrase 1", "Phrase 2"])

        XCTAssertFalse(settings.removePhrase(from: .morning, at: 5), "Removing at invalid index should fail")
        XCTAssertFalse(settings.removePhrase(from: .morning, at: -1), "Removing at negative index should fail")
    }

    // MARK: - Story 11.2 Task 5.4: Reset to Defaults Tests

    func testResetToDefaultsClearsCustomPhrases() {
        // Task 5.4: Test resetToDefaults clears custom phrases
        let settings = TimeBasedPhraseSettings()

        // Set custom phrases for multiple periods
        settings.updatePhrases(for: .morning, phrases: ["Custom Morning"])
        settings.updatePhrases(for: .lunch, phrases: ["Custom Lunch"])
        settings.updatePhrases(for: .evening, phrases: ["Custom Evening"])

        // Verify custom phrases are set
        XCTAssertTrue(settings.hasCustomPhrases(for: .morning), "Morning should have custom phrases")
        XCTAssertTrue(settings.hasCustomPhrases(for: .lunch), "Lunch should have custom phrases")

        // Reset to defaults
        settings.resetToDefaults()

        // Verify custom phrases are cleared
        XCTAssertFalse(settings.hasCustomPhrases(for: .morning), "Morning should not have custom phrases after reset")
        XCTAssertFalse(settings.hasCustomPhrases(for: .lunch), "Lunch should not have custom phrases after reset")
        XCTAssertFalse(settings.hasCustomPhrases(for: .evening), "Evening should not have custom phrases after reset")

        // Verify UserDefaults is cleared
        let persistedData = UserDefaults.standard.data(forKey: "com.callivox.time_based_custom_phrases")
        XCTAssertNil(persistedData, "UserDefaults should be cleared after reset")

        // Verify default phrases are returned
        let morningPhrases = settings.phrases(for: .morning)
        XCTAssertTrue(morningPhrases?.contains("Bonjour") ?? false, "Should return default phrases after reset")
    }

    // MARK: - Story 11.2 Task 5.5: Custom Over Default Priority Tests

    func testPhrasesForCurrentPeriodReturnsCustomOverDefault() {
        // Task 5.5: Test phrasesForCurrentPeriod returns custom over default
        let settings = TimeBasedPhraseSettings()
        settings.isEnabled = true

        // Set custom phrases for morning
        let customPhrases = ["Custom 1", "Custom 2", "Custom 3"]
        settings.updatePhrases(for: .morning, phrases: customPhrases)

        // Verify custom phrases are returned
        let returnedPhrases = settings.phrases(for: .morning)
        XCTAssertEqual(returnedPhrases, customPhrases, "Custom phrases should take precedence over defaults")
        XCTAssertFalse(returnedPhrases?.contains("Bonjour") ?? true, "Default phrases should not be included")
    }

    func testPhrasesForPeriodReturnsDefaultsWhenNoCustom() {
        let settings = TimeBasedPhraseSettings()

        // Verify defaults are returned when no custom phrases are set
        let phrases = settings.phrases(for: .morning)
        XCTAssertTrue(phrases?.contains("Bonjour") ?? false, "Should return default phrases when no custom")
        XCTAssertTrue(phrases?.contains("Café") ?? false, "Should return default phrases when no custom")
    }

    func testEmptyCustomPhrasesArrayFallsBackToDefaults() {
        let settings = TimeBasedPhraseSettings()

        // Set empty custom phrases (edge case)
        settings.customPhrases["morning"] = []

        // Should fall back to defaults
        let phrases = settings.phrases(for: .morning)
        XCTAssertTrue(phrases?.contains("Bonjour") ?? false, "Empty custom array should fall back to defaults")
    }

    // MARK: - Story 11.2: Additional Edge Case Tests

    func testUpdatePhrasesLimitsTo6() {
        let settings = TimeBasedPhraseSettings()

        // Try to set 10 phrases
        let manyPhrases = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
        settings.updatePhrases(for: .morning, phrases: manyPhrases)

        // Verify only 6 are stored
        XCTAssertEqual(settings.phraseCount(for: .morning), 6, "Update should limit to 6 phrases")
        XCTAssertEqual(settings.phrases(for: .morning), ["1", "2", "3", "4", "5", "6"], "Should keep first 6 phrases")
    }

    func testHasCustomPhrasesForPeriod() {
        let settings = TimeBasedPhraseSettings()

        // Initially no custom phrases
        XCTAssertFalse(settings.hasCustomPhrases(for: .morning), "Should not have custom phrases initially")

        // Set custom phrases
        settings.updatePhrases(for: .morning, phrases: ["Custom"])
        XCTAssertTrue(settings.hasCustomPhrases(for: .morning), "Should have custom phrases after setting")

        // None period should always return false
        XCTAssertFalse(settings.hasCustomPhrases(for: .none), "None period should never have custom phrases")
    }

    func testPhraseCountForPeriod() {
        let settings = TimeBasedPhraseSettings()

        // Default count
        XCTAssertEqual(settings.phraseCount(for: .morning), 4, "Default morning should have 4 phrases")

        // Custom count
        settings.updatePhrases(for: .morning, phrases: ["One", "Two"])
        XCTAssertEqual(settings.phraseCount(for: .morning), 2, "Custom morning should have 2 phrases")

        // None period
        XCTAssertEqual(settings.phraseCount(for: .none), 0, "None period should have 0 phrases")
    }

    // Code Review Fix M1: Updated test to match corrected time range display
    func testTimeRangeDisplayProperty() {
        XCTAssertEqual(TimePeriod.morning.timeRangeDisplay, "7h-8h59")
        XCTAssertEqual(TimePeriod.lunch.timeRangeDisplay, "12h-13h59")
        XCTAssertEqual(TimePeriod.evening.timeRangeDisplay, "18h-19h59")
        XCTAssertEqual(TimePeriod.night.timeRangeDisplay, "21h-22h59")
        XCTAssertEqual(TimePeriod.none.timeRangeDisplay, "")
    }

    // MARK: - Code Review Fix M4: Missing Test for updatePhrases with .none

    func testUpdatePhrasesForNonePeriodDoesNothing() {
        let settings = TimeBasedPhraseSettings()

        // Try to update .none period
        settings.updatePhrases(for: .none, phrases: ["Test Phrase"])

        // Verify nothing was stored
        XCTAssertNil(settings.phrases(for: .none), "updatePhrases for .none should do nothing")
        XCTAssertFalse(settings.hasCustomPhrases(for: .none), "Should not have custom phrases for .none")
    }
}
