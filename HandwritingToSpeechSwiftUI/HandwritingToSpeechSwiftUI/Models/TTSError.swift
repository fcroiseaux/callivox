//
//  TTSError.swift
//  HandwritingToSpeechSwiftUI
//
//  Created by CalliVox on 2026-01-25.
//

import Foundation

/// Error types for Text-to-Speech operations.
/// Implements LocalizedError with French error descriptions for user-facing messages.
enum TTSError: LocalizedError {

    /// Network connection is unavailable
    case networkUnavailable

    /// API returned an error response
    case apiError(statusCode: Int, message: String)

    /// Audio playback failed
    case audioPlaybackFailed(underlying: Error)

    /// API key is missing or invalid
    case invalidApiKey

    /// Too many requests - rate limited by the API
    case rateLimited

    /// Request timed out
    case timeout

    /// French localized error descriptions for user display
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Connexion internet indisponible"
        case .apiError(let code, let message):
            return "Erreur du service vocal (\(code)): \(message)"
        case .audioPlaybackFailed(let underlying):
            return "Erreur de lecture audio: \(underlying.localizedDescription)"
        case .invalidApiKey:
            return "Clé API invalide. Veuillez vérifier votre configuration."
        case .rateLimited:
            return "Trop de requêtes. Veuillez patienter quelques instants."
        case .timeout:
            return "Connexion lente ou indisponible"
        }
    }

    /// Failure reason for debugging
    var failureReason: String? {
        switch self {
        case .networkUnavailable:
            return "No network connection available"
        case .apiError(let code, _):
            return "HTTP status code: \(code)"
        case .audioPlaybackFailed(let underlying):
            return "Audio error: \(underlying)"
        case .invalidApiKey:
            return "API key not found in Keychain or invalid"
        case .rateLimited:
            return "HTTP 429 - Rate limit exceeded"
        case .timeout:
            return "Request exceeded timeout interval"
        }
    }

    /// Suggested recovery action
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Vérifiez votre connexion internet et réessayez."
        case .apiError:
            return "Si le problème persiste, contactez le support."
        case .audioPlaybackFailed:
            return "Fermez et rouvrez l'application."
        case .invalidApiKey:
            return "Allez dans Paramètres pour configurer votre clé API Gradium."
        case .rateLimited:
            return "Attendez quelques secondes avant de réessayer."
        case .timeout:
            return "Vérifiez votre connexion et réessayez."
        }
    }
}
