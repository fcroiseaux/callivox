//
//  InterlocutorListeningService.swift
//  HandwritingToSpeechSwiftUI
//
//  Orchestrates interlocutor speech listening: microphone capture → STT → VAD → LLM suggestions.
//  Created by CalliVox on 2026-01-26.
//

import Foundation
import Combine

/// Service that orchestrates listening to the interlocutor's speech.
/// Manages the flow: microphone capture → Gradium STT → VAD detection → LLM suggestions.
///
/// Usage:
/// ```swift
/// let service = InterlocutorListeningService.shared
/// await service.startListening()
/// // Observe service.currentTranscription for live updates
/// // Suggestions appear in SuggestionService.shared when speech ends
/// ```
@MainActor
class InterlocutorListeningService: ObservableObject {

    // MARK: - Singleton

    static let shared = InterlocutorListeningService()

    // MARK: - Published Properties

    /// Whether the service is actively listening
    @Published private(set) var isListening = false

    /// Current transcription being built from speech
    @Published private(set) var currentTranscription = ""

    /// Whether suggestions are being generated after speech ended
    @Published private(set) var isProcessingSuggestions = false

    /// Whether the listening toggle is enabled by user
    @Published var listeningEnabled = true

    /// Error display
    @Published var showError = false
    @Published var errorMessage = ""

    // MARK: - Dependencies

    private let sttProvider = GradiumSTTProvider()
    private let micCapture = MicrophoneCaptureManager()
    private let suggestionService = SuggestionService.shared

    // MARK: - VAD State

    /// Timestamp of last detected speech activity
    private var lastSpeechTime: Date?

    /// Timer task for detecting end of speech
    private var silenceTimerTask: Task<Void, Never>?

    /// Task for processing STT events
    private var eventProcessingTask: Task<Void, Never>?

    /// Task for sending audio chunks
    private var audioSendTask: Task<Void, Never>?

    /// Accumulated VAD predictions for smoothing
    private var recentInactivityProbs: [Float] = []
    private let vadSmoothingWindow = 5

    // MARK: - Initialization

    private init() {
        setupMicrophoneCallback()
    }

    // MARK: - Public Methods

    /// Starts listening to the interlocutor's speech.
    /// Requests microphone permission if needed, then starts capture and STT.
    func startListening() async {
        guard listeningEnabled else {
            print("InterlocutorListeningService: Listening is disabled")
            return
        }

        guard !isListening else {
            print("InterlocutorListeningService: Already listening")
            return
        }

        // Check network availability
        guard NetworkMonitor.shared.isConnected else {
            handleError(STTError.networkUnavailable)
            return
        }

        // Request microphone permission
        let permissionGranted = await micCapture.requestPermission()
        guard permissionGranted else {
            handleError(STTError.permissionDenied)
            return
        }

        do {
            // Connect to STT service
            try await sttProvider.connect()

            // Start microphone capture
            try micCapture.startCapture()

            // Start processing STT events
            startEventProcessing()

            isListening = true
            currentTranscription = ""
            lastSpeechTime = Date()

            print("InterlocutorListeningService: Started listening")

        } catch {
            handleError(error)
            cleanup()
        }
    }

    /// Stops listening and cleans up resources.
    func stopListening() {
        guard isListening else { return }

        cleanup()
        isListening = false

        print("InterlocutorListeningService: Stopped listening")
    }

    /// Toggles listening state.
    func toggleListening() async {
        if isListening {
            stopListening()
        } else {
            await startListening()
        }
    }

    /// Clears the current transcription without stopping listening.
    func clearTranscription() {
        currentTranscription = ""
    }

    // MARK: - Private Methods

    private func setupMicrophoneCallback() {
        micCapture.onAudioChunk = { [weak self] audioData in
            Task { @MainActor in
                await self?.sendAudioChunk(audioData)
            }
        }
    }

    private func sendAudioChunk(_ audioData: Data) async {
        guard isListening else { return }

        do {
            try await sttProvider.sendAudioChunk(audioData)
        } catch {
            print("InterlocutorListeningService: Error sending audio chunk: \(error)")
        }
    }

    private func startEventProcessing() {
        eventProcessingTask = Task {
            do {
                for try await event in sttProvider.eventStream() {
                    await processSTTEvent(event)
                }
            } catch {
                await MainActor.run {
                    if self.isListening {
                        self.handleError(error)
                        self.cleanup()
                    }
                }
            }
        }
    }

    private func processSTTEvent(_ event: STTEvent) async {
        switch event {
        case .ready:
            print("InterlocutorListeningService: STT ready")

        case .text(let text, _):
            // Update transcription with new text
            if !text.isEmpty {
                if currentTranscription.isEmpty {
                    currentTranscription = text
                } else {
                    currentTranscription += " " + text
                }
                lastSpeechTime = Date()
                print("InterlocutorListeningService: Transcription: \(text)")
            }

        case .endText:
            // Text segment ended, but speaker may continue
            print("InterlocutorListeningService: Text segment ended")

        case .step(let vadPredictions):
            handleVADPredictions(vadPredictions)

        case .endOfStream:
            print("InterlocutorListeningService: End of stream")
            if !currentTranscription.isEmpty {
                await onSpeechEnded()
            }

        case .error(let message):
            handleError(STTError.apiError(statusCode: 0, message: message))
            cleanup()
        }
    }

    private func handleVADPredictions(_ predictions: [VADPrediction]) {
        guard !predictions.isEmpty else { return }

        // Get the last prediction (most recent)
        let lastPrediction = predictions.last!

        // Add to smoothing window
        recentInactivityProbs.append(lastPrediction.inactivityProb)
        if recentInactivityProbs.count > vadSmoothingWindow {
            recentInactivityProbs.removeFirst()
        }

        // Calculate smoothed inactivity probability
        let avgInactivity = recentInactivityProbs.reduce(0, +) / Float(recentInactivityProbs.count)

        // Check if speech has likely ended
        if avgInactivity > AppConfig.STT.vadInactivityThreshold {
            // High inactivity - start/continue silence timer
            startSilenceTimer()
        } else {
            // Speech detected - cancel silence timer
            cancelSilenceTimer()
            lastSpeechTime = Date()
        }
    }

    private func startSilenceTimer() {
        // Don't start a new timer if one is already running
        guard silenceTimerTask == nil else { return }

        silenceTimerTask = Task {
            // Wait for the configured silence duration
            try? await Task.sleep(for: .seconds(AppConfig.STT.silenceDuration))

            guard !Task.isCancelled else { return }

            await MainActor.run {
                // Check if we still have transcription and are still listening
                if self.isListening && !self.currentTranscription.isEmpty {
                    Task {
                        await self.onSpeechEnded()
                    }
                }
            }
        }
    }

    private func cancelSilenceTimer() {
        silenceTimerTask?.cancel()
        silenceTimerTask = nil
    }

    private func onSpeechEnded() async {
        guard !currentTranscription.isEmpty else { return }

        let transcription = currentTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
        print("InterlocutorListeningService: Speech ended with transcription: \(transcription)")

        // Stop listening
        stopListening()

        // Generate suggestions from transcription
        isProcessingSuggestions = true

        // Add to conversation history and generate suggestions
        suggestionService.addToHistory(userMessage: transcription)
        await suggestionService.generateSuggestions(for: transcription)

        isProcessingSuggestions = false
        currentTranscription = ""
    }

    private func cleanup() {
        // Cancel all tasks
        eventProcessingTask?.cancel()
        eventProcessingTask = nil

        audioSendTask?.cancel()
        audioSendTask = nil

        cancelSilenceTimer()

        // Stop microphone capture
        micCapture.stopCapture()

        // Disconnect STT
        Task {
            await sttProvider.disconnect()
        }

        // Reset VAD state
        recentInactivityProbs.removeAll()
        lastSpeechTime = nil

        isListening = false
    }

    private func handleError(_ error: Error) {
        let sttError: STTError

        if let existing = error as? STTError {
            sttError = existing
        } else {
            sttError = .connectionFailed(message: error.localizedDescription)
        }

        if let suggestion = sttError.recoverySuggestion {
            errorMessage = "\(sttError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = sttError.localizedDescription
        }

        showError = true
        isListening = false
        isProcessingSuggestions = false

        print("InterlocutorListeningService Error: \(sttError.failureReason ?? "unknown")")
    }

    /// Dismisses the current error
    func dismissError() {
        showError = false
        errorMessage = ""
    }
}
