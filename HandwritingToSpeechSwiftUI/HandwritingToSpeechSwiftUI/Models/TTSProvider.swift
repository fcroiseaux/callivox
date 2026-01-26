//
//  TTSProvider.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by CalliVox on 2026-01-25.
//

import Foundation

/// Protocol abstraction for Text-to-Speech providers.
/// Enables switching between Gradium TTS, Kyutai self-hosted, and future providers
/// without changing the service layer interface.
///
/// Implementations must handle:
/// - Secure API key retrieval from Keychain
/// - Network availability checking before API calls
/// - Streaming PCM audio data via AsyncThrowingStream
/// - French localized error messages via TTSError
protocol TTSProvider {

    /// Synthesizes text to speech and returns streaming PCM audio data.
    ///
    /// - Parameters:
    ///   - text: The text to convert to speech
    ///   - voice: The voice identifier to use (e.g., "olivier" for French)
    ///
    /// - Returns: An AsyncThrowingStream of Data chunks containing PCM audio (24kHz, Int16, Mono).
    ///            Errors during streaming (network issues, API errors) are thrown through the stream.
    ///
    /// - Throws: TTSError if synthesis setup fails (network unavailable, invalid API key, etc.)
    func synthesize(text: String, voice: String) async throws -> AsyncThrowingStream<Data, Error>
}
