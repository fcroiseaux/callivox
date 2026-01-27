import SwiftUI
import UIKit

// MARK: - Story 6.2: Primary Speak Button (AC1 - 200x80pt minimum)
// Enhanced speak button component - PRIMARY ACTION in reorganized sidebar
@MainActor
struct SpeakControlButton: View {
    var text: String
    var isLoading: Bool
    var onSpeak: () -> Void

    // Create separate components for the button
    private var buttonBackground: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var buttonBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.white.opacity(0.3), lineWidth: 2)
    }

    var body: some View {
        Button(action: {
            // Story 6.2 AC4: Haptic feedback for primary action (.medium)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onSpeak()
        }) {
            VStack(spacing: 8) {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 36))
                    .symbolEffect(.pulse, options: .repeating, value: isLoading)

                HStack {
                    if isLoading {
                        ProgressView().tint(.white)
                            .scaleEffect(1.2)
                            .padding(.trailing, 4)
                    }
                    Text("Lire à haute voix")
                        .font(.title)
                        .bold()
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minWidth: 200, minHeight: 80)  // Story 6.2 AC1: 200x80pt minimum
            .padding(.vertical, 12)
            .background(buttonBackground)
            .overlay(buttonBorder)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: 0.95,
            pressedColor: Color.blue.opacity(0.7),
            normalColor: .clear
        ))
        .disabled(isLoading || text.isEmpty)
        .opacity((isLoading || text.isEmpty) ? 0.6 : 1.0)
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel("Lire à haute voix")
        .accessibilityHint("Lit le texte reconnu à haute voix")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Story 6.2: Compact Repeat Button (AC1 - 95x60pt for side-by-side)
// Secondary action button - simplified for horizontal layout
@MainActor
struct CompactRepeatButton: View {
    var lastText: String
    var isLoading: Bool
    var onRepeat: () -> Void

    var body: some View {
        Button(action: {
            // Story 6.2 AC4: Haptic feedback for action (.medium)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            onRepeat()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                Text("Répéter")
                    .font(.headline)
                    .fontWeight(.semibold)
                if isLoading {
                    ProgressView().tint(.white).scaleEffect(0.8)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minWidth: 95, minHeight: 60)  // Story 6.2 AC1: 95x60pt minimum
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .disabled(isLoading || lastText.isEmpty)
        .opacity((isLoading || lastText.isEmpty) ? 0.5 : 1.0)
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel("Répéter")
        .accessibilityHint(lastText.isEmpty ? "Aucun texte à répéter" : "Répète le dernier texte prononcé")
    }
}

// MARK: - Story 6.2: Compact Clear Button (AC1 - 95x60pt for side-by-side)
// Secondary action button - simplified for horizontal layout
@MainActor
struct CompactClearButton: View {
    @Binding var recognizedText: String
    @Binding var speakTask: Task<Void, Never>?
    var isLoading: Bool

    var body: some View {
        Button(action: {
            // Story 6.2 AC4: Haptic feedback for action (.medium)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            recognizedText = ""
            speakTask?.cancel()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 18))
                Text("Effacer")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(minWidth: 95, minHeight: 60)  // Story 6.2 AC1: 95x60pt minimum
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .disabled(isLoading || recognizedText.isEmpty)
        .opacity((isLoading || recognizedText.isEmpty) ? 0.5 : 1.0)
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel("Effacer")
        .accessibilityHint(recognizedText.isEmpty ? "Aucun texte à effacer" : "Efface le texte saisi")
    }
}

// Button style for improved interaction feedback
struct ScaleButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat
    var pressedColor: Color
    var normalColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : normalColor)
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Story 6.2: Reorganized ControlButtonsView (AC1, AC3)
// Main sidebar view - reduced from 8+ buttons to 5 buttons + settings submenu
@MainActor
struct ControlButtonsView: View {
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var userModel: UserModel
    // M2 Fix (Code Review): Explicit declaration for sheet environment propagation
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @Binding var recognizedText: String
    @Binding var showPhraseManager: Bool
    @Binding var speakTask: Task<Void, Never>?

    // Story 6.2 AC2: State for settings submenu
    @State private var showSettingsSubmenu: Bool = false

    // Existing states for settings views (preserved for Task 3)
    @State private var showUsageSettings: Bool = false
    @State private var showLLMSettings: Bool = false
    @State private var showPersonalizationSettings: Bool = false
    @State private var showGradiumSettings: Bool = false

    // Story 7.1 Task 4.1: State for accessibility settings sheet
    @State private var showAccessibilitySettings: Bool = false

    var body: some View {
        // Story 6.2 AC1, AC3: Reorganized VStack with clear hierarchy
        VStack(spacing: 16) {
            // MARK: Story 6.2 AC1: PRIMARY ACTION - PARLER (200x80pt minimum)
            SpeakControlButton(
                text: recognizedText,
                isLoading: speechService.isLoading,
                onSpeak: {
                    guard !recognizedText.isEmpty else { return }
                    speechService.speakText(recognizedText)
                    recognizedText = ""
                }
            )

            // MARK: Story 6.2 AC1: SECONDARY ACTIONS - Side by side (95x60pt each)
            HStack(spacing: 12) {
                CompactRepeatButton(
                    lastText: speechService.lastSpokenText,
                    isLoading: speechService.isLoading,
                    onRepeat: {
                        guard !speechService.lastSpokenText.isEmpty else { return }
                        speechService.speakText(speechService.lastSpokenText)
                    }
                )

                CompactClearButton(
                    recognizedText: $recognizedText,
                    speakTask: $speakTask,
                    isLoading: speechService.isLoading
                )
            }

            // MARK: Story 6.2 AC1: TERTIARY - Mes phrases (50pt minimum)
            Button(action: {
                // Story 6.2 AC4: Haptic feedback for navigation (.light)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showPhraseManager = true
            }) {
                HStack {
                    Image(systemName: "text.quote")
                        .font(.system(size: 18))
                    Text("Mes phrases")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)  // Story 6.2 AC1: 50pt minimum
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            // Story 6.2 AC5: French accessibility labels
            .accessibilityLabel("Mes phrases")
            .accessibilityHint("Ouvre la gestion des phrases rapides")

            // MARK: Story 6.2 AC1: SETTINGS ENTRY POINT (50pt minimum)
            // Replaces the 4+ settings buttons previously in sidebar (AC3)
            Button(action: {
                // Story 6.2 AC4: Haptic feedback for navigation (.light)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showSettingsSubmenu = true
            }) {
                HStack {
                    Image(systemName: "gearshape")
                        .font(.system(size: 18))
                    Text("Paramètres")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)  // Story 6.2 AC1: 50pt minimum
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            // Story 6.2 AC5: French accessibility labels
            .accessibilityLabel("Paramètres")
            .accessibilityHint("Ouvre le menu des réglages")

            // Story 6.2 AC1: Flexible space to push user info to bottom
            Spacer()

            // MARK: Story 6.2 AC1: USER INFO - preserved at bottom
            if let userName = userModel.userName {
                VStack(alignment: .leading, spacing: 4) {
                    Text(userName)
                        .font(.footnote)
                        .fontWeight(.medium)

                    if let userEmail = userModel.userEmail {
                        Text(userEmail)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("ID: \(userModel.userId ?? "Non disponible")")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, alignment: .leading)
        // MARK: Story 6.2 AC2: Settings submenu presentation (fullScreenCover per Story 6.1 pattern)
        .fullScreenCover(isPresented: $showSettingsSubmenu) {
            SettingsSubmenuView(
                onSelectSetting: { setting in
                    handleSettingSelection(setting)
                },
                onDismiss: { showSettingsSubmenu = false },
                showPrivacyOption: !AppConfig.Features.skipAuthentication
            )
        }
        // Existing .sheet modifiers for individual settings views
        .sheet(isPresented: $showUsageSettings) {
            UsageSettingsView()
        }
        .sheet(isPresented: $showLLMSettings) {
            NavigationView {
                LLMSettingsView()
            }
        }
        .sheet(isPresented: $showPersonalizationSettings) {
            NavigationView {
                PersonalizationSettingsView()
            }
        }
        .sheet(isPresented: $showGradiumSettings) {
            NavigationView {
                GradiumSettingsView()
            }
        }
        // Story 7.1 Task 4.3: Accessibility settings sheet presentation
        // M2 Fix (Code Review): Explicit environmentObject injection for clarity
        .sheet(isPresented: $showAccessibilitySettings) {
            AccessibilitySettingsView(onDismiss: { showAccessibilitySettings = false })
                .environmentObject(accessibilitySettings)
        }
    }

    // MARK: Story 6.2 Task 3.3: Handle settings view presentations from submenu
    private func handleSettingSelection(_ setting: SettingsSubmenuView.SettingType) {
        switch setting {
        case .tts:
            showGradiumSettings = true
        case .llm:
            showLLMSettings = true
        case .personalization:
            showPersonalizationSettings = true
        case .accessibility:
            // Story 7.1 Task 4.2: Handle accessibility settings
            showAccessibilitySettings = true
        case .privacy:
            showUsageSettings = true
        }
    }
}

// MARK: - Legacy Components
// M1 Fix (Code Review): Removed legacy RepeatControlButton struct (65 lines of dead code)
// Original Story 4.2 implementation was replaced by CompactRepeatButton in Story 6.2.
// See git history for original implementation if needed.
