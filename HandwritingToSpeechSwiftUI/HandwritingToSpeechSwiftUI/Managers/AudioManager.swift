import AVFoundation
import SwiftUI

class AudioManager: NSObject, ObservableObject, AVAudioPlayerDelegate, AVSpeechSynthesizerDelegate {
    // Mark the class as @unchecked Sendable while keeping the actual properties and state updates on the main actor
    // This prevents protocol conflicts with delegate methods
    static let shared = AudioManager()
    var audioPlayer: AVAudioPlayer?
    let synthesizer = AVSpeechSynthesizer()
    
    @Published var isPlaying: Bool = false
    @Published var audioError: String? = nil
    
    // Callback for clients to register for audio completion events
    var onAudioCompletion: (() -> Void)?
    var onAudioError: ((String) -> Void)?
    
    private var setupTask: Task<Void, Never>?
    
    deinit {
        setupTask?.cancel()
        audioPlayer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    override init() {
        super.init()
        synthesizer.delegate = self
        setupAudio()
        
        // Register for audio session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAudioSessionInterruption),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    private func setupAudio() {
        setupTask?.cancel()
        setupTask = Task {
            do {
                try await setupAudioAsync()
            } catch {
                let errorMessage = "Erreur configuration audio: \(error.localizedDescription)"
                print(errorMessage)
                audioError = errorMessage
                onAudioError?(errorMessage)
            }
        }
    }
    
    private func setupAudioAsync() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                // Use playAndRecord to support both TTS playback and STT microphone capture
                try AVAudioSession.sharedInstance().setCategory(
                    .playAndRecord,
                    mode: .default,
                    options: [.duckOthers, .allowBluetoothA2DP, .defaultToSpeaker]
                )
                try AVAudioSession.sharedInstance().setActive(true)
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    // MARK: - AVAudioPlayerDelegate
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Use DispatchQueue.main to ensure thread safety since we're not using @MainActor
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            if flag {
                self?.onAudioCompletion?()
            } else {
                let errorMessage = "La lecture audio s'est terminée de manière inattendue"
                self?.audioError = errorMessage
                self?.onAudioError?(errorMessage)
            }
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            if let error = error {
                let errorMessage = "Erreur de décodage audio: \(error.localizedDescription)"
                self?.audioError = errorMessage
                self?.onAudioError?(errorMessage)
            }
        }
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
            self?.onAudioCompletion?()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        DispatchQueue.main.async { [weak self] in
            self?.isPlaying = true
        }
    }
    
    // MARK: - Error handling
    
    @objc func handleAudioSessionInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        switch type {
        case .began:
            // Audio session interrupted (e.g., phone call)
            isPlaying = false
        case .ended:
            // Interruption ended
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt,
               AVAudioSession.InterruptionOptions(rawValue: optionsValue).contains(.shouldResume) {
                // Resume playback if appropriate
                audioPlayer?.play()
            }
        @unknown default:
            break
        }
    }
    
    // MARK: - Public methods
    
    func stopAllAudio() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        if let player = audioPlayer, player.isPlaying {
            player.stop()
        }
        
        isPlaying = false
    }
}
