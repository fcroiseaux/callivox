//
//  LLMError.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 3.1: LLM Service Integration
//  Created by CalliVox on 2026-01-26.
//

import Foundation

/// Error types for LLM (Large Language Model) operations.
/// Implements LocalizedError with French error descriptions for user-facing messages.
///
/// Usage:
/// ```swift
/// throw LLMError.invalidApiKey
/// // User sees: "Clé API LLM invalide ou manquante"
/// // Recovery: "Vérifiez votre clé API dans Réglages > Service IA."
/// ```
enum LLMError: LocalizedError {

    /// API key is missing or invalid in Keychain
    case invalidApiKey

    /// Network connection is unavailable
    case networkUnavailable

    /// API returned an error response with status code and message
    case apiError(statusCode: Int, message: String)

    /// Too many requests - rate limited by the API (HTTP 429)
    case rateLimited

    /// Request timed out (HTTP 408 or timeout interval exceeded)
    case timeout

    /// Response format is invalid or cannot be parsed
    case invalidResponse

    // MARK: - LocalizedError Protocol (AC2, AC3)

    /// French localized error descriptions for user display
    var errorDescription: String? {
        switch self {
        case .invalidApiKey:
            return "Clé API LLM invalide ou manquante"
        case .networkUnavailable:
            return "Connexion internet indisponible"
        case .apiError(let statusCode, let message):
            return "Erreur du service IA (code \(statusCode)): \(message)"
        case .rateLimited:
            return "Trop de requêtes, veuillez patienter"
        case .timeout:
            return "Connexion au service IA lente ou indisponible"
        case .invalidResponse:
            return "Réponse invalide du service IA"
        }
    }

    /// Failure reason for debugging (English)
    var failureReason: String? {
        switch self {
        case .invalidApiKey:
            return "LLM API key not found in Keychain or invalid"
        case .networkUnavailable:
            return "No network connection available"
        case .apiError(let statusCode, _):
            return "HTTP status code: \(statusCode)"
        case .rateLimited:
            return "HTTP 429 - Rate limit exceeded"
        case .timeout:
            return "Request exceeded timeout interval"
        case .invalidResponse:
            return "Failed to parse LLM response JSON"
        }
    }

    /// Suggested recovery action (French) - AC2, AC3: Guide user to resolution
    var recoverySuggestion: String? {
        switch self {
        case .invalidApiKey:
            return "Vérifiez votre clé API dans Réglages > Service IA."
        case .networkUnavailable:
            return "Vérifiez votre connexion internet."
        case .apiError:
            return "Réessayez dans quelques instants."
        case .rateLimited:
            return "Attendez quelques secondes avant de réessayer."
        case .timeout:
            return "Vérifiez votre connexion. Les suggestions IA sont temporairement indisponibles."
        case .invalidResponse:
            return "Le service IA a renvoyé une réponse inattendue. Réessayez."
        }
    }
}
