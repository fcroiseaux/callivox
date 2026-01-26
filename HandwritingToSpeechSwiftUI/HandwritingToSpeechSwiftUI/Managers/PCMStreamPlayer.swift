//
//  PCMStreamPlayer.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by CalliVox on 2026-01-26.
//

import Foundation
import AVFoundation

/// PCM audio streaming player using AVAudioEngine.
/// Handles real-time playback of PCM audio data chunks as they arrive from the network.
///
/// Audio Format: 24kHz, Int16, Mono (Gradium TTS output format)
///
/// Usage:
/// ```swift
/// let player = PCMStreamPlayer()
/// try player.prepareToPlay()
/// player.scheduleBuffer(pcmData)
/// player.play()
/// ```
@MainActor
class PCMStreamPlayer: ObservableObject {

    // MARK: - Published Properties

    @Published var isPlaying = false
    @Published var showError = false
    @Published var errorMessage = ""

    // MARK: - Audio Engine Properties

    private var engine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?

    /// PCM format from Gradium: 24kHz, Int16, Mono
    private let format: AVAudioFormat?

    /// Callback when playback completes
    var onPlaybackComplete: (() -> Void)?

    /// Track if we've started playing (for first-chunk latency)
    private var hasStartedPlayback = false

    /// Track number of scheduled buffers for completion detection
    private var scheduledBufferCount = 0
    private var completedBufferCount = 0

    /// Observer for audio session interruptions
    private var interruptionObserver: NSObjectProtocol?

    // MARK: - Initialization

    init() {
        // Initialize PCM format: 24kHz, Int16, Mono
        self.format = AVAudioFormat(
            commonFormat: .pcmFormatInt16,
            sampleRate: 24000,
            channels: 1,
            interleaved: false
        )

        setupAudioEngine()
        setupInterruptionHandling()
    }

    deinit {
        // Remove interruption observer
        if let observer = interruptionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        // CRITICAL: Clean up audio resources to prevent memory leaks
        engine?.stop()
        playerNode?.stop()
        playerNode = nil
        engine = nil
    }

    // MARK: - Setup

    private func setupAudioEngine() {
        engine = AVAudioEngine()
        playerNode = AVAudioPlayerNode()

        guard let engine = engine,
              let playerNode = playerNode,
              let format = format else {
            handleError("Impossible d'initialiser le moteur audio")
            return
        }

        // Attach player node to engine
        engine.attach(playerNode)

        // Connect player node to main mixer with our PCM format
        engine.connect(playerNode, to: engine.mainMixerNode, format: format)
    }

    // MARK: - Audio Session Configuration

    /// Configures the audio session for playback
    func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try session.setActive(true)
    }

    /// Sets up handling for audio session interruptions (phone calls, alarms, etc.)
    private func setupInterruptionHandling() {
        interruptionObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: AVAudioSession.sharedInstance(),
            queue: .main
        ) { [weak self] notification in
            Task { @MainActor in
                self?.handleInterruption(notification)
            }
        }
    }

    /// Handles audio session interruptions
    private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        switch type {
        case .began:
            // Interruption began (e.g., phone call)
            print("PCMStreamPlayer: Audio interruption began")
            playerNode?.pause()
            isPlaying = false

        case .ended:
            // Interruption ended
            print("PCMStreamPlayer: Audio interruption ended")
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    // Resume playback if recommended
                    do {
                        try configureAudioSession()
                        playerNode?.play()
                        isPlaying = true
                        print("PCMStreamPlayer: Playback resumed after interruption")
                    } catch {
                        handleError("Erreur lors de la reprise de la lecture: \(error.localizedDescription)")
                    }
                }
            }

        @unknown default:
            break
        }
    }

    // MARK: - Playback Control

    /// Prepares the audio engine for playback
    func prepareToPlay() throws {
        guard let engine = engine else {
            throw TTSError.audioPlaybackFailed(underlying: NSError(
                domain: "PCMStreamPlayer",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Moteur audio non initialisé"]
            ))
        }

        // Configure audio session
        try configureAudioSession()

        // Prepare and start engine
        engine.prepare()
        try engine.start()

        // Reset playback state
        hasStartedPlayback = false
        scheduledBufferCount = 0
        completedBufferCount = 0
    }

    /// Starts audio playback
    func play() {
        guard let playerNode = playerNode else { return }

        if !playerNode.isPlaying {
            playerNode.play()
            isPlaying = true
            hasStartedPlayback = true
        }
    }

    /// Stops playback and clears all scheduled buffers
    func stop() {
        playerNode?.stop()
        isPlaying = false
        hasStartedPlayback = false
        scheduledBufferCount = 0
        completedBufferCount = 0

        // Reset the engine for next playback session
        engine?.stop()

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    /// Resets the player for a new playback session
    func reset() {
        stop()
        setupAudioEngine()
    }

    // MARK: - Buffer Scheduling

    /// Schedules PCM audio data for playback
    /// - Parameter data: Raw PCM audio data (Int16, 24kHz, Mono)
    func scheduleBuffer(_ data: Data) {
        guard let format = format,
              let playerNode = playerNode else {
            return
        }

        // Calculate frame count from data size
        // Int16 = 2 bytes per sample
        let frameCount = UInt32(data.count / MemoryLayout<Int16>.size)
        guard frameCount > 0 else { return }

        // Create audio buffer
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            handleError("Impossible de créer le buffer audio")
            return
        }

        buffer.frameLength = frameCount

        // Copy PCM data to buffer
        data.withUnsafeBytes { rawBuffer in
            guard let int16Pointer = rawBuffer.baseAddress?.assumingMemoryBound(to: Int16.self) else {
                return
            }
            buffer.int16ChannelData?[0].update(from: int16Pointer, count: Int(frameCount))
        }

        // Track scheduled buffers
        scheduledBufferCount += 1
        let currentBufferIndex = scheduledBufferCount

        // Schedule buffer with completion handler
        playerNode.scheduleBuffer(buffer) { [weak self] in
            Task { @MainActor in
                self?.handleBufferCompletion(bufferIndex: currentBufferIndex)
            }
        }

        // Auto-start playback on first buffer for minimal latency (< 300ms requirement)
        if !hasStartedPlayback {
            play()
        }
    }

    /// Signals that no more buffers will be scheduled
    func finishScheduling() {
        // Check if all buffers have been played
        checkPlaybackCompletion()
    }

    // MARK: - Private Methods

    private func handleBufferCompletion(bufferIndex: Int) {
        completedBufferCount += 1
        checkPlaybackCompletion()
    }

    private func checkPlaybackCompletion() {
        // All scheduled buffers have been played
        if completedBufferCount >= scheduledBufferCount && scheduledBufferCount > 0 {
            isPlaying = false
            cleanupAfterCompletion()
            onPlaybackComplete?()
        }
    }

    /// Cleans up audio engine and session after natural completion
    private func cleanupAfterCompletion() {
        playerNode?.stop()
        engine?.stop()
        scheduledBufferCount = 0
        completedBufferCount = 0

        // Deactivate audio session to release audio resources
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func handleError(_ message: String) {
        errorMessage = message
        showError = true
        isPlaying = false
        print("PCMStreamPlayer Error: \(message)")
    }
}
