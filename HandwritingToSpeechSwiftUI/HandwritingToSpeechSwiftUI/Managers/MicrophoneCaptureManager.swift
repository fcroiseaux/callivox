//
//  MicrophoneCaptureManager.swift
//  HandwritingToSpeechSwiftUI
//
//  Manages microphone audio capture for STT transcription.
//  Captures PCM audio at 24kHz, Int16, Mono format for Gradium STT.
//  Created by CalliVox on 2026-01-26.
//

import Foundation
import AVFoundation

/// Manages microphone audio capture for speech-to-text transcription.
/// Captures audio in 80ms chunks (1920 samples at 24kHz) as required by Gradium STT.
///
/// Usage:
/// ```swift
/// let capture = MicrophoneCaptureManager()
/// capture.onAudioChunk = { data in
///     // Send data to STT provider
/// }
/// let granted = await capture.requestPermission()
/// if granted {
///     try capture.startCapture()
/// }
/// ```
@MainActor
class MicrophoneCaptureManager: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var isCapturing = false
    @Published private(set) var permissionGranted = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""

    // MARK: - Callback

    /// Called when a new audio chunk is ready (PCM Int16, 24kHz, Mono, base64 encoded)
    var onAudioChunk: ((Data) -> Void)?

    // MARK: - Private Properties

    private var audioEngine: AVAudioEngine?
    private let targetSampleRate = AppConfig.STT.sampleRate
    private let chunkSamples = AppConfig.STT.chunkSamples

    /// Buffer to accumulate samples for consistent chunk sizes
    private var sampleBuffer: [Int16] = []
    private let bufferLock = NSLock()

    // MARK: - Initialization

    init() {
        checkPermissionStatus()
    }

    deinit {
        // Cannot call @MainActor method from deinit, so cleanup synchronously
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil
    }

    // MARK: - Permission

    /// Checks current microphone permission status
    private func checkPermissionStatus() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            permissionGranted = true
        case .denied, .undetermined:
            permissionGranted = false
        @unknown default:
            permissionGranted = false
        }
    }

    /// Requests microphone permission.
    /// - Returns: true if permission is granted
    func requestPermission() async -> Bool {
        let status = AVAudioApplication.shared.recordPermission

        switch status {
        case .granted:
            permissionGranted = true
            return true

        case .undetermined:
            let granted = await AVAudioApplication.requestRecordPermission()
            permissionGranted = granted
            return granted

        case .denied:
            permissionGranted = false
            return false

        @unknown default:
            permissionGranted = false
            return false
        }
    }

    // MARK: - Capture Control

    /// Starts capturing audio from the microphone.
    /// - Throws: STTError if capture cannot be started
    func startCapture() throws {
        guard permissionGranted else {
            throw STTError.permissionDenied
        }

        guard !isCapturing else { return }

        // Configure audio session for recording
        try configureAudioSession()

        // Create and configure audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw STTError.audioCaptureFailed(underlying: NSError(
                domain: "MicrophoneCaptureManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Impossible de créer le moteur audio"]
            ))
        }

        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        // Install tap on input node
        // Note: iOS may provide a different sample rate, so we'll resample if needed
        inputNode.installTap(onBus: 0, bufferSize: AVAudioFrameCount(chunkSamples * 2), format: inputFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer, inputSampleRate: inputFormat.sampleRate)
        }

        // Start the engine
        audioEngine.prepare()
        try audioEngine.start()

        isCapturing = true
        sampleBuffer.removeAll()
        print("MicrophoneCaptureManager: Capture started at \(inputFormat.sampleRate)Hz")
    }

    /// Stops audio capture.
    func stopCapture() {
        guard isCapturing else { return }

        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine?.stop()
        audioEngine = nil

        isCapturing = false
        sampleBuffer.removeAll()

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        print("MicrophoneCaptureManager: Capture stopped")
    }

    // MARK: - Private Methods

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
        try session.setPreferredSampleRate(targetSampleRate)
        try session.setActive(true)
    }

    /// Processes audio buffer from the tap, resamples if needed, and emits chunks.
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer, inputSampleRate: Double) {
        guard let channelData = buffer.floatChannelData else { return }

        let frameCount = Int(buffer.frameLength)
        let samples = channelData[0]

        // Convert to Int16 and resample if needed
        var int16Samples: [Int16] = []

        if inputSampleRate != targetSampleRate {
            // Simple resampling by linear interpolation
            let ratio = inputSampleRate / targetSampleRate
            let outputCount = Int(Double(frameCount) / ratio)

            for i in 0..<outputCount {
                let srcIndex = Double(i) * ratio
                let srcIndexInt = Int(srcIndex)
                let frac = Float(srcIndex - Double(srcIndexInt))

                let sample0 = samples[min(srcIndexInt, frameCount - 1)]
                let sample1 = samples[min(srcIndexInt + 1, frameCount - 1)]
                let interpolated = sample0 + frac * (sample1 - sample0)

                // Convert Float32 [-1, 1] to Int16
                let int16Value = Int16(max(-32768, min(32767, interpolated * 32767)))
                int16Samples.append(int16Value)
            }
        } else {
            // Direct conversion without resampling
            for i in 0..<frameCount {
                let int16Value = Int16(max(-32768, min(32767, samples[i] * 32767)))
                int16Samples.append(int16Value)
            }
        }

        // Add to buffer and emit chunks
        bufferLock.lock()
        sampleBuffer.append(contentsOf: int16Samples)

        // Emit complete chunks
        while sampleBuffer.count >= chunkSamples {
            let chunk = Array(sampleBuffer.prefix(chunkSamples))
            sampleBuffer.removeFirst(chunkSamples)
            bufferLock.unlock()

            // Convert to Data
            let chunkData = chunk.withUnsafeBufferPointer { buffer in
                Data(buffer: buffer)
            }

            // Emit on main thread
            DispatchQueue.main.async { [weak self] in
                self?.onAudioChunk?(chunkData)
            }

            bufferLock.lock()
        }
        bufferLock.unlock()
    }

    private func handleError(_ error: Error) {
        let sttError: STTError

        if let existing = error as? STTError {
            sttError = existing
        } else {
            sttError = .audioCaptureFailed(underlying: error)
        }

        if let suggestion = sttError.recoverySuggestion {
            errorMessage = "\(sttError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = sttError.localizedDescription
        }

        showError = true
        isCapturing = false

        print("MicrophoneCaptureManager Error: \(sttError.failureReason ?? "unknown")")
    }
}
