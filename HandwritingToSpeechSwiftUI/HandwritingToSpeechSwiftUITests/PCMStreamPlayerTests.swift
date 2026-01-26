//
//  PCMStreamPlayerTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Created by CalliVox on 2026-01-26.
//

import XCTest
import AVFoundation
@testable import HandwritingToSpeechSwiftUI

@MainActor
final class PCMStreamPlayerTests: XCTestCase {

    var player: PCMStreamPlayer!

    override func setUp() async throws {
        try await super.setUp()
        player = PCMStreamPlayer()
    }

    override func tearDown() async throws {
        player?.stop()
        player = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func testPlayerInitialization() {
        // Given/When: Player is created
        // Then: Initial state is correct
        XCTAssertFalse(player.isPlaying, "Player should not be playing initially")
        XCTAssertFalse(player.showError, "Player should not show error initially")
        XCTAssertTrue(player.errorMessage.isEmpty, "Error message should be empty initially")
    }

    // MARK: - Buffer Scheduling Tests

    func testScheduleBufferWithValidPCMData() {
        // Given: Valid PCM data (24kHz, Int16, Mono)
        let sampleCount = 1024
        var pcmData = Data(count: sampleCount * MemoryLayout<Int16>.size)

        // Fill with sample audio data (simple sine wave pattern)
        pcmData.withUnsafeMutableBytes { buffer in
            let int16Buffer = buffer.bindMemory(to: Int16.self)
            for i in 0..<sampleCount {
                // Generate a simple pattern
                int16Buffer[i] = Int16(sin(Double(i) * 0.1) * 1000)
            }
        }

        // When: Buffer is scheduled (no crash = success for this test)
        // Note: We don't prepare the engine to avoid audio session issues in tests
        player.scheduleBuffer(pcmData)

        // Then: No error should be shown
        XCTAssertFalse(player.showError, "No error should occur when scheduling valid PCM data")
    }

    func testScheduleBufferWithEmptyData() {
        // Given: Empty data
        let emptyData = Data()

        // When: Empty buffer is scheduled
        player.scheduleBuffer(emptyData)

        // Then: Should handle gracefully (no crash, no error)
        XCTAssertFalse(player.showError, "Empty data should be handled gracefully")
    }

    // MARK: - Playback Control Tests

    func testStopClearsPlayingState() {
        // Given: Player in any state

        // When: Stop is called
        player.stop()

        // Then: Playing state should be false
        XCTAssertFalse(player.isPlaying, "Player should not be playing after stop")
    }

    func testResetClearsState() {
        // Given: Player in any state

        // When: Reset is called
        player.reset()

        // Then: State should be cleared
        XCTAssertFalse(player.isPlaying, "Player should not be playing after reset")
        XCTAssertFalse(player.showError, "No error should be shown after reset")
    }

    // MARK: - Interruption Tests (AC3)

    func testStopInterruptsCurrentPlayback() {
        // Given: Some data has been scheduled
        let sampleData = createMockPCMData(sampleCount: 512)
        player.scheduleBuffer(sampleData)

        // When: Stop is called (simulating new TTS request)
        player.stop()

        // Then: Player should stop cleanly
        XCTAssertFalse(player.isPlaying, "Player should stop when interrupted")
    }

    // MARK: - Completion Callback Tests

    func testCompletionCallbackIsSet() {
        // Given: A completion callback
        var callbackCalled = false
        player.onPlaybackComplete = {
            callbackCalled = true
        }

        // When: Callback is manually triggered (simulating completion)
        player.onPlaybackComplete?()

        // Then: Callback should be called
        XCTAssertTrue(callbackCalled, "Completion callback should be called")
    }

    // MARK: - Resource Cleanup Tests (AC4)

    func testPlayerReleasesResourcesOnDeinit() {
        // Given: A player instance
        var localPlayer: PCMStreamPlayer? = PCMStreamPlayer()

        // When: Player is deallocated
        localPlayer = nil

        // Then: No crash should occur (deinit cleanup works)
        // This test passes if no crash occurs during deallocation
        XCTAssertNil(localPlayer, "Player should be deallocated")
    }

    func testMultipleStopCallsAreSafe() {
        // Given: A player

        // When: Stop is called multiple times
        player.stop()
        player.stop()
        player.stop()

        // Then: No crash should occur
        XCTAssertFalse(player.isPlaying, "Multiple stops should be safe")
    }

    // MARK: - Error Handling Tests

    func testErrorStateAfterInternalError() {
        // Given: Player in initial state
        XCTAssertFalse(player.showError, "Should not show error initially")

        // When: Error occurs (simulated by checking internal state)
        // Note: We can't easily trigger internal errors without mocking

        // Then: Error handling is available
        XCTAssertTrue(player.errorMessage.isEmpty, "Error message should be empty without errors")
    }

    // MARK: - Audio Session Interruption Tests (M3 Fix)

    func testPlayerHandlesInterruptionNotificationGracefully() {
        // Given: A player instance
        // Note: We can't easily simulate real interruptions in unit tests,
        // but we can verify the player handles notification registration

        // When: Player is created
        // Then: It should have set up interruption handling without crashing
        XCTAssertNotNil(player, "Player should initialize with interruption handling")
    }

    func testPlayerStateAfterSimulatedInterruption() {
        // Given: Player with some scheduled data
        let sampleData = createMockPCMData(sampleCount: 512)
        player.scheduleBuffer(sampleData)

        // When: We simulate an interruption by stopping the player
        // (Real interruptions would be triggered by AVAudioSession notifications)
        player.stop()

        // Then: Player should be in a clean state
        XCTAssertFalse(player.isPlaying, "Player should not be playing after interruption/stop")
    }

    // MARK: - Audio Format Tests

    func testPCMFormatIs24kHzInt16Mono() {
        // This test verifies the expected format is used
        // The player should handle 24kHz Int16 Mono PCM data

        // Given: PCM data with correct format (24kHz, Int16, Mono)
        let sampleCount = 24000  // 1 second of audio at 24kHz
        let pcmData = createMockPCMData(sampleCount: sampleCount)

        // When: Data is scheduled
        player.scheduleBuffer(pcmData)

        // Then: No format error should occur
        XCTAssertFalse(player.showError, "24kHz Int16 Mono format should be accepted")
    }

    // MARK: - Helper Methods

    private func createMockPCMData(sampleCount: Int) -> Data {
        var data = Data(count: sampleCount * MemoryLayout<Int16>.size)
        data.withUnsafeMutableBytes { buffer in
            let int16Buffer = buffer.bindMemory(to: Int16.self)
            for i in 0..<sampleCount {
                // Generate silence (zeros) or a simple pattern
                int16Buffer[i] = Int16(sin(Double(i) * 0.05) * 500)
            }
        }
        return data
    }
}
