//
//  GradiumTTSProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by CalliVox on 2026-01-25.
//

import Foundation

/// Gradium TTS API client implementation using WebSocket.
/// Connects to Gradium TTS service and returns streaming PCM audio data.
///
/// Note: Network availability should be checked by the caller (SpeechService)
/// before invoking synthesize(). Network errors during the request are
/// properly mapped to TTSError.networkUnavailable in error handling.
///
/// Usage:
/// ```swift
/// let provider = GradiumTTSProvider()
/// let audioStream = try await provider.synthesize(text: "Bonjour", voice: "olivier")
/// for try await chunk in audioStream {
///     // Process PCM audio chunk
/// }
/// ```
@MainActor
class GradiumTTSProvider: ObservableObject, TTSProvider {

    // MARK: - Published Properties
    // Note: These properties are used internally for error state tracking.
    // UI display is handled by SpeechService which catches errors from the AsyncThrowingStream.

    @Published private(set) var isLoading = false
    @Published private(set) var showError = false
    @Published private(set) var errorMessage = ""

    // MARK: - Private Properties

    private let keychainKey = AppConfig.Gradium.keychainKey

    // MARK: - Initialization

    init() {
        // No initialization needed - network checks delegated to caller (SpeechService)
    }

    // MARK: - TTSProvider Protocol

    func synthesize(text: String, voice: String) async throws -> AsyncThrowingStream<Data, Error> {
        // Get API key from Keychain
        let apiKey = try getAPIKey()

        // Return streaming response with proper error propagation
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    try await self.performWebSocketRequest(
                        text: text,
                        voice: voice,
                        apiKey: apiKey,
                        continuation: continuation
                    )
                } catch {
                    self.handleError(error)
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Private Methods

    private func getAPIKey() throws -> String {
        do {
            let data = try KeychainManager.load(key: keychainKey)
            guard let apiKey = String(data: data, encoding: .utf8), !apiKey.isEmpty else {
                throw TTSError.invalidApiKey
            }
            return apiKey
        } catch KeychainManager.KeychainError.unknown {
            throw TTSError.invalidApiKey
        } catch {
            throw TTSError.invalidApiKey
        }
    }

    private func performWebSocketRequest(
        text: String,
        voice: String,
        apiKey: String,
        continuation: AsyncThrowingStream<Data, Error>.Continuation
    ) async throws {
        guard let url = URL(string: AppConfig.Gradium.apiEndpoint) else {
            throw TTSError.apiError(statusCode: 0, message: "URL WebSocket invalide")
        }

        // Create WebSocket request with API key header
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = AppConfig.Gradium.timeout

        // Create WebSocket task
        let webSocketTask = URLSession.shared.webSocketTask(with: request)
        webSocketTask.resume()

        do {
            // Step 1: Send setup message
            let setupMessage = try buildSetupMessage(voice: voice)
            try await webSocketTask.send(.string(setupMessage))
            print("GradiumTTSProvider: Setup message sent")

            // Step 2: Wait for ready message
            try await waitForReady(webSocketTask: webSocketTask)
            print("GradiumTTSProvider: Ready message received")

            // Step 3: Send text message
            let textMessage = try buildTextMessage(text: text)
            try await webSocketTask.send(.string(textMessage))
            print("GradiumTTSProvider: Text message sent")

            // Step 4: Send end_of_stream message
            let endMessage = "{\"type\":\"end_of_stream\"}"
            try await webSocketTask.send(.string(endMessage))
            print("GradiumTTSProvider: End of stream message sent")

            // Step 5: Receive audio chunks
            try await receiveAudioChunks(webSocketTask: webSocketTask, continuation: continuation)

            // Close WebSocket gracefully
            webSocketTask.cancel(with: .normalClosure, reason: nil)
            continuation.finish()

        } catch {
            webSocketTask.cancel(with: .abnormalClosure, reason: nil)
            throw error
        }
    }

    private func buildSetupMessage(voice: String) throws -> String {
        let setup: [String: Any] = [
            "type": "setup",
            "voice_id": voice,
            "output_format": AppConfig.Gradium.outputFormat
        ]

        let data = try JSONSerialization.data(withJSONObject: setup)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw TTSError.apiError(statusCode: 0, message: "Erreur de serialisation JSON setup")
        }
        return jsonString
    }

    private func buildTextMessage(text: String) throws -> String {
        let textPayload: [String: Any] = [
            "type": "text",
            "text": text
        ]

        let data = try JSONSerialization.data(withJSONObject: textPayload)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw TTSError.apiError(statusCode: 0, message: "Erreur de serialisation JSON text")
        }
        return jsonString
    }

    private func waitForReady(webSocketTask: URLSessionWebSocketTask) async throws {
        let message = try await webSocketTask.receive()

        switch message {
        case .string(let text):
            if let jsonData = text.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                // Check for error response
                if let errorMsg = json["error"] as? String {
                    throw TTSError.apiError(statusCode: 0, message: errorMsg)
                }

                // Check for ready message
                if let type = json["type"] as? String, type == "ready" {
                    return
                }

                // Unexpected message type
                throw TTSError.apiError(statusCode: 0, message: "Message inattendu: \(text)")
            }
        case .data:
            throw TTSError.apiError(statusCode: 0, message: "Données binaires inattendues avant ready")
        @unknown default:
            throw TTSError.apiError(statusCode: 0, message: "Type de message inconnu")
        }
    }

    private func receiveAudioChunks(
        webSocketTask: URLSessionWebSocketTask,
        continuation: AsyncThrowingStream<Data, Error>.Continuation
    ) async throws {
        var buffer = Data()
        let chunkSize = AppConfig.Gradium.streamingChunkSize

        while true {
            let message: URLSessionWebSocketTask.Message
            do {
                message = try await webSocketTask.receive()
            } catch {
                // Connection closed or error
                let nsError = error as NSError
                if nsError.domain == NSPOSIXErrorDomain && nsError.code == 57 {
                    // Socket is not connected - normal end of stream
                    break
                }
                throw mapWebSocketError(error)
            }

            switch message {
            case .string(let text):
                // Parse JSON response
                if let jsonData = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {

                    let messageType = json["type"] as? String

                    // Check for error response
                    if messageType == "error" {
                        let errorMsg = json["message"] as? String ?? "Erreur inconnue"
                        throw TTSError.apiError(statusCode: 0, message: errorMsg)
                    }

                    // Check for audio data (base64 encoded)
                    if messageType == "audio",
                       let audioBase64 = json["audio"] as? String,
                       let audioData = Data(base64Encoded: audioBase64) {
                        buffer.append(audioData)
                        print("GradiumTTSProvider: Received audio chunk (\(audioData.count) bytes)")

                        // Yield chunks for streaming playback
                        while buffer.count >= chunkSize {
                            let chunk = buffer.prefix(chunkSize)
                            continuation.yield(Data(chunk))
                            buffer.removeFirst(chunkSize)
                        }
                    }

                    // Check for end of stream
                    if messageType == "end_of_stream" {
                        print("GradiumTTSProvider: End of stream received")
                        // Yield remaining buffer
                        if !buffer.isEmpty {
                            continuation.yield(buffer)
                        }
                        return
                    }
                }

            case .data(let data):
                // Direct binary audio data
                buffer.append(data)

                // Yield chunks for streaming playback
                while buffer.count >= chunkSize {
                    let chunk = buffer.prefix(chunkSize)
                    continuation.yield(Data(chunk))
                    buffer.removeFirst(chunkSize)
                }

            @unknown default:
                break
            }
        }

        // Yield remaining buffer at end
        if !buffer.isEmpty {
            continuation.yield(buffer)
        }
    }

    private func mapWebSocketError(_ error: Error) -> TTSError {
        let nsError = error as NSError

        switch nsError.code {
        case NSURLErrorTimedOut:
            return .timeout
        case NSURLErrorNotConnectedToInternet, NSURLErrorNetworkConnectionLost:
            return .networkUnavailable
        case NSURLErrorUserAuthenticationRequired:
            return .invalidApiKey
        default:
            return .apiError(statusCode: 0, message: error.localizedDescription)
        }
    }

    /// Story 2.3: Handle errors with French messages AND recovery suggestions
    /// Consistent with SpeechService.updateUIForGradiumError formatting
    @MainActor
    private func handleError(_ error: Error) {
        let ttsError: TTSError

        if let existing = error as? TTSError {
            ttsError = existing
        } else if (error as NSError).code == NSURLErrorTimedOut {
            ttsError = .timeout
        } else if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            ttsError = .networkUnavailable
        } else {
            ttsError = .apiError(statusCode: 0, message: error.localizedDescription)
        }

        // Story 2.3 AC1: Include both error description AND recovery suggestion
        if let suggestion = ttsError.recoverySuggestion {
            errorMessage = "\(ttsError.localizedDescription)\n\n\(suggestion)"
        } else {
            errorMessage = ttsError.localizedDescription
        }

        showError = true
        isLoading = false

        // Log error for debugging (AC5: never silent)
        print("GradiumTTSProvider Error: \(ttsError.failureReason ?? "unknown") - \(errorMessage)")
    }
}
