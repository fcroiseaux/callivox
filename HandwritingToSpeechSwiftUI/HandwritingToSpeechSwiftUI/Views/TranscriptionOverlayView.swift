//
//  TranscriptionOverlayView.swift
//  HandwritingToSpeechSwiftUI
//
//  Overlay view displaying live transcription of interlocutor's speech.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI

/// Overlay view that displays live transcription when listening to interlocutor.
/// Shows animated listening indicator and transcribed text in real-time.
/// Story 7.3: Added accessibility settings for reduced animations and high contrast
struct TranscriptionOverlayView: View {
    @ObservedObject var listeningService: InterlocutorListeningService
    // Story 7.3 Task 3.1: Add accessibility settings for conditional opacity and animations
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    // Story 7.3 Task 3.2, AC4: System reduce motion detection
    @Environment(\.accessibilityReduceMotion) var systemReduceMotion

    var body: some View {
        // Show overlay when listening or has transcription or processing suggestions
        if listeningService.isListening || !listeningService.currentTranscription.isEmpty || listeningService.isProcessingSuggestions {
            ZStack {
                // Semi-transparent background
                Color.black.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        // Tap background to stop listening
                        listeningService.stopListening()
                    }

                VStack(spacing: 24) {
                    Spacer()

                    // Listening indicator
                    // Story 7.3 AC3, AC4: Pass reduce motion flag to indicator
                    if listeningService.isListening {
                        ListeningIndicator(
                            shouldReduceMotion: systemReduceMotion || accessibilitySettings.shouldReduceMotion
                        )
                        .padding(.bottom, 8)
                    }

                    // Processing indicator
                    if listeningService.isProcessingSuggestions {
                        ProcessingIndicator()
                            .padding(.bottom, 8)
                    }

                    // Transcription text
                    if !listeningService.currentTranscription.isEmpty {
                        Text(listeningService.currentTranscription)
                            .font(.title)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .animation(.easeOut(duration: 0.15), value: listeningService.currentTranscription)
                    } else if listeningService.isListening {
                        Text("En écoute...")
                            .font(.title2)
                            // Story 7.3 AC1: Use configured secondary text opacity
                            .foregroundColor(.white.opacity(accessibilitySettings.isEnhancedModeEnabled ? 0.85 : 0.7))
                            .italic()
                    }

                    Spacer()

                    // Stop button
                    if listeningService.isListening {
                        Button(action: {
                            listeningService.stopListening()
                        }) {
                            HStack {
                                Image(systemName: "stop.fill")
                                Text("Arrêter l'écoute")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color.red.opacity(0.8))
                            )
                        }
                        .padding(.bottom, 48)
                    }
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: listeningService.isListening)
        }
    }
}

/// Animated microphone indicator showing active listening state.
/// Story 7.3 AC3, AC4: Conditionally disables pulsing animation for reduced motion
struct ListeningIndicator: View {
    @State private var isAnimating = false
    // Story 7.3 AC3, AC4: Parameter to control motion reduction
    var shouldReduceMotion: Bool = false

    var body: some View {
        ZStack {
            // Story 7.3 AC3: Pulsing circles - conditional animation
            if shouldReduceMotion {
                // Story 7.3 AC3, Task 3.5: Static circles when reduce motion enabled
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(index) * 30, height: 80 + CGFloat(index) * 30)
                }
            } else {
                // Original animated circles
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                        .frame(width: 80 + CGFloat(index) * 30, height: 80 + CGFloat(index) * 30)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0.0 : 0.5)
                        .animation(
                            Animation.easeOut(duration: 1.5)
                                .repeatForever(autoreverses: false)
                                .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
            }

            // Story 7.3 AC3, Task 3.6: Microphone icon - unchanged, always visible
            Image(systemName: "mic.fill")
                .font(.system(size: 36))
                .foregroundColor(.blue)
                .frame(width: 70, height: 70)
                .background(
                    Circle()
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.2), radius: 10)
                )
        }
        .onAppear {
            // Story 7.3 AC3: Only start animation if not in reduce motion mode
            if !shouldReduceMotion {
                isAnimating = true
            }
        }
    }
}

/// Indicator showing suggestions are being generated.
struct ProcessingIndicator: View {
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)

            Text("Génération des suggestions...")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

/// Button to toggle listening mode.
struct ListeningToggleButton: View {
    @ObservedObject var listeningService: InterlocutorListeningService

    var body: some View {
        Button(action: {
            Task {
                await listeningService.toggleListening()
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: listeningService.isListening ? "ear.fill" : "ear")
                    .font(.system(size: 18))
                Text(listeningService.isListening ? "Écoute..." : "Écouter")
                    .font(.subheadline.weight(.medium))
            }
            .foregroundColor(listeningService.isListening ? .white : .blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(listeningService.isListening ? Color.blue : Color.blue.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(Color.blue, lineWidth: listeningService.isListening ? 0 : 1)
            )
        }
        .disabled(!listeningService.listeningEnabled)
        .opacity(listeningService.listeningEnabled ? 1.0 : 0.5)
    }
}

// Story 7.3: Preview with AccessibilitySettings environment object
#Preview {
    TranscriptionOverlayView(listeningService: InterlocutorListeningService.shared)
        .environmentObject(AccessibilitySettings())
}
