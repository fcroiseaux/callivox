//
//  GradiumTTSProviderTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-25.
//

import XCTest
import Combine
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class GradiumTTSProviderTests: XCTestCase {

    // MARK: - Constants

    /// Delay to allow MainActor state updates to propagate
    private static let stateUpdateDelay: UInt64 = 100_000_000  // 100ms in nanoseconds

    var provider: GradiumTTSProvider!

    override func setUp() {
        super.setUp()
        provider = GradiumTTSProvider()
    }

    override func tearDown() {
        provider = nil
        // Clean up test API key from Keychain
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)
        super.tearDown()
    }

    // MARK: - Protocol Conformance Tests

    func testProviderConformsToTTSProvider() {
        let ttsProvider: any TTSProvider = provider
        XCTAssertNotNil(ttsProvider)
    }

    // MARK: - Published Properties Tests

    func testInitialStateIsNotLoading() {
        XCTAssertFalse(provider.isLoading)
    }

    func testInitialStateShowsNoError() {
        XCTAssertFalse(provider.showError)
        XCTAssertTrue(provider.errorMessage.isEmpty)
    }

    // MARK: - API Key Validation Tests

    func testSynthesizeThrowsErrorWhenNoApiKey() async {
        // Ensure no API key exists
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)

        do {
            _ = try await provider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected invalidApiKey error")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.invalidApiKey.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    func testSynthesizeThrowsErrorWhenApiKeyIsEmpty() async {
        // Save empty API key
        try? KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: Data())

        do {
            _ = try await provider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected invalidApiKey error")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.invalidApiKey.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    // MARK: - AppConfig Integration Tests

    func testUsesCorrectApiEndpoint() {
        XCTAssertEqual(AppConfig.Gradium.apiEndpoint, "wss://eu.api.gradium.ai/api/speech/tts")
    }

    func testUsesCorrectDefaultVoice() {
        XCTAssertEqual(AppConfig.Gradium.defaultVoiceId, "m46-aSD529HCahBS")
    }

    func testUsesCorrectOutputFormat() {
        XCTAssertEqual(AppConfig.Gradium.outputFormat, "pcm")
    }

    func testUsesCorrectKeychainKey() {
        XCTAssertEqual(AppConfig.Gradium.keychainKey, "gradium_api_key")
    }

    func testTimeoutIsReasonable() {
        XCTAssertGreaterThan(AppConfig.Gradium.timeout, 0)
        XCTAssertLessThanOrEqual(AppConfig.Gradium.timeout, 30.0)
    }

    // MARK: - Error Handling Tests

    func testErrorMessageIsSetOnFailure() async {
        // Ensure no API key
        try? KeychainManager.delete(key: AppConfig.Gradium.keychainKey)

        do {
            _ = try await provider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected invalidApiKey error to be thrown")
        } catch let error as TTSError {
            // Verify the correct error type was thrown
            if case .invalidApiKey = error {
                // Give time for error state to update on MainActor
                try? await Task.sleep(nanoseconds: Self.stateUpdateDelay)

                // Verify error state was set
                XCTAssertTrue(provider.showError, "Provider should show error after failure")
                XCTAssertFalse(provider.errorMessage.isEmpty, "Error message should be set after failure")
                XCTAssertTrue(provider.errorMessage.contains("API") || provider.errorMessage.contains("Clé"),
                             "Error message should mention API key issue")
            } else {
                XCTFail("Expected invalidApiKey error, got \(error)")
            }
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    // MARK: - ObservableObject Tests

    func testIsObservableObject() {
        // Verify the provider publishes changes
        let expectation = XCTestExpectation(description: "Published property change")

        let cancellable = provider.$isLoading.sink { _ in
            expectation.fulfill()
        }

        // Trigger a change
        provider.isLoading = true

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    // MARK: - MainActor Tests

    func testRunsOnMainActor() async {
        // This test runs on MainActor due to @MainActor annotation
        XCTAssertTrue(Thread.isMainThread)
    }

    // MARK: - Integration Tests (Require Valid API Key)

    /// Note: This test requires a valid Gradium API key in the environment
    /// Skip this test in CI by checking for the key first
    func testSynthesizeWithValidApiKey() async throws {
        // Check if we have a test API key in environment
        guard let testApiKey = ProcessInfo.processInfo.environment["GRADIUM_TEST_API_KEY"],
              !testApiKey.isEmpty else {
            throw XCTSkip("GRADIUM_TEST_API_KEY not set - skipping integration test")
        }

        // Save test API key
        try KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: testApiKey.data(using: .utf8)!)

        // Attempt synthesis
        let stream = try await provider.synthesize(text: "Bonjour", voice: "olivier")

        var receivedData = Data()
        for try await chunk in stream {
            receivedData.append(chunk)
        }

        XCTAssertFalse(receivedData.isEmpty, "Should receive audio data")
    }
}
