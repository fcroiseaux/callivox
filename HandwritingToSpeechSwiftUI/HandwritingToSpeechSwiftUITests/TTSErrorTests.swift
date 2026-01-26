//
//  TTSErrorTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-25.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class TTSErrorTests: XCTestCase {

    // MARK: - Error Description Tests

    func testNetworkUnavailableErrorDescription() {
        let error = TTSError.networkUnavailable
        XCTAssertEqual(error.errorDescription, "Connexion internet indisponible")
    }

    func testApiErrorDescription() {
        let error = TTSError.apiError(statusCode: 500, message: "Server error")
        XCTAssertEqual(error.errorDescription, "Erreur du service vocal (500): Server error")
    }

    func testAudioPlaybackFailedErrorDescription() {
        let underlyingError = NSError(domain: "AudioError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Audio failed"])
        let error = TTSError.audioPlaybackFailed(underlying: underlyingError)
        XCTAssertTrue(error.errorDescription?.contains("Erreur de lecture audio") ?? false)
    }

    func testInvalidApiKeyErrorDescription() {
        let error = TTSError.invalidApiKey
        XCTAssertEqual(error.errorDescription, "Clé API invalide. Veuillez vérifier votre configuration.")
    }

    func testRateLimitedErrorDescription() {
        let error = TTSError.rateLimited
        XCTAssertEqual(error.errorDescription, "Trop de requêtes. Veuillez patienter quelques instants.")
    }

    func testTimeoutErrorDescription() {
        let error = TTSError.timeout
        XCTAssertEqual(error.errorDescription, "Connexion lente ou indisponible")
    }

    // MARK: - Failure Reason Tests

    func testNetworkUnavailableFailureReason() {
        let error = TTSError.networkUnavailable
        XCTAssertEqual(error.failureReason, "No network connection available")
    }

    func testApiErrorFailureReason() {
        let error = TTSError.apiError(statusCode: 401, message: "Unauthorized")
        XCTAssertEqual(error.failureReason, "HTTP status code: 401")
    }

    func testInvalidApiKeyFailureReason() {
        let error = TTSError.invalidApiKey
        XCTAssertEqual(error.failureReason, "API key not found in Keychain or invalid")
    }

    func testRateLimitedFailureReason() {
        let error = TTSError.rateLimited
        XCTAssertEqual(error.failureReason, "HTTP 429 - Rate limit exceeded")
    }

    func testTimeoutFailureReason() {
        let error = TTSError.timeout
        XCTAssertEqual(error.failureReason, "Request exceeded timeout interval")
    }

    // MARK: - Recovery Suggestion Tests

    func testNetworkUnavailableRecoverySuggestion() {
        let error = TTSError.networkUnavailable
        XCTAssertEqual(error.recoverySuggestion, "Vérifiez votre connexion internet et réessayez.")
    }

    func testInvalidApiKeyRecoverySuggestion() {
        let error = TTSError.invalidApiKey
        XCTAssertEqual(error.recoverySuggestion, "Allez dans Paramètres pour configurer votre clé API Gradium.")
    }

    func testRateLimitedRecoverySuggestion() {
        let error = TTSError.rateLimited
        XCTAssertEqual(error.recoverySuggestion, "Attendez quelques secondes avant de réessayer.")
    }

    // MARK: - LocalizedError Conformance

    func testConformsToLocalizedError() {
        let error: LocalizedError = TTSError.networkUnavailable
        XCTAssertNotNil(error.errorDescription)
        XCTAssertNotNil(error.failureReason)
        XCTAssertNotNil(error.recoverySuggestion)
    }

    // MARK: - French Localization Tests

    func testAllErrorsHaveFrenchDescriptions() {
        let errors: [TTSError] = [
            .networkUnavailable,
            .apiError(statusCode: 500, message: "test"),
            .audioPlaybackFailed(underlying: NSError(domain: "", code: 0)),
            .invalidApiKey,
            .rateLimited,
            .timeout
        ]

        for error in errors {
            let description = error.errorDescription ?? ""
            // Check that descriptions contain French characters or common French words
            let hasFrenchContent = description.contains("Connexion") ||
                                   description.contains("Erreur") ||
                                   description.contains("Clé") ||
                                   description.contains("requêtes") ||
                                   description.contains("indisponible")
            XCTAssertTrue(hasFrenchContent, "Error \(error) should have French description")
        }
    }
}
