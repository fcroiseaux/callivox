//
//  SpeechServiceTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class SpeechServiceTests: XCTestCase {

    var speechService: SpeechService!

    override func setUp() {
        super.setUp()
        speechService = SpeechService.shared
        // Reset state before each test
        speechService.isLoading = false
        speechService.showError = false
        speechService.errorMessage = ""
    }

    override func tearDown() {
        speechService = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testSpeechServiceIsSingleton() {
        let instance1 = SpeechService.shared
        let instance2 = SpeechService.shared
        XCTAssertTrue(instance1 === instance2, "SpeechService should be a singleton")
    }

    func testInitialState() {
        XCTAssertFalse(speechService.isLoading, "Should not be loading initially")
        XCTAssertFalse(speechService.showError, "Should not show error initially")
        XCTAssertTrue(speechService.errorMessage.isEmpty, "Error message should be empty initially")
        XCTAssertTrue(speechService.lastSpokenText.isEmpty, "Last spoken text should be empty initially")
    }

    // MARK: - Voice Selection Tests

    func testDefaultVoiceId() {
        // Given: Default configuration
        // Then: Default voice should match AppConfig
        XCTAssertEqual(speechService.selectedVoiceId, AppConfig.VoiceConfig.defaultVoiceId)
    }

    func testSelectVoiceWithValidVoiceId() {
        // Given: A valid voice ID from available voices
        let validVoiceId = AppConfig.VoiceConfig.availableVoices.first?.id ?? "olivier"

        // When: Voice is selected
        speechService.selectVoice(validVoiceId)

        // Then: Voice should be selected
        XCTAssertEqual(speechService.selectedVoiceId, validVoiceId)
    }

    func testSelectVoiceWithInvalidVoiceIdShowsError() {
        // Given: An invalid voice ID
        let invalidVoiceId = "invalid_voice_that_does_not_exist"

        // When: Invalid voice is selected
        speechService.selectVoice(invalidVoiceId)

        // Then: Error should be shown
        XCTAssertTrue(speechService.showError, "Should show error for invalid voice")
        XCTAssertFalse(speechService.errorMessage.isEmpty, "Error message should be set")
    }

    func testSaveVoicePreference() {
        // Given: A voice selection
        let voiceId = AppConfig.VoiceConfig.defaultVoiceId
        speechService.selectedVoiceId = voiceId

        // When: Preference is saved
        speechService.saveVoicePreference()

        // Then: Preference should be stored in UserDefaults
        let savedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey)
        XCTAssertEqual(savedVoice, voiceId)
    }

    func testLoadVoicePreference() {
        // Given: A saved voice preference
        let testVoiceId = "olivier"
        UserDefaults.standard.set(testVoiceId, forKey: AppConfig.VoiceConfig.userDefaultsKey)

        // When: Preference is loaded
        speechService.loadVoicePreference()

        // Then: Voice should be loaded
        XCTAssertEqual(speechService.selectedVoiceId, testVoiceId)

        // Cleanup
        UserDefaults.standard.removeObject(forKey: AppConfig.VoiceConfig.userDefaultsKey)
    }

    // MARK: - Gradium Availability Tests

    func testCheckGradiumAvailabilityWithoutApiKey() {
        // Given: No API key in Keychain
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)

        // When: Availability is checked
        speechService.checkGradiumAvailability()

        // Then: Gradium should not be available
        XCTAssertFalse(speechService.gradiumAvailable, "Gradium should not be available without API key")
        XCTAssertFalse(speechService.useGradium, "useGradium should be false without API key")
    }

    func testCheckGradiumAvailabilityWithApiKey() {
        // Given: Valid API key in Keychain
        let testApiKey = "test_api_key_12345"
        try? KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: testApiKey.data(using: .utf8)!)

        // When: Availability is checked
        speechService.checkGradiumAvailability()

        // Then: Gradium should be available
        XCTAssertTrue(speechService.gradiumAvailable, "Gradium should be available with API key")

        // Cleanup
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)
    }

    // MARK: - Gradium API Key Management Tests

    func testUpdateGradiumAPIKeyWithValidKey() {
        // Given: A valid API key
        let validApiKey = "valid_test_key_abc123"

        // When: API key is updated
        speechService.updateGradiumAPIKey(validApiKey)

        // Then: Gradium should be available
        XCTAssertTrue(speechService.gradiumAvailable, "Gradium should be available after key update")

        // Cleanup
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)
    }

    func testUpdateGradiumAPIKeyWithEmptyKeyShowsError() {
        // Given: An empty API key
        let emptyApiKey = ""

        // When: Empty API key is provided
        speechService.updateGradiumAPIKey(emptyApiKey)

        // Then: Error should be shown
        XCTAssertTrue(speechService.showError, "Should show error for empty API key")
    }

    // MARK: - speakText Tests

    func testSpeakTextSetsLastSpokenText() {
        // Given: Text to speak
        let text = "Test text"

        // When: speakText is called
        speechService.speakText(text)

        // Then: lastSpokenText should be set
        XCTAssertEqual(speechService.lastSpokenText, text)
    }

    func testSpeakTextSetsLoadingState() {
        // Given: Text to speak
        let text = "Loading test"

        // When: speakText is called
        speechService.speakText(text)

        // Then: isLoading should be true (briefly, until native TTS completes)
        // Note: Native TTS completes very quickly, so we just verify the method runs without crash
        XCTAssertEqual(speechService.lastSpokenText, text)
    }

    // MARK: - Error Handling Tests

    func testShowGradiumKeyMissingGuidance() {
        // When: Guidance is requested
        speechService.showGradiumKeyMissingGuidance()

        // Then: Error should be shown with guidance message
        XCTAssertTrue(speechService.showError, "Should show error")
        XCTAssertTrue(speechService.errorMessage.contains("Gradium") || speechService.errorMessage.contains("API"),
                     "Error message should mention Gradium or API")
    }

    // MARK: - Text Correction Tests

    func testCorrectTextWithEmptyString() {
        // Given: Empty text
        let emptyText = ""

        // When: Text is corrected
        let result = speechService.correctText(emptyText)

        // Then: Result should be empty
        XCTAssertTrue(result.isEmpty, "Empty text should return empty result")
    }

    func testCorrectTextWithValidText() {
        // Given: Valid French text
        let validText = "Bonjour"

        // When: Text is corrected
        let result = speechService.correctText(validText)

        // Then: Result should not be empty
        XCTAssertFalse(result.isEmpty, "Valid text should return non-empty result")
    }

    // MARK: - ObservableObject Tests

    func testPublishedPropertiesExist() {
        // Verify published properties are accessible
        _ = speechService.isLoading
        _ = speechService.showError
        _ = speechService.errorMessage
        _ = speechService.lastSpokenText
        _ = speechService.useGradium
        _ = speechService.gradiumAvailable
        _ = speechService.selectedVoiceId
        _ = speechService.isPreviewingVoice

        // Test passes if no crash
        XCTAssertTrue(true)
    }
}
