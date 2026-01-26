//
//  GradiumTTSProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by CalliVox on 2026-01-25.
//

import Foundation

/// Gradium TTS API client implementation.
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

        // Build request
        let request = try buildRequest(text: text, voice: voice, apiKey: apiKey)

        // Return streaming response with proper error propagation
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    try await self.performStreamingRequest(request: request, continuation: continuation)
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

    private func buildRequest(text: String, voice: String, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: AppConfig.Gradium.apiEndpoint) else {
            throw TTSError.apiError(statusCode: 0, message: "URL invalide")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = AppConfig.Gradium.timeout

        let body: [String: Any] = [
            "text": text,
            "voice_id": voice,
            "output_format": AppConfig.Gradium.outputFormat
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw TTSError.apiError(statusCode: 0, message: "Erreur de serialisation JSON")
        }

        return request
    }

    private func performStreamingRequest(
        request: URLRequest,
        continuation: AsyncThrowingStream<Data, Error>.Continuation
    ) async throws {
        let (bytes, response) = try await URLSession.shared.bytes(for: request)

        // Validate HTTP response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw TTSError.apiError(statusCode: 0, message: "Réponse invalide")
        }

        // Handle HTTP errors
        try validateHTTPResponse(httpResponse)

        // Stream data chunks
        var buffer = Data()
        let chunkSize = AppConfig.Gradium.streamingChunkSize

        for try await byte in bytes {
            buffer.append(byte)

            // Yield chunks of data for streaming playback
            if buffer.count >= chunkSize {
                continuation.yield(buffer)
                buffer = Data()
            }
        }

        // Yield remaining data
        if !buffer.isEmpty {
            continuation.yield(buffer)
        }

        continuation.finish()
    }

    private func validateHTTPResponse(_ response: HTTPURLResponse) throws {
        guard (200...299).contains(response.statusCode) else {
            switch response.statusCode {
            case 401:
                throw TTSError.invalidApiKey
            case 429:
                throw TTSError.rateLimited
            case 408:
                throw TTSError.timeout
            default:
                throw TTSError.apiError(
                    statusCode: response.statusCode,
                    message: HTTPURLResponse.localizedString(forStatusCode: response.statusCode)
                )
            }
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
