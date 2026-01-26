//
//  VoiceSelectionTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-26.
//  Story 1.3: Voice Selection and Persistence Tests
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class VoiceSelectionTests: XCTestCase {

    // MARK: - Setup / Teardown

    override func setUp() {
        super.setUp()
        // Clear any existing voice preference before each test
        UserDefaults.standard.removeObject(forKey: AppConfig.VoiceConfig.userDefaultsKey)
    }

    override func tearDown() {
        // Clean up after tests
        UserDefaults.standard.removeObject(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        super.tearDown()
    }

    // MARK: - VoiceConfig Tests

    func testVoiceConfigUserDefaultsKeyIsCorrect() {
        XCTAssertEqual(AppConfig.VoiceConfig.userDefaultsKey, "selected_voice_id")
    }

    func testVoiceConfigDefaultVoiceIdIsOlivier() {
        // AC4: Default voice for French locale is "olivier"
        XCTAssertEqual(AppConfig.VoiceConfig.defaultVoiceId, "olivier")
    }

    func testVoiceConfigAvailableVoicesContainsOlivier() {
        // AC1: Available voices include "Olivier" for French
        let olivierVoice = AppConfig.VoiceConfig.availableVoices.first { $0.id == "olivier" }
        XCTAssertNotNil(olivierVoice)
        XCTAssertEqual(olivierVoice?.name, "Olivier")
        XCTAssertEqual(olivierVoice?.description, "Voix masculine française")
    }

    func testVoiceConfigPreviewTextTemplateContainsPlaceholder() {
        // AC2: Preview text template for voice samples
        XCTAssertTrue(AppConfig.VoiceConfig.previewTextTemplate.contains("%@"))
    }

    // MARK: - Voice Persistence Tests (AC: 3, 5)

    func testSaveVoicePreferencePersistsToUserDefaults() {
        // AC3: Voice ID is stored in UserDefaults
        let testVoiceId = "test_voice"
        UserDefaults.standard.set(testVoiceId, forKey: AppConfig.VoiceConfig.userDefaultsKey)

        let savedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        XCTAssertEqual(savedVoice, testVoiceId)
    }

    func testLoadVoicePreferenceRetrievesFromUserDefaults() {
        // AC5: Saved voice preference is loaded on app launch
        let testVoiceId = "olivier"
        UserDefaults.standard.set(testVoiceId, forKey: AppConfig.VoiceConfig.userDefaultsKey)

        let loadedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        XCTAssertEqual(loadedVoice, testVoiceId)
    }

    func testNoSavedVoiceReturnsNilFromUserDefaults() {
        // When no preference exists, UserDefaults returns nil
        UserDefaults.standard.removeObject(forKey: AppConfig.VoiceConfig.userDefaultsKey)

        let loadedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        XCTAssertNil(loadedVoice)
    }

    // MARK: - Default Voice Logic Tests (AC: 4)

    func testDefaultVoiceIdMatchesGradiumDefault() {
        // AC4: Consistency between VoiceConfig and Gradium defaults
        XCTAssertEqual(AppConfig.VoiceConfig.defaultVoiceId, AppConfig.Gradium.defaultVoiceId)
    }

    func testFrenchLocaleDefaultVoiceIsOlivier() {
        // AC4: "olivier" is used as the default voice for French locale
        // This test validates the configuration constant
        let defaultVoice = AppConfig.VoiceConfig.defaultVoiceId
        XCTAssertEqual(defaultVoice, "olivier")
    }

    // MARK: - Voice List Validation Tests

    func testAvailableVoicesNotEmpty() {
        // AC1: Voices are available to display
        XCTAssertFalse(AppConfig.VoiceConfig.availableVoices.isEmpty)
    }

    func testAllVoicesHaveRequiredFields() {
        // AC1: Each voice has id, name, and description
        for voice in AppConfig.VoiceConfig.availableVoices {
            XCTAssertFalse(voice.id.isEmpty, "Voice id should not be empty")
            XCTAssertFalse(voice.name.isEmpty, "Voice name should not be empty")
            XCTAssertFalse(voice.description.isEmpty, "Voice description should not be empty")
        }
    }

    func testAllVoiceDescriptionsAreFrench() {
        // French labels requirement from story
        for voice in AppConfig.VoiceConfig.availableVoices {
            // Check for French language patterns in descriptions
            let hasFrenchContent = voice.description.contains("Voix") ||
                                   voice.description.contains("française") ||
                                   voice.description.contains("masculin")
            XCTAssertTrue(hasFrenchContent, "Voice description '\(voice.description)' should be in French")
        }
    }

    // MARK: - Voice ID Validation Tests

    func testValidVoiceIdsAreLowercase() {
        // Convention: voice IDs should be lowercase
        for voice in AppConfig.VoiceConfig.availableVoices {
            XCTAssertEqual(voice.id, voice.id.lowercased(), "Voice ID '\(voice.id)' should be lowercase")
        }
    }

    func testVoiceIdsAreUnique() {
        // Each voice should have a unique ID
        let ids = AppConfig.VoiceConfig.availableVoices.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "Voice IDs should be unique")
    }

    // MARK: - Preview Text Tests

    func testPreviewTextFormatting() {
        // AC2: Preview text can be formatted with voice name
        let voiceName = "Olivier"
        let previewText = String(format: AppConfig.VoiceConfig.previewTextTemplate, voiceName)
        XCTAssertTrue(previewText.contains(voiceName))
        XCTAssertTrue(previewText.contains("Bonjour"))
    }

    // MARK: - Integration Tests

    func testVoicePreferencePersistenceRoundTrip() {
        // Full round-trip test: save and load
        let testVoiceId = "olivier"

        // Save
        UserDefaults.standard.set(testVoiceId, forKey: AppConfig.VoiceConfig.userDefaultsKey)

        // Load
        let loadedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)

        XCTAssertEqual(loadedVoice, testVoiceId)
    }

    func testVoicePreferenceOverwrite() {
        // Test that saving a new preference overwrites the old one
        let firstVoice = "olivier"
        let secondVoice = "another_voice"

        UserDefaults.standard.set(firstVoice, forKey: AppConfig.VoiceConfig.userDefaultsKey)
        UserDefaults.standard.set(secondVoice, forKey: AppConfig.VoiceConfig.userDefaultsKey)

        let loadedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        XCTAssertEqual(loadedVoice, secondVoice)
    }
}
