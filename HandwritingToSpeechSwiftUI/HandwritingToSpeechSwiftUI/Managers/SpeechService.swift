import Foundation
import AVFoundation
import SwiftUI

@MainActor
class SpeechService: ObservableObject {
    static let shared = SpeechService()
    
    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var lastSpokenText: String = ""
    @Published var elevenLabsAvailable: Bool = true
    @Published var useElevenLabs: Bool = false
    
    private var availabilityTimer: Timer?
    private var checkAvailabilityTask: Task<Void, Never>?
    private var currentSpeechTask: Task<Void, Never>?
    
    private let audioManager = AudioManager.shared
    private let elevenLabsApiKeyName = "elevenlabs_api_key"
    
    deinit {
        // Can't call MainActor-isolated methods directly from deinit
        availabilityTimer?.invalidate()
        checkAvailabilityTask?.cancel()
        currentSpeechTask?.cancel()
    }
    
    init() {
        setupDefaultAPIKey()
        setupAvailabilityTimer()
    }
    
    private func setupDefaultAPIKey() {
        // Only set the default key if no key exists in the keychain
        do {
            _ = try KeychainManager.load(key: elevenLabsApiKeyName)
        } catch {
            // No key exists, set the default
            if let apiKey = "sk_c1f7c99c2a688d720672d9517168cfadd83461ed118acf97".data(using: .utf8) {
                try? KeychainManager.save(key: elevenLabsApiKeyName, data: apiKey)
            }
        }
    }
    
    private func getAPIKey() -> String? {
        do {
            let data = try KeychainManager.load(key: elevenLabsApiKeyName)
            return String(data: data, encoding: .utf8)
        } catch {
            handleError("API key not found: \(error.localizedDescription)")
            return nil
        }
    }
    
    func updateAPIKey(_ apiKey: String) {
        guard !apiKey.isEmpty else {
            handleError("API key cannot be empty")
            return
        }
        
        if let data = apiKey.data(using: .utf8) {
            do {
                try KeychainManager.save(key: elevenLabsApiKeyName, data: data)
                // Test key after saving
                checkElevenLabsAvailability()
            } catch {
                handleError("Failed to save API key: \(error.localizedDescription)")
            }
        }
    }
    
    func setupAvailabilityTimer() {
        availabilityTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            // Use Task to ensure MainActor isolation is respected
            Task { @MainActor in
                self?.checkElevenLabsAvailability()
            }
        }
        // Use Task to ensure MainActor isolation is respected
        Task { @MainActor in
            checkElevenLabsAvailability()
        }
    }
    
    func stopAvailabilityTimer() {
        availabilityTimer?.invalidate()
        cancelAllTasks()
    }
    
    private func cancelAllTasks() {
        checkAvailabilityTask?.cancel()
        currentSpeechTask?.cancel()
        checkAvailabilityTask = nil
        currentSpeechTask = nil
    }
    
    func checkElevenLabsAvailability() {
        checkAvailabilityTask?.cancel()
        checkAvailabilityTask = Task {
            await checkElevenLabsAvailabilityAsync()
        }
    }
    
    private func checkElevenLabsAvailabilityAsync() async {
        guard !Task.isCancelled else { return }
        
        guard let apiKey = getAPIKey(), !apiKey.isEmpty else {
            elevenLabsAvailable = false
            useElevenLabs = false
            return
        }
        
        guard !Task.isCancelled, let url = URL(string: "https://api.elevenlabs.io/v1/voices") else {
            elevenLabsAvailable = false
            useElevenLabs = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        do {
            guard !Task.isCancelled else { return }
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard !Task.isCancelled else { return }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                elevenLabsAvailable = true
            } else {
                elevenLabsAvailable = false
                useElevenLabs = false
            }
        } catch {
            guard !Task.isCancelled else { return }
            print("Erreur de vérification ElevenLabs: \(error.localizedDescription)")
            elevenLabsAvailable = false
            useElevenLabs = false
        }
    }
    
    func speakText(_ text: String) {
        lastSpokenText = text
        isLoading = true
        
        print("SpeechService: Speaking text: '\(text)'")
        
        // Log the usage first
        print("SpeechService: Logging usage statistics...")
        UsageLogManager.shared.logSentenceUsage(text)
        
        // Then speak the text
        if useElevenLabs {
            print("SpeechService: Using ElevenLabs for TTS")
            speakTextElevenLabs(text)
        } else {
            print("SpeechService: Using native AVSpeechSynthesizer for TTS")
            speakTextNative(text)
        }
    }
    
    func speakTextNative(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        if audioManager.synthesizer.isSpeaking {
            audioManager.synthesizer.stopSpeaking(at: .immediate)
        }
        audioManager.synthesizer.speak(utterance)
        isLoading = false
    }
    
    // Enum to track and differentiate various network error types
    enum ElevenLabsError: Error, LocalizedError {
        case apiKeyMissing
        case invalidURL
        case networkError(String)
        case invalidResponse
        case authenticationError
        case rateLimitExceeded
        case serverError(Int)
        case noData
        case audioPlaybackError(String)
        case serializationError(String)
        
        var errorDescription: String? {
            switch self {
            case .apiKeyMissing:
                return "Clé API manquante ou invalide"
            case .invalidURL:
                return "URL invalide pour l'API ElevenLabs"
            case .networkError(let message):
                return "Erreur réseau: \(message)"
            case .invalidResponse:
                return "Réponse invalide du serveur"
            case .authenticationError:
                return "Erreur d'authentification: Vérifiez votre clé API"
            case .rateLimitExceeded:
                return "Limite d'utilisation ElevenLabs atteinte"
            case .serverError(let code):
                return "Erreur serveur ElevenLabs: \(code)"
            case .noData:
                return "Données audio manquantes dans la réponse"
            case .audioPlaybackError(let message):
                return "Erreur lecture audio: \(message)"
            case .serializationError(let message):
                return "Erreur de formatage des données: \(message)"
            }
        }
    }
    
    func speakTextElevenLabs(_ text: String) {
        currentSpeechTask?.cancel()
        currentSpeechTask = Task {
            await speakTextElevenLabsAsync(text)
        }
    }
    
    private func updateUIForElevenLabsError(_ error: Error) {
        let errorMessage: String
        
        if let elevenLabsError = error as? ElevenLabsError {
            errorMessage = elevenLabsError.errorDescription ?? error.localizedDescription
            
            // Update service availability if needed
            switch elevenLabsError {
            case .authenticationError, .serverError:
                elevenLabsAvailable = false
                useElevenLabs = false
            default:
                break
            }
        } else {
            errorMessage = ElevenLabsError.networkError(error.localizedDescription).errorDescription ?? "Erreur réseau"
        }
        
        handleError(errorMessage)
    }
    
    private func speakTextElevenLabsAsync(_ text: String) async {
        do {
            guard !Task.isCancelled else { return }
            let data = try await requestElevenLabsSpeech(text: text)
            
            guard !Task.isCancelled else { return }
            try await playAudioData(data)
            
            guard !Task.isCancelled else { return }
            isLoading = false
        } catch {
            guard !Task.isCancelled else { return }
            updateUIForElevenLabsError(error)
        }
    }
    
    private func requestElevenLabsSpeech(text: String) async throws -> Data {
        guard let apiKey = getAPIKey(), !apiKey.isEmpty else {
            throw ElevenLabsError.apiKeyMissing
        }
        
        guard let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/TuPaqVGqdYrU7SnpT92i/stream") else {
            throw ElevenLabsError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("3", forHTTPHeaderField: "x-retry-count")
        request.timeoutInterval = 15
        
        let body: [String: Any] = [
            "text": text,
            "model_id": "eleven_multilingual_v2"
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        
        // Using modern Swift concurrency for network requests
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // HTTP response validation
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElevenLabsError.invalidResponse
        }
        
        // Parse error based on status code
        if !(200...299).contains(httpResponse.statusCode) {
            switch httpResponse.statusCode {
            case 401:
                throw ElevenLabsError.authenticationError
            case 429:
                throw ElevenLabsError.rateLimitExceeded
            case 500...599:
                throw ElevenLabsError.serverError(httpResponse.statusCode)
            default:
                // Try to extract more detailed error from response body
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = errorJson["detail"] as? String {
                    throw ElevenLabsError.networkError("Erreur HTTP \(httpResponse.statusCode): \(errorMessage)")
                } else {
                    throw ElevenLabsError.networkError("Erreur HTTP: \(httpResponse.statusCode)")
                }
            }
        }
        
        // Data validation
        guard !data.isEmpty else {
            throw ElevenLabsError.noData
        }
        
        return data
    }
    
    private func playAudioData(_ data: Data) async throws {
        // Capture audioManager locally to avoid capturing self
        let audioManager = self.audioManager
        
        return try await withCheckedThrowingContinuation { continuation in
            // Already on MainActor due to class annotation
            do {
                audioManager.audioPlayer = try AVAudioPlayer(data: data)
                audioManager.audioPlayer?.delegate = audioManager
                
                if audioManager.audioPlayer?.prepareToPlay() == true,
                   audioManager.audioPlayer?.play() == true {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ElevenLabsError.audioPlaybackError("Impossible de lire l'audio généré"))
                }
            } catch {
                continuation.resume(throwing: ElevenLabsError.audioPlaybackError(error.localizedDescription))
            }
        }
    }
    
    func correctText(_ text: String) -> String {
        guard !text.isEmpty else { return text }
        let checker = UITextChecker()
        var correctedText = text
        var startIndex = correctedText.startIndex
        
        while let range = correctedText.rangeOfCharacter(from: .letters,
                                                       options: [],
                                                       range: startIndex..<correctedText.endIndex) {
            let nsRange = NSRange(range, in: correctedText)
            let misspelledRange = checker.rangeOfMisspelledWord(
                in: correctedText,
                range: nsRange,
                startingAt: nsRange.location,
                wrap: false,
                language: "fr"
            )
            if misspelledRange.location == NSNotFound {
                break
            } else if let guess = checker.guesses(forWordRange: misspelledRange,
                                                in: correctedText,
                                                language: "fr")?.first,
                    let swiftRange = Range(misspelledRange, in: correctedText) {
                correctedText = correctedText.replacingCharacters(in: swiftRange, with: guess)
                if let nextIndex = correctedText.index(correctedText.startIndex,
                                                     offsetBy: misspelledRange.location + misspelledRange.length,
                                                     limitedBy: correctedText.endIndex) {
                    startIndex = nextIndex
                } else {
                    break
                }
            } else {
                break
            }
        }
        return correctedText
    }
    
    private func handleError(_ message: String) {
        isLoading = false
        errorMessage = message
        showError = true
    }
}