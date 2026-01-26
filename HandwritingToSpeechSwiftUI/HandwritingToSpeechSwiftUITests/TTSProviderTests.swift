//
//  TTSProviderTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-25.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

// MARK: - Mock TTS Provider for Testing

/// Mock implementation of TTSProvider for unit testing
class MockTTSProvider: TTSProvider {

    var shouldSucceed = true
    var errorToThrow: TTSError?
    var streamingErrorToThrow: TTSError?  // Error thrown during streaming
    var mockAudioData: Data = Data([0x00, 0x01, 0x02, 0x03])
    var synthesizeCalled = false
    var lastText: String?
    var lastVoice: String?

    func synthesize(text: String, voice: String) async throws -> AsyncThrowingStream<Data, Error> {
        synthesizeCalled = true
        lastText = text
        lastVoice = voice

        if let error = errorToThrow {
            throw error
        }

        if !shouldSucceed {
            throw TTSError.apiError(statusCode: 500, message: "Mock error")
        }

        let audioData = self.mockAudioData
        let streamingError = self.streamingErrorToThrow

        return AsyncThrowingStream { continuation in
            continuation.yield(audioData)
            if let error = streamingError {
                continuation.finish(throwing: error)
            } else {
                continuation.finish()
            }
        }
    }
}

// MARK: - TTSProvider Protocol Tests

final class TTSProviderTests: XCTestCase {

    var mockProvider: MockTTSProvider!

    override func setUp() {
        super.setUp()
        mockProvider = MockTTSProvider()
    }

    override func tearDown() {
        mockProvider = nil
        super.tearDown()
    }

    // MARK: - Protocol Conformance Tests

    func testMockProviderConformsToProtocol() {
        let provider: any TTSProvider = mockProvider
        XCTAssertNotNil(provider)
    }

    // MARK: - Synthesize Method Tests

    func testSynthesizeCallsWithCorrectParameters() async throws {
        let text = "Bonjour"
        let voice = "olivier"

        _ = try await mockProvider.synthesize(text: text, voice: voice)

        XCTAssertTrue(mockProvider.synthesizeCalled)
        XCTAssertEqual(mockProvider.lastText, text)
        XCTAssertEqual(mockProvider.lastVoice, voice)
    }

    func testSynthesizeReturnsAudioStream() async throws {
        let stream = try await mockProvider.synthesize(text: "Test", voice: "olivier")

        var receivedData = Data()
        for try await chunk in stream {
            receivedData.append(chunk)
        }

        XCTAssertFalse(receivedData.isEmpty)
        XCTAssertEqual(receivedData, mockProvider.mockAudioData)
    }

    func testSynthesizeThrowsOnError() async {
        mockProvider.errorToThrow = TTSError.networkUnavailable

        do {
            _ = try await mockProvider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected error to be thrown")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.networkUnavailable.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    func testSynthesizeThrowsInvalidApiKey() async {
        mockProvider.errorToThrow = TTSError.invalidApiKey

        do {
            _ = try await mockProvider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected error to be thrown")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.invalidApiKey.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    func testSynthesizeThrowsRateLimited() async {
        mockProvider.errorToThrow = TTSError.rateLimited

        do {
            _ = try await mockProvider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected error to be thrown")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.rateLimited.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    func testSynthesizeThrowsTimeout() async {
        mockProvider.errorToThrow = TTSError.timeout

        do {
            _ = try await mockProvider.synthesize(text: "Test", voice: "olivier")
            XCTFail("Expected error to be thrown")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.timeout.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    // MARK: - Voice Selection Tests

    func testSynthesizeWithDifferentVoices() async throws {
        let voices = ["olivier", "kelly", "custom_voice"]

        for voice in voices {
            _ = try await mockProvider.synthesize(text: "Test", voice: voice)
            XCTAssertEqual(mockProvider.lastVoice, voice)
        }
    }

    // MARK: - Text Handling Tests

    func testSynthesizeWithEmptyText() async throws {
        _ = try await mockProvider.synthesize(text: "", voice: "olivier")
        XCTAssertEqual(mockProvider.lastText, "")
    }

    func testSynthesizeWithLongText() async throws {
        let longText = String(repeating: "Bonjour ", count: 1000)
        _ = try await mockProvider.synthesize(text: longText, voice: "olivier")
        XCTAssertEqual(mockProvider.lastText, longText)
    }

    func testSynthesizeWithSpecialCharacters() async throws {
        let specialText = "Bonjour! Comment allez-vous? C'est l'ete."
        _ = try await mockProvider.synthesize(text: specialText, voice: "olivier")
        XCTAssertEqual(mockProvider.lastText, specialText)
    }

    func testSynthesizeWithUnicodeCharacters() async throws {
        let unicodeText = "Cafe resume naive"
        _ = try await mockProvider.synthesize(text: unicodeText, voice: "olivier")
        XCTAssertEqual(mockProvider.lastText, unicodeText)
    }

    // MARK: - Streaming Error Propagation Tests

    func testStreamingErrorIsPropagated() async {
        mockProvider.streamingErrorToThrow = TTSError.timeout

        do {
            let stream = try await mockProvider.synthesize(text: "Test", voice: "olivier")

            // Iterate through stream - should throw the streaming error
            for try await _ in stream {
                // Consume data
            }
            XCTFail("Expected streaming error to be thrown")
        } catch let error as TTSError {
            XCTAssertEqual(error.errorDescription, TTSError.timeout.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }

    func testStreamingErrorAfterReceivingData() async {
        mockProvider.streamingErrorToThrow = TTSError.networkUnavailable

        do {
            let stream = try await mockProvider.synthesize(text: "Test", voice: "olivier")

            var receivedData = Data()
            for try await chunk in stream {
                receivedData.append(chunk)
            }
            XCTFail("Expected streaming error after receiving data")
        } catch let error as TTSError {
            // Error should be propagated even after receiving some data
            XCTAssertEqual(error.errorDescription, TTSError.networkUnavailable.errorDescription)
        } catch {
            XCTFail("Expected TTSError, got \(error)")
        }
    }
}
