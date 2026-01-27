//
//  InterlocutorListeningServiceTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Unit tests for InterlocutorListeningService.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class InterlocutorListeningServiceTests: XCTestCase {

    var service: InterlocutorListeningService!

    override func setUp() async throws {
        try await super.setUp()
        service = InterlocutorListeningService.shared
        // Reset state
        service.stopListening()
        service.clearTranscription()
    }

    override func tearDown() async throws {
        service.stopListening()
        service = nil
        try await super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState() {
        // Then: Service should be in default state
        XCTAssertFalse(service.isListening, "Should not be listening initially")
        XCTAssertTrue(service.currentTranscription.isEmpty, "Transcription should be empty initially")
        XCTAssertFalse(service.isProcessingSuggestions, "Should not be processing suggestions initially")
        XCTAssertTrue(service.listeningEnabled, "Listening should be enabled by default")
        XCTAssertFalse(service.showError, "Should not show error initially")
    }

    // MARK: - Toggle Tests

    func testListeningEnabledDefault() {
        // Then: Listening should be enabled by default
        XCTAssertTrue(service.listeningEnabled)
    }

    func testDisableListeningPreventsStart() async {
        // Given: Listening is disabled
        service.listeningEnabled = false

        // When: Attempting to start listening
        await service.startListening()

        // Then: Service should not be listening
        XCTAssertFalse(service.isListening, "Should not start listening when disabled")
    }

    // MARK: - Transcription Tests

    func testClearTranscription() {
        // Given: Some transcription exists (simulated)
        // Note: We can't easily set currentTranscription since it's private(set)
        // This test verifies the method exists and doesn't crash

        // When: Clearing transcription
        service.clearTranscription()

        // Then: Transcription should be empty
        XCTAssertTrue(service.currentTranscription.isEmpty)
    }

    // MARK: - Stop Listening Tests

    func testStopListeningWhenNotListening() {
        // Given: Service is not listening
        XCTAssertFalse(service.isListening)

        // When: Stopping (no-op expected)
        service.stopListening()

        // Then: No error should occur
        XCTAssertFalse(service.isListening)
        XCTAssertFalse(service.showError)
    }

    // MARK: - Error Handling Tests

    func testDismissError() {
        // Given: An error state (simulated by checking public interface)
        // Note: We can't easily trigger an error without network,
        // but we can verify dismissError doesn't crash

        // When: Dismissing error
        service.dismissError()

        // Then: Error should be dismissed
        XCTAssertFalse(service.showError)
        XCTAssertTrue(service.errorMessage.isEmpty)
    }

    // MARK: - VAD Configuration Tests

    func testVADConfigurationValues() {
        // Verify VAD configuration is reasonable
        let threshold = AppConfig.STT.vadInactivityThreshold
        let silenceDuration = AppConfig.STT.silenceDuration

        // Threshold should be between 0 and 1
        XCTAssertTrue(threshold > 0, "VAD threshold should be positive")
        XCTAssertTrue(threshold < 1, "VAD threshold should be less than 1")

        // Silence duration should be reasonable (0.3s - 2s)
        XCTAssertTrue(silenceDuration >= 0.3, "Silence duration should be at least 0.3s")
        XCTAssertTrue(silenceDuration <= 2.0, "Silence duration should be at most 2s")
    }

    // MARK: - Integration Behavior Tests

    func testServiceIsSingleton() {
        // When: Getting the shared instance
        let instance1 = InterlocutorListeningService.shared
        let instance2 = InterlocutorListeningService.shared

        // Then: Both should be the same instance
        XCTAssertTrue(instance1 === instance2, "Should return the same singleton instance")
    }

    func testStopListeningClearsState() {
        // Given: Service might have some state

        // When: Stopping listening
        service.stopListening()

        // Then: State should be cleared
        XCTAssertFalse(service.isListening)
        // Note: isProcessingSuggestions might still be true if suggestions are generating
    }

    // MARK: - STTError Tests

    func testSTTErrorLocalizedDescriptions() {
        // Verify all STT errors have French descriptions
        let errors: [STTError] = [
            .networkUnavailable,
            .connectionFailed(message: "test"),
            .apiError(statusCode: 500, message: "test"),
            .audioCaptureFailed(underlying: NSError(domain: "test", code: 0)),
            .permissionDenied,
            .invalidApiKey,
            .timeout
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription, "Error should have description: \(error)")
            XCTAssertFalse(error.errorDescription!.isEmpty, "Description should not be empty")
        }
    }

    func testSTTErrorRecoverySuggestions() {
        // Verify all STT errors have recovery suggestions
        let errors: [STTError] = [
            .networkUnavailable,
            .connectionFailed(message: "test"),
            .apiError(statusCode: 500, message: "test"),
            .audioCaptureFailed(underlying: NSError(domain: "test", code: 0)),
            .permissionDenied,
            .invalidApiKey,
            .timeout
        ]

        for error in errors {
            XCTAssertNotNil(error.recoverySuggestion, "Error should have recovery suggestion: \(error)")
        }
    }

    func testPermissionDeniedSuggestionMentionsSettings() {
        // Given: Permission denied error
        let error = STTError.permissionDenied

        // Then: Recovery suggestion should mention Settings
        let suggestion = error.recoverySuggestion ?? ""
        XCTAssertTrue(suggestion.contains("Réglages") || suggestion.contains("Paramètres"),
                      "Permission denied should suggest checking Settings")
    }

    // MARK: - Audio Format Tests

    func testAudioChunkSize() {
        // Given: Expected chunk parameters
        let sampleRate = AppConfig.STT.sampleRate
        let chunkSamples = AppConfig.STT.chunkSamples

        // When: Calculating chunk duration
        let chunkDurationMs = (Double(chunkSamples) / sampleRate) * 1000

        // Then: Should be approximately 80ms (per Gradium spec)
        XCTAssertEqual(chunkDurationMs, 80, accuracy: 1.0, "Chunk should be ~80ms")
    }

    func testSampleRateMatchesGradiumSpec() {
        // Then: Sample rate should be 24kHz as per Gradium STT spec
        XCTAssertEqual(AppConfig.STT.sampleRate, 24000)
    }
}
