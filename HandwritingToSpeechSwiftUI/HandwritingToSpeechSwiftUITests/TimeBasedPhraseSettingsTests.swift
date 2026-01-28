//
//  TimeBasedPhraseSettingsTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 11.1: Implement Time-Based Predictive Phrases
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
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "com.callivox.time_based_phrases_enabled")
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
}
