import Foundation
import AVFoundation
import SwiftUI
import Network

@MainActor
class SpeechService: ObservableObject {
    static let shared = SpeechService()

    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var lastSpokenText: String = ""

    // Gradium TTS properties
    @Published var useGradium: Bool = false
    @Published var gradiumAvailable: Bool = false

    // Voice selection properties (Story 1.3)
    @Published var selectedVoiceId: String = AppConfig.VoiceConfig.defaultVoiceId
    @Published var isPreviewingVoice: Bool = false

    private var currentSpeechTask: Task<Void, Never>?

    private let audioManager = AudioManager.shared

    // Gradium TTS provider and PCM stream player
    private let gradiumProvider = GradiumTTSProvider()
    private let pcmStreamPlayer = PCMStreamPlayer()

    // Network availability is now provided by NetworkMonitor singleton (Story 2.1)
    private var isNetworkAvailable: Bool {
        NetworkMonitor.shared.isConnected
    }

    deinit {
        currentSpeechTask?.cancel()
    }

    init() {
        checkGradiumAvailability()
        loadVoicePreference()
    }

    func speakText(_ text: String) {
        lastSpokenText = text
        isLoading = true

        print("SpeechService: Speaking text: '\(text)'")

        // Log the usage first
        print("SpeechService: Logging usage statistics...")
        UsageLogManager.shared.logSentenceUsage(text)

        // AC1, AC2, AC4: Automatic fallback to AVFoundation when offline (Story 2.2)
        if useGradium && isNetworkAvailable {
            print("SpeechService: Using Gradium for TTS")
            speakTextGradium(text)
        } else {
            // Log fallback reason for debugging
            if useGradium && !isNetworkAvailable {
                print("SpeechService: Network offline, using AVFoundation fallback")
            } else {
                print("SpeechService: Using native AVSpeechSynthesizer for TTS")
            }
            speakTextNative(text)
        }
    }

    // MARK: - Gradium TTS Methods

    /// Speaks text using Gradium TTS API
    func speakTextGradium(_ text: String) {
        // AC3: Stop any current playback cleanly before starting new request
        currentSpeechTask?.cancel()
        pcmStreamPlayer.stop()

        currentSpeechTask = Task {
            await speakTextGradiumAsync(text)
        }
    }

    private func speakTextGradiumAsync(_ text: String) async {
        do {
            guard !Task.isCancelled else { return }

            // Story 2.2: Network check is now done in speakText(_:) before calling this method.
            // This defensive check remains for edge cases where network state changes mid-execution
            // or if this method is called directly. Should rarely trigger during normal operation.
            guard isNetworkAvailable else {
                throw TTSError.networkUnavailable
            }

            // Story 1.3: Use selected voice instead of hardcoded default
            let audioStream = try await gradiumProvider.synthesize(text: text, voice: selectedVoiceId)

            guard !Task.isCancelled else { return }

            // Prepare PCM stream player for playback
            try pcmStreamPlayer.prepareToPlay()

            // Set up completion callback
            pcmStreamPlayer.onPlaybackComplete = { [weak self] in
                Task { @MainActor in
                    self?.isLoading = false
                    print("SpeechService: Gradium playback completed")
                }
            }

            // Stream audio chunks directly to PCMStreamPlayer for real-time playback
            // This achieves < 300ms time-to-first-audio as per NFR-1
            var totalBytes = 0
            for try await chunk in audioStream {
                guard !Task.isCancelled else {
                    pcmStreamPlayer.stop()
                    return
                }
                pcmStreamPlayer.scheduleBuffer(chunk)
                totalBytes += chunk.count
            }

            guard !Task.isCancelled else {
                pcmStreamPlayer.stop()
                return
            }

            // Signal that all buffers have been scheduled
            pcmStreamPlayer.finishScheduling()

            if totalBytes > 0 {
                print("SpeechService: Streamed \(totalBytes) bytes of PCM audio to player")
                gradiumAvailable = true
            } else {
                throw TTSError.apiError(statusCode: 0, message: "Aucune donnée audio reçue")
            }
        } catch {
            guard !Task.isCancelled else { return }
            pcmStreamPlayer.stop()
            updateUIForGradiumError(error)
        }
    }

    /// Displays user-friendly error message with recovery suggestion (Story 2.3)
    /// AC1: All errors show French message + what went wrong + what user can do
    /// AC2: invalidApiKey guides user to check API configuration
    /// AC5: All errors logged for debugging, never silently swallowed
    private func updateUIForGradiumError(_ error: Error) {
        let errorMsg: String

        if let ttsError = error as? TTSError {
            // Story 2.3 AC1, AC2: Include both error description AND recovery suggestion for ALL errors
            if let suggestion = ttsError.recoverySuggestion {
                errorMsg = "\(ttsError.localizedDescription)\n\n\(suggestion)"
            } else {
                errorMsg = ttsError.localizedDescription
            }
            gradiumAvailable = false
            useGradium = false
            // AC5: Log error for debugging (never silent)
            print("SpeechService [ERROR]: TTSError - \(ttsError.failureReason ?? "unknown")")
        } else {
            // Generic error fallback with French message
            errorMsg = "Erreur Gradium: \(error.localizedDescription)"
            // AC5: Log error for debugging
            print("SpeechService [ERROR]: \(error)")
        }

        handleError(errorMsg)
    }

    /// Checks if Gradium API key is configured and service is available
    /// If not configured, shows guidance message to user (AC2)
    func checkGradiumAvailability() {
        do {
            _ = try KeychainManager.load(key: AppConfig.Gradium.keychainKey)
            gradiumAvailable = true
            print("SpeechService: Gradium API key found, service available")
        } catch {
            gradiumAvailable = false
            useGradium = false
            print("SpeechService: Gradium API key not configured")
            // AC2: Guide user to configure API key when attempting to use Gradium without key
        }
    }

    /// Shows guidance message when Gradium API key is missing (AC2)
    func showGradiumKeyMissingGuidance() {
        let guidance = TTSError.invalidApiKey.recoverySuggestion ?? "Configurez votre clé API Gradium dans les paramètres."
        handleError("Clé API Gradium non configurée. \(guidance)")
    }

    /// Saves Gradium API key to Keychain
    func updateGradiumAPIKey(_ apiKey: String) {
        guard !apiKey.isEmpty else {
            handleError("La clé API ne peut pas être vide")
            return
        }

        if let data = apiKey.data(using: .utf8) {
            do {
                try KeychainManager.save(key: AppConfig.Gradium.keychainKey, data: data)
                gradiumAvailable = true
                print("SpeechService: Gradium API key saved successfully")
            } catch {
                handleError("Erreur lors de la sauvegarde de la clé API: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Voice Selection Methods (Story 1.3)

    /// Loads saved voice preference from UserDefaults, applying French locale default if no preference exists (AC: 4, 5)
    func loadVoicePreference() {
        if let savedVoice = UserDefaults.standard.string(forKey: AppConfig.VoiceConfig.userDefaultsKey) {
            selectedVoiceId = savedVoice
            print("SpeechService: Loaded saved voice preference: \(savedVoice)")
        } else {
            // AC4: Set default for French locale
            if Locale.current.language.languageCode?.identifier == "fr" {
                selectedVoiceId = AppConfig.VoiceConfig.defaultVoiceId
                print("SpeechService: French locale detected, using default voice: \(selectedVoiceId)")
            }
        }
    }

    /// Saves current voice preference to UserDefaults (AC: 3)
    func saveVoicePreference() {
        UserDefaults.standard.set(selectedVoiceId, forKey: AppConfig.VoiceConfig.userDefaultsKey)
        print("SpeechService: Saved voice preference: \(selectedVoiceId)")
    }

    /// Previews a voice by speaking sample text (AC: 2)
    /// Protected against rapid taps and duplicate preview requests
    private var currentPreviewVoiceId: String?

    func previewVoice(_ voiceId: String) {
        // Guard against rapid taps: ignore if already previewing same voice
        guard !isPreviewingVoice || currentPreviewVoiceId != voiceId else {
            print("SpeechService: Preview already in progress for voice \(voiceId)")
            return
        }

        // If previewing different voice, cancel current and start new
        if isPreviewingVoice && currentPreviewVoiceId != voiceId {
            currentSpeechTask?.cancel()
            pcmStreamPlayer.stop()
        }

        let voiceName = AppConfig.VoiceConfig.availableVoices.first { $0.id == voiceId }?.name ?? voiceId
        let sampleText = String(format: AppConfig.VoiceConfig.previewTextTemplate, voiceName)

        isPreviewingVoice = true
        currentPreviewVoiceId = voiceId
        currentSpeechTask?.cancel()
        pcmStreamPlayer.stop()

        currentSpeechTask = Task {
            await previewVoiceAsync(text: sampleText, voiceId: voiceId)
            // Reset tracking when done
            await MainActor.run {
                self.currentPreviewVoiceId = nil
            }
        }
    }

    private func previewVoiceAsync(text: String, voiceId: String) async {
        do {
            guard !Task.isCancelled else {
                isPreviewingVoice = false
                return
            }

            // Check network availability before API call
            guard isNetworkAvailable else {
                throw TTSError.networkUnavailable
            }

            let audioStream = try await gradiumProvider.synthesize(text: text, voice: voiceId)

            guard !Task.isCancelled else {
                isPreviewingVoice = false
                return
            }

            try pcmStreamPlayer.prepareToPlay()

            pcmStreamPlayer.onPlaybackComplete = { [weak self] in
                Task { @MainActor in
                    self?.isPreviewingVoice = false
                    print("SpeechService: Voice preview completed")
                }
            }

            for try await chunk in audioStream {
                guard !Task.isCancelled else {
                    pcmStreamPlayer.stop()
                    isPreviewingVoice = false
                    return
                }
                pcmStreamPlayer.scheduleBuffer(chunk)
            }

            guard !Task.isCancelled else {
                pcmStreamPlayer.stop()
                isPreviewingVoice = false
                return
            }

            pcmStreamPlayer.finishScheduling()
        } catch {
            guard !Task.isCancelled else {
                isPreviewingVoice = false
                return
            }
            pcmStreamPlayer.stop()
            isPreviewingVoice = false
            updateUIForGradiumError(error)
        }
    }

    /// Selects a voice and saves the preference (AC: 3)
    /// Validates that the voiceId exists in available voices before saving
    func selectVoice(_ voiceId: String) {
        // Validate voiceId exists in available voices
        let isValidVoice = AppConfig.VoiceConfig.availableVoices.contains { $0.id == voiceId }
        guard isValidVoice else {
            print("SpeechService: Invalid voice ID '\(voiceId)' - not in available voices")
            handleError("Voix invalide: \(voiceId)")
            return
        }

        selectedVoiceId = voiceId
        saveVoicePreference()
        print("SpeechService: Voice selected and saved: \(voiceId)")
    }

    /// Speaks text using native AVFoundation TTS (Story 2.2: AC3)
    /// Used as primary when useGradium=false, or as fallback when offline
    func speakTextNative(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "fr-FR")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0

        // Stop any current speech before starting new
        if audioManager.synthesizer.isSpeaking {
            audioManager.synthesizer.stopSpeaking(at: .immediate)
        }

        // AC3: Set completion callback to reset isLoading when speech finishes
        // This ensures text clears identically to Gradium path
        //
        // Note: Callback is overwritten on each call, which is safe because:
        // 1. We call stopSpeaking(at: .immediate) above if already speaking
        // 2. Previous speech is stopped before new callback is set
        // 3. AVSpeechSynthesizer only calls didFinish for the current utterance
        audioManager.onAudioCompletion = { [weak self] in
            Task { @MainActor in
                self?.isLoading = false
                print("SpeechService: Native speech completed")
            }
        }

        audioManager.synthesizer.speak(utterance)
        // Note: isLoading will be reset to false via onAudioCompletion callback when speech finishes
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
