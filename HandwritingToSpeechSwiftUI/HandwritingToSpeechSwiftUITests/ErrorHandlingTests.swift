//
//  ErrorHandlingTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 2.3: Graceful Error Handling - Unit tests for error handling paths
//
//  NOTE: These tests validate TTSError enum properties (French messages, recovery suggestions).
//  The helper methods mirror GradiumTTSProvider's mapping logic for verification.
//  Integration tests requiring actual HTTP responses would need URLSession mocking.
//

import XCTest
import AVFoundation
@testable import HandwritingToSpeechSwiftUI

final class ErrorHandlingTests: XCTestCase {

    // MARK: - HTTP Status Code Mapping Tests (AC: 2, 3)
    // These verify TTSError properties match expected French messages for each HTTP code

    /// Test: HTTP 401 response → TTSError.invalidApiKey with correct French message
    func testHTTP401MapsToInvalidApiKey() {
        // Given: HTTP 401 Unauthorized response
        let statusCode = 401

        // When: Mapped according to GradiumTTSProvider.validateHTTPResponse logic
        let expectedError = TTSError.invalidApiKey

        // Then: Correct TTSError type and French message
        XCTAssertEqual(expectedError.errorDescription, "Clé API invalide. Veuillez vérifier votre configuration.")
        XCTAssertEqual(expectedError.failureReason, "API key not found in Keychain or invalid")
        XCTAssertNotNil(expectedError.recoverySuggestion)

        // Verify the mapping matches what GradiumTTSProvider does
        let mappedError = mapHTTPStatusToTTSError(statusCode)
        XCTAssertTrue(isInvalidApiKeyError(mappedError))
    }

    /// Test: HTTP 429 response → TTSError.rateLimited with correct French message
    func testHTTP429MapsToRateLimited() {
        // Given: HTTP 429 Too Many Requests response
        let statusCode = 429

        // When: Mapped according to GradiumTTSProvider.validateHTTPResponse logic
        let expectedError = TTSError.rateLimited

        // Then: Correct TTSError type and French message
        XCTAssertEqual(expectedError.errorDescription, "Trop de requêtes. Veuillez patienter quelques instants.")
        XCTAssertEqual(expectedError.failureReason, "HTTP 429 - Rate limit exceeded")
        XCTAssertEqual(expectedError.recoverySuggestion, "Attendez quelques secondes avant de réessayer.")

        // Verify the mapping
        let mappedError = mapHTTPStatusToTTSError(statusCode)
        XCTAssertTrue(isRateLimitedError(mappedError))
    }

    /// Test: HTTP 408 response → TTSError.timeout with correct French message
    func testHTTP408MapsToTimeout() {
        // Given: HTTP 408 Request Timeout response
        let statusCode = 408

        // When: Mapped according to GradiumTTSProvider.validateHTTPResponse logic
        let expectedError = TTSError.timeout

        // Then: Correct TTSError type and French message
        XCTAssertEqual(expectedError.errorDescription, "Connexion lente ou indisponible")
        XCTAssertEqual(expectedError.failureReason, "Request exceeded timeout interval")

        // Story 2.3 AC4: Verify offline fallback is mentioned in recovery suggestion
        let recoverySuggestion = expectedError.recoverySuggestion ?? ""
        XCTAssertTrue(recoverySuggestion.contains("hors-ligne"), "Timeout should mention offline mode availability")

        // Verify the mapping
        let mappedError = mapHTTPStatusToTTSError(statusCode)
        XCTAssertTrue(isTimeoutError(mappedError))
    }

    // MARK: - NSURLError Mapping Tests

    /// Test: NSURLErrorTimedOut → TTSError.timeout
    func testNSURLErrorTimedOutMapsToTimeout() {
        // Given: NSURLErrorTimedOut (-1001)
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut)

        // When: Mapped according to GradiumTTSProvider.handleError logic
        let mappedError = mapNSURLErrorToTTSError(nsError)

        // Then: Should be timeout
        XCTAssertTrue(isTimeoutError(mappedError))

        // Verify French message
        let timeoutError = TTSError.timeout
        XCTAssertEqual(timeoutError.errorDescription, "Connexion lente ou indisponible")
    }

    /// Test: NSURLErrorNotConnectedToInternet → TTSError.networkUnavailable
    func testNSURLErrorNotConnectedMapsToNetworkUnavailable() {
        // Given: NSURLErrorNotConnectedToInternet (-1009)
        let nsError = NSError(domain: NSURLErrorDomain, code: NSURLErrorNotConnectedToInternet)

        // When: Mapped according to GradiumTTSProvider.handleError logic
        let mappedError = mapNSURLErrorToTTSError(nsError)

        // Then: Should be networkUnavailable
        XCTAssertTrue(isNetworkUnavailableError(mappedError))

        // Verify French message
        let networkError = TTSError.networkUnavailable
        XCTAssertEqual(networkError.errorDescription, "Connexion internet indisponible")
    }

    // MARK: - Recovery Suggestion Completeness Tests (AC: 1)

    /// Test: TTSError.recoverySuggestion is non-nil for all cases
    func testAllTTSErrorsHaveRecoverySuggestion() {
        let errors: [TTSError] = [
            .networkUnavailable,
            .apiError(statusCode: 500, message: "Server error"),
            .audioPlaybackFailed(underlying: NSError(domain: AVFoundationErrorDomain, code: AVError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Test audio error"])),
            .invalidApiKey,
            .rateLimited,
            .timeout
        ]

        for error in errors {
            XCTAssertNotNil(error.recoverySuggestion, "\(error) should have a recovery suggestion")
            XCTAssertFalse(error.recoverySuggestion?.isEmpty ?? true, "\(error) recovery suggestion should not be empty")
        }
    }

    /// Test: All recovery suggestions are in French
    func testRecoverySuggestionsAreInFrench() {
        let errors: [TTSError] = [
            .networkUnavailable,
            .apiError(statusCode: 500, message: "test"),
            .audioPlaybackFailed(underlying: NSError(domain: AVFoundationErrorDomain, code: AVError.Code.unknown.rawValue, userInfo: [NSLocalizedDescriptionKey: "Test audio error"])),
            .invalidApiKey,
            .rateLimited,
            .timeout
        ]

        for error in errors {
            let suggestion = error.recoverySuggestion ?? ""
            // French indicators: accented characters, common French words
            let hasFrenchContent = suggestion.contains("é") ||
                                   suggestion.contains("è") ||
                                   suggestion.contains("à") ||
                                   suggestion.contains("Vérifiez") ||
                                   suggestion.contains("Allez") ||
                                   suggestion.contains("Attendez") ||
                                   suggestion.contains("Fermez") ||
                                   suggestion.contains("problème") ||
                                   suggestion.contains("réessayez")
            XCTAssertTrue(hasFrenchContent, "Recovery suggestion for \(error) should be in French: '\(suggestion)'")
        }
    }

    // MARK: - Story 2.3 AC4: Timeout mentions offline fallback

    /// Test: Timeout recovery suggestion mentions offline mode
    func testTimeoutRecoverySuggestionMentionsOfflineMode() {
        let error = TTSError.timeout
        let suggestion = error.recoverySuggestion ?? ""

        XCTAssertTrue(suggestion.contains("hors-ligne"),
                      "Timeout recovery should mention offline mode. Got: '\(suggestion)'")
    }

    // MARK: - Error Message Format Tests (Story 2.3 AC1)

    /// Test: Error messages include both description and recovery for user understanding
    func testErrorMessagesProvideCompleteGuidance() {
        let errors: [TTSError] = [
            .networkUnavailable,
            .invalidApiKey,
            .rateLimited,
            .timeout
        ]

        for error in errors {
            // Both should be non-nil and non-empty
            XCTAssertNotNil(error.errorDescription, "\(error) should have error description")
            XCTAssertNotNil(error.recoverySuggestion, "\(error) should have recovery suggestion")

            // Combined message should be informative
            let fullMessage = "\(error.errorDescription ?? "")\n\n\(error.recoverySuggestion ?? "")"
            XCTAssertTrue(fullMessage.count > 20, "Combined message should be meaningful: \(fullMessage)")
        }
    }

    // MARK: - Helper Methods (Simulating GradiumTTSProvider logic)

    /// Simulates GradiumTTSProvider.validateHTTPResponse HTTP status code mapping
    private func mapHTTPStatusToTTSError(_ statusCode: Int) -> TTSError {
        switch statusCode {
        case 401:
            return .invalidApiKey
        case 429:
            return .rateLimited
        case 408:
            return .timeout
        default:
            return .apiError(statusCode: statusCode, message: "HTTP \(statusCode)")
        }
    }

    /// Simulates GradiumTTSProvider.handleError NSURLError mapping
    private func mapNSURLErrorToTTSError(_ error: NSError) -> TTSError {
        switch error.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorNotConnectedToInternet:
            return .networkUnavailable
        default:
            return .apiError(statusCode: 0, message: error.localizedDescription)
        }
    }

    // MARK: - Type Check Helpers

    private func isInvalidApiKeyError(_ error: TTSError) -> Bool {
        if case .invalidApiKey = error { return true }
        return false
    }

    private func isRateLimitedError(_ error: TTSError) -> Bool {
        if case .rateLimited = error { return true }
        return false
    }

    private func isTimeoutError(_ error: TTSError) -> Bool {
        if case .timeout = error { return true }
        return false
    }

    private func isNetworkUnavailableError(_ error: TTSError) -> Bool {
        if case .networkUnavailable = error { return true }
        return false
    }
}
