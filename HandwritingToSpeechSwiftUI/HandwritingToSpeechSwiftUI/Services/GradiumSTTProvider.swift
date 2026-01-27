//
//  GradiumSTTProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Gradium STT API client implementation using WebSocket.
//  Connects to Gradium STT service for real-time speech transcription.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Events received from the Gradium STT WebSocket.
enum STTEvent: Equatable {
    /// Service is ready to receive audio
    case ready(requestId: String, sampleRate: Int)

    /// Transcribed text segment
    case text(String, startTime: Double)

    /// End of a text segment
    case endText(stopTime: Double)

    /// VAD step with predictions
    case step(vadPredictions: [VADPrediction])

    /// End of stream received
    case endOfStream

    /// Error from the service
    case error(String)
}

/// Voice Activity Detection prediction from Gradium.
struct VADPrediction: Equatable {
    let horizonS: Double
    let inactivityProb: Float
}

/// Gradium STT API client implementation using WebSocket.
/// Connects to Gradium STT service and streams transcriptions in real-time.
///
/// Usage:
/// ```swift
/// let provider = GradiumSTTProvider()
/// try await provider.connect()
/// for try await event in provider.eventStream() {
///     switch event {
///     case .text(let text, _): print("Transcription: \(text)")
///     case .step(let vad): // process VAD
///     }
/// }
/// ```
@MainActor
class GradiumSTTProvider: ObservableObject {

    // MARK: - Published Properties

    @Published private(set) var isConnected = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""

    // MARK: - Private Properties

    private var webSocketTask: URLSessionWebSocketTask?
    private var eventContinuation: AsyncThrowingStream<STTEvent, Error>.Continuation?
    private var receiveTask: Task<Void, Never>?

    // MARK: - Initialization

    init() {}

    deinit {
        receiveTask?.cancel()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    // MARK: - Public Methods

    /// Connects to Gradium STT WebSocket and performs handshake.
    /// - Throws: STTError if connection fails
    func connect() async throws {
        // Get API key from Keychain
        let apiKey = try getAPIKey()

        guard let url = URL(string: AppConfig.STT.apiEndpoint) else {
            throw STTError.connectionFailed(message: "URL WebSocket invalide")
        }

        // Create WebSocket request with API key header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = AppConfig.Gradium.timeout

        // Create and start WebSocket task
        webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask?.resume()

        do {
            // Send setup message
            let setupMessage = try buildSetupMessage()
            try await webSocketTask?.send(.string(setupMessage))
            print("GradiumSTTProvider: Setup message sent")

            // Wait for ready message
            try await waitForReady()
            isConnected = true
            print("GradiumSTTProvider: Connected and ready")

        } catch {
            webSocketTask?.cancel(with: .abnormalClosure, reason: nil)
            webSocketTask = nil
            throw error
        }
    }

    /// Returns an async stream of STT events.
    /// Must be called after connect().
    func eventStream() -> AsyncThrowingStream<STTEvent, Error> {
        AsyncThrowingStream { continuation in
            self.eventContinuation = continuation

            let task = Task {
                await self.receiveMessages(continuation: continuation)
            }
            self.receiveTask = task

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }

    /// Sends an audio chunk to the STT service.
    /// - Parameter audioData: PCM audio data (Int16, 24kHz, Mono)
    func sendAudioChunk(_ audioData: Data) async throws {
        guard let webSocketTask = webSocketTask, isConnected else {
            throw STTError.connectionFailed(message: "Non connecté au service STT")
        }

        // Base64 encode the audio data
        let base64Audio = audioData.base64EncodedString()

        let audioMessage: [String: Any] = [
            "type": "audio",
            "audio": base64Audio
        ]

        let jsonData = try JSONSerialization.data(withJSONObject: audioMessage)
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw STTError.apiError(statusCode: 0, message: "Erreur d'encodage audio")
        }

        try await webSocketTask.send(.string(jsonString))
    }

    /// Disconnects from the STT service gracefully.
    func disconnect() async {
        guard let webSocketTask = webSocketTask else { return }

        // Send end of stream message
        let endMessage = "{\"type\":\"end_of_stream\"}"
        try? await webSocketTask.send(.string(endMessage))

        // Close WebSocket
        webSocketTask.cancel(with: .normalClosure, reason: nil)
        self.webSocketTask = nil
        isConnected = false
        eventContinuation?.finish()
        eventContinuation = nil

        print("GradiumSTTProvider: Disconnected")
    }

    // MARK: - Private Methods

    private func getAPIKey() throws -> String {
        do {
            let data = try KeychainManager.load(key: AppConfig.STT.keychainKey)
            guard let apiKey = String(data: data, encoding: .utf8), !apiKey.isEmpty else {
                throw STTError.invalidApiKey
            }
            return apiKey
        } catch {
            throw STTError.invalidApiKey
        }
    }

    private func buildSetupMessage() throws -> String {
        let setup: [String: Any] = [
            "type": "setup",
            "model_name": AppConfig.STT.modelName,
            "input_format": AppConfig.STT.inputFormat
        ]

        let data = try JSONSerialization.data(withJSONObject: setup)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw STTError.apiError(statusCode: 0, message: "Erreur de sérialisation JSON setup")
        }
        return jsonString
    }

    private func waitForReady() async throws {
        guard let webSocketTask = webSocketTask else {
            throw STTError.connectionFailed(message: "WebSocket non initialisé")
        }

        let message = try await webSocketTask.receive()

        switch message {
        case .string(let text):
            if let jsonData = text.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                // Check for error response
                if let errorMsg = json["message"] as? String, json["code"] != nil {
                    throw STTError.apiError(statusCode: json["code"] as? Int ?? 0, message: errorMsg)
                }

                // Check for ready message
                if let type = json["type"] as? String, type == "ready" {
                    return
                }

                throw STTError.connectionFailed(message: "Message inattendu: \(text)")
            }
            throw STTError.connectionFailed(message: "Réponse invalide")

        case .data:
            throw STTError.connectionFailed(message: "Données binaires inattendues")

        @unknown default:
            throw STTError.connectionFailed(message: "Type de message inconnu")
        }
    }

    private func receiveMessages(continuation: AsyncThrowingStream<STTEvent, Error>.Continuation) async {
        guard let webSocketTask = webSocketTask else { return }

        while !Task.isCancelled {
            do {
                let message = try await webSocketTask.receive()

                switch message {
                case .string(let text):
                    if let event = parseMessage(text) {
                        continuation.yield(event)

                        // End stream on endOfStream event
                        if case .endOfStream = event {
                            continuation.finish()
                            return
                        }

                        // End stream on error event
                        if case .error(let msg) = event {
                            continuation.finish(throwing: STTError.apiError(statusCode: 0, message: msg))
                            return
                        }
                    }

                case .data:
                    // Unexpected binary data
                    print("GradiumSTTProvider: Unexpected binary data received")

                @unknown default:
                    break
                }

            } catch {
                let nsError = error as NSError
                // Normal closure
                if nsError.domain == NSPOSIXErrorDomain && nsError.code == 57 {
                    continuation.finish()
                    return
                }
                continuation.finish(throwing: mapWebSocketError(error))
                return
            }
        }

        continuation.finish()
    }

    private func parseMessage(_ text: String) -> STTEvent? {
        guard let jsonData = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let type = json["type"] as? String else {
            return nil
        }

        switch type {
        case "ready":
            let requestId = json["request_id"] as? String ?? ""
            let sampleRate = json["sample_rate"] as? Int ?? 24000
            return .ready(requestId: requestId, sampleRate: sampleRate)

        case "text":
            let text = json["text"] as? String ?? ""
            let startS = json["start_s"] as? Double ?? 0
            return .text(text, startTime: startS)

        case "end_text":
            let stopS = json["stop_s"] as? Double ?? 0
            return .endText(stopTime: stopS)

        case "step":
            var predictions: [VADPrediction] = []
            if let vadArray = json["vad"] as? [[String: Any]] {
                for vad in vadArray {
                    let horizonS = vad["horizon_s"] as? Double ?? 0
                    let inactivityProb = vad["inactivity_prob"] as? Double ?? 0
                    predictions.append(VADPrediction(
                        horizonS: horizonS,
                        inactivityProb: Float(inactivityProb)
                    ))
                }
            }
            return .step(vadPredictions: predictions)

        case "end_of_stream":
            return .endOfStream

        case "error":
            let message = json["message"] as? String ?? "Erreur inconnue"
            return .error(message)

        default:
            print("GradiumSTTProvider: Unknown message type: \(type)")
            return nil
        }
    }

    private func mapWebSocketError(_ error: Error) -> STTError {
        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .networkUnavailable
        case NSURLErrorUserAuthenticationRequired:
            return .invalidApiKey
        default:
            return .connectionFailed(message: error.localizedDescription)
        }
    }

    @MainActor
    private func handleError(_ error: Error) {
        let sttError: STTError

        if let existing = error as? STTError {
            sttError = existing
        } else if (error as NSError).code == NSURLErrorTimedOut {
            sttError = .timeout
        } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            sttError = .networkUnavailable
        } else {
            sttError = .connectionFailed(message: error.localizedDescription)
        }

        if let suggestion = sttError.recoverySuggestion {
            errorMessage = "\(sttError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = sttError.localizedDescription
        }

        showError = true
        isConnected = false

        print("GradiumSTTProvider Error: \(sttError.failureReason ?? "unknown") - \(errorMessage)")
    }
}
