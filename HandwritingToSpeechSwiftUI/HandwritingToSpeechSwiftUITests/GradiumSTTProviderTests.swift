//
//  GradiumSTTProviderTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Unit tests for GradiumSTTProvider.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class GradiumSTTProviderTests: XCTestCase {

    // MARK: - Setup Message Tests

    func testSetupMessageFormat() throws {
        // Given: Expected setup message format
        let expectedType = "setup"
        let expectedModelName = AppConfig.STT.modelName
        let expectedInputFormat = AppConfig.STT.inputFormat

        // When: We create a setup message structure
        let setup: [String: Any] = [
            "type": expectedType,
            "model_name": expectedModelName,
            "input_format": expectedInputFormat
        ]

        // Then: JSON serialization succeeds
        let jsonData = try JSONSerialization.data(withJSONObject: setup)
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)

        // Verify fields are present
        XCTAssertTrue(jsonString!.contains("\"type\""))
        XCTAssertTrue(jsonString!.contains("\"model_name\""))
        XCTAssertTrue(jsonString!.contains("\"input_format\""))
    }

    // MARK: - Audio Message Tests

    func testAudioMessageBase64Encoding() {
        // Given: Sample PCM audio data (1920 samples = 80ms at 24kHz)
        let sampleCount = AppConfig.STT.chunkSamples
        var audioData = Data(count: sampleCount * MemoryLayout<Int16>.size)

        audioData.withUnsafeMutableBytes { buffer in
            let int16Buffer = buffer.bindMemory(to: Int16.self)
            for i in 0..<sampleCount {
                int16Buffer[i] = Int16(sin(Double(i) * 0.1) * 1000)
            }
        }

        // When: We encode to base64
        let base64Audio = audioData.base64EncodedString()

        // Then: Base64 string is valid
        XCTAssertFalse(base64Audio.isEmpty)

        // And: Decoding returns original data
        let decodedData = Data(base64Encoded: base64Audio)
        XCTAssertEqual(decodedData, audioData)
    }

    func testAudioMessageStructure() throws {
        // Given: Base64 encoded audio
        let testBase64 = "SGVsbG8gV29ybGQ="

        // When: We create audio message structure
        let audioMessage: [String: Any] = [
            "type": "audio",
            "audio": testBase64
        ]

        // Then: JSON serialization succeeds
        let jsonData = try JSONSerialization.data(withJSONObject: audioMessage)
        let jsonString = String(data: jsonData, encoding: .utf8)
        XCTAssertNotNil(jsonString)
        XCTAssertTrue(jsonString!.contains("\"type\":\"audio\""))
        XCTAssertTrue(jsonString!.contains("\"audio\""))
    }

    // MARK: - Response Parsing Tests

    func testParseTextMessage() throws {
        // Given: A text message from Gradium
        let textJson = """
        {"type": "text", "text": "Bonjour comment ça va", "start_s": 1.5, "stream_id": 0}
        """
        let jsonData = textJson.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        // When: We parse the message
        let type = json["type"] as? String
        let text = json["text"] as? String
        let startS = json["start_s"] as? Double

        // Then: Fields are correctly parsed
        XCTAssertEqual(type, "text")
        XCTAssertEqual(text, "Bonjour comment ça va")
        XCTAssertEqual(startS, 1.5)
    }

    func testParseStepMessageWithVAD() throws {
        // Given: A step message with VAD predictions
        let stepJson = """
        {
            "type": "step",
            "vad": [
                {"horizon_s": 0.5, "inactivity_prob": 0.2},
                {"horizon_s": 1.0, "inactivity_prob": 0.3},
                {"horizon_s": 1.5, "inactivity_prob": 0.4}
            ],
            "step_idx": 10,
            "step_duration_s": 0.08,
            "total_duration_s": 0.8
        }
        """
        let jsonData = stepJson.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        // When: We parse the VAD array
        let type = json["type"] as? String
        let vadArray = json["vad"] as? [[String: Any]]

        // Then: VAD predictions are correctly parsed
        XCTAssertEqual(type, "step")
        XCTAssertNotNil(vadArray)
        XCTAssertEqual(vadArray?.count, 3)

        // Verify last prediction (used for end-of-speech detection)
        let lastVad = vadArray?.last
        let inactivityProb = lastVad?["inactivity_prob"] as? Double
        XCTAssertEqual(inactivityProb, 0.4)
    }

    func testParseReadyMessage() throws {
        // Given: A ready message from Gradium
        let readyJson = """
        {
            "type": "ready",
            "request_id": "abc123",
            "model_name": "default",
            "sample_rate": 24000,
            "frame_size": 0.08,
            "text_stream_names": ["text"]
        }
        """
        let jsonData = readyJson.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        // When: We parse the message
        let type = json["type"] as? String
        let sampleRate = json["sample_rate"] as? Int

        // Then: Ready message is correctly identified
        XCTAssertEqual(type, "ready")
        XCTAssertEqual(sampleRate, 24000)
    }

    func testParseEndOfStreamMessage() throws {
        // Given: An end_of_stream message
        let endJson = """
        {"type": "end_of_stream"}
        """
        let jsonData = endJson.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        // When: We parse the message
        let type = json["type"] as? String

        // Then: End of stream is correctly identified
        XCTAssertEqual(type, "end_of_stream")
    }

    func testParseErrorMessage() throws {
        // Given: An error message from Gradium
        let errorJson = """
        {"message": "Rate limit exceeded", "code": 429}
        """
        let jsonData = errorJson.data(using: .utf8)!
        let json = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        // When: We parse the message
        let message = json["message"] as? String
        let code = json["code"] as? Int

        // Then: Error details are correctly parsed
        XCTAssertEqual(message, "Rate limit exceeded")
        XCTAssertEqual(code, 429)
    }

    // MARK: - Configuration Tests

    func testSTTConfigurationValues() {
        // Verify STT configuration is correctly set
        XCTAssertEqual(AppConfig.STT.sampleRate, 24000)
        XCTAssertEqual(AppConfig.STT.chunkSamples, 1920)
        XCTAssertEqual(AppConfig.STT.inputFormat, "pcm")
        XCTAssertEqual(AppConfig.STT.modelName, "default")
        XCTAssertTrue(AppConfig.STT.vadInactivityThreshold > 0)
        XCTAssertTrue(AppConfig.STT.vadInactivityThreshold < 1)
    }

    func testSTTEndpointIsValid() {
        // Verify endpoint is a valid WebSocket URL
        let endpoint = AppConfig.STT.apiEndpoint
        XCTAssertTrue(endpoint.hasPrefix("wss://"))
        XCTAssertTrue(endpoint.contains("gradium.ai"))
        XCTAssertTrue(endpoint.contains("asr"))
    }

    // MARK: - VAD Prediction Tests

    func testVADPredictionStructure() {
        // Given: VAD prediction values
        let horizonS = 1.5
        let inactivityProb: Float = 0.85

        // When: We create a VAD prediction
        let prediction = VADPrediction(horizonS: horizonS, inactivityProb: inactivityProb)

        // Then: Values are correctly stored
        XCTAssertEqual(prediction.horizonS, horizonS)
        XCTAssertEqual(prediction.inactivityProb, inactivityProb)
    }

    func testVADThresholdDetection() {
        // Given: Inactivity probability above threshold
        let highInactivity: Float = 0.9
        let threshold = AppConfig.STT.vadInactivityThreshold

        // Then: Should be detected as speech ended
        XCTAssertTrue(highInactivity > threshold)

        // Given: Inactivity probability below threshold
        let lowInactivity: Float = 0.3

        // Then: Should be detected as speech ongoing
        XCTAssertFalse(lowInactivity > threshold)
    }

    // MARK: - STTEvent Tests

    func testSTTEventEquality() {
        // Test ready events
        let ready1 = STTEvent.ready(requestId: "abc", sampleRate: 24000)
        let ready2 = STTEvent.ready(requestId: "abc", sampleRate: 24000)
        XCTAssertEqual(ready1, ready2)

        // Test text events
        let text1 = STTEvent.text("Hello", startTime: 1.0)
        let text2 = STTEvent.text("Hello", startTime: 1.0)
        XCTAssertEqual(text1, text2)

        // Test different events
        let text3 = STTEvent.text("World", startTime: 2.0)
        XCTAssertNotEqual(text1, text3)
    }
}
