//
//  STTError.swift
//  HandwritingToSpeechSwiftUI
//
//  Speech-to-Text error types for interlocutor transcription.
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Error types for Speech-to-Text operations.
/// Implements LocalizedError with French error descriptions for user-facing messages.
enum STTError: LocalizedError {

    /// Network connection is unavailable
    case networkUnavailable

    /// WebSocket connection failed
    case connectionFailed(message: String)

    /// API returned an error response
    case apiError(statusCode: Int, message: String)

    /// Audio capture failed
    case audioCaptureFailed(underlying: Error)

    /// Microphone permission denied
    case permissionDenied

    /// API key is missing or invalid
    case invalidApiKey

    /// Request timed out
    case timeout

    /// French localized error descriptions for user display
    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "Connexion internet indisponible"
        case .connectionFailed(let message):
            return "Connexion au service de transcription échouée: \(message)"
        case .apiError(let code, let message):
            return "Erreur du service de transcription (\(code)): \(message)"
        case .audioCaptureFailed(let underlying):
            return "Erreur de capture audio: \(underlying.localizedDescription)"
        case .permissionDenied:
            return "Accès au microphone refusé"
        case .invalidApiKey:
            return "Clé API invalide. Veuillez vérifier votre configuration."
        case .timeout:
            return "Connexion lente ou indisponible"
        }
    }

    /// Failure reason for debugging
    var failureReason: String? {
        switch self {
        case .networkUnavailable:
            return "No network connection available"
        case .connectionFailed(let message):
            return "WebSocket connection failed: \(message)"
        case .apiError(let code, _):
            return "HTTP status code: \(code)"
        case .audioCaptureFailed(let underlying):
            return "Audio capture error: \(underlying)"
        case .permissionDenied:
            return "Microphone permission not granted"
        case .invalidApiKey:
            return "API key not found in Keychain or invalid"
        case .timeout:
            return "Request exceeded timeout interval"
        }
    }

    /// Suggested recovery action
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return "Vérifiez votre connexion internet et réessayez."
        case .connectionFailed:
            return "Vérifiez votre connexion et réessayez."
        case .apiError:
            return "Si le problème persiste, contactez le support."
        case .audioCaptureFailed:
            return "Fermez et rouvrez l'application."
        case .permissionDenied:
            return "Allez dans Réglages > Confidentialité > Microphone pour autoriser l'accès."
        case .invalidApiKey:
            return "Allez dans Paramètres pour configurer votre clé API Gradium."
        case .timeout:
            return "Vérifiez votre connexion et réessayez."
        }
    }
}
