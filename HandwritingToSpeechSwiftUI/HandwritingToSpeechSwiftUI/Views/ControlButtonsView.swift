import SwiftUI
import UIKit

// MARK: - Story 6.2: Primary Speak Button (AC1 - 200x80pt minimum)
// Story 7.2: Accepts primaryButtonHeight for Enhanced Mode conditional sizing
// Story 7.3: Accepts animation parameters for reduced motion
// Enhanced speak button component - PRIMARY ACTION in reorganized sidebar
@MainActor
struct SpeakControlButton: View {
    var text: String
    var isLoading: Bool
    var onSpeak: () -> Void
    var primaryButtonHeight: CGFloat  // Story 7.2 AC4: Conditional height (100pt enhanced, 80pt standard)
    var scaleAnimationAmount: CGFloat = 0.95  // Story 7.3 AC2: Default for backward compatibility
    var animationDuration: Double = 0.2       // Story 7.3 AC2: Default for backward compatibility

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
            .frame(minWidth: 200, minHeight: primaryButtonHeight)  // Story 7.2 AC4: Conditional height
            .padding(.vertical, 12)
            .background(buttonBackground)
            .overlay(buttonBorder)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: scaleAnimationAmount,  // Story 7.3 AC2: Conditional animation
            pressedColor: Color.blue.opacity(0.7),
            normalColor: .clear,
            animationDuration: animationDuration  // Story 7.3 AC2
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
// Story 7.2: Accepts buttonHeight for Enhanced Mode conditional sizing
// Story 7.3: Accepts animation parameters for reduced motion
// Secondary action button - simplified for horizontal layout
@MainActor
struct CompactRepeatButton: View {
    var lastText: String
    var isLoading: Bool
    var onRepeat: () -> Void
    var buttonHeight: CGFloat  // Story 7.2 AC4: Conditional height (80pt enhanced, 60pt standard)
    var scaleAnimationAmount: CGFloat = 0.97  // Story 7.3 AC2: Default for backward compatibility
    var animationDuration: Double = 0.2       // Story 7.3 AC2: Default for backward compatibility

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
            .frame(minWidth: 95, minHeight: buttonHeight)  // Story 7.2 AC4: Conditional height
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: scaleAnimationAmount,  // Story 7.3 AC2: Conditional animation
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: animationDuration  // Story 7.3 AC2
        ))
        .disabled(isLoading || lastText.isEmpty)
        .opacity((isLoading || lastText.isEmpty) ? 0.5 : 1.0)
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel("Répéter")
        .accessibilityHint(lastText.isEmpty ? "Aucun texte à répéter" : "Répète le dernier texte prononcé")
    }
}

// MARK: - Story 6.2: Compact Clear Button (AC1 - 95x60pt for side-by-side)
// Story 7.2: Accepts buttonHeight for Enhanced Mode conditional sizing
// Story 7.3: Accepts animation parameters for reduced motion
// Story 7.4: Accepts requireConfirmation for confirmation dialog
// Secondary action button - simplified for horizontal layout
@MainActor
struct CompactClearButton: View {
    @Binding var recognizedText: String
    @Binding var speakTask: Task<Void, Never>?
    var isLoading: Bool
    var buttonHeight: CGFloat  // Story 7.2 AC4: Conditional height (80pt enhanced, 60pt standard)
    var scaleAnimationAmount: CGFloat = 0.97  // Story 7.3 AC2: Default for backward compatibility
    var animationDuration: Double = 0.2       // Story 7.3 AC2: Default for backward compatibility
    var requireConfirmation: Bool = true      // Story 7.4 AC1, AC4: Default to true for safety

    // Story 7.4 AC1 Task 3.1: State for confirmation dialog
    @State private var showClearConfirmation: Bool = false

    var body: some View {
        Button(action: {
            // Story 6.2 AC4: Haptic feedback for action (.medium)
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            // Story 7.4 AC1 Task 3.3: Show confirmation or clear immediately
            if requireConfirmation && !recognizedText.isEmpty {
                showClearConfirmation = true
            } else {
                performClear()
            }
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
            .frame(minWidth: 95, minHeight: buttonHeight)  // Story 7.2 AC4: Conditional height
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: scaleAnimationAmount,  // Story 7.3 AC2: Conditional animation
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: animationDuration  // Story 7.3 AC2
        ))
        .disabled(isLoading || recognizedText.isEmpty)
        .opacity((isLoading || recognizedText.isEmpty) ? 0.5 : 1.0)
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel("Effacer")
        .accessibilityHint(recognizedText.isEmpty ? "Aucun texte à effacer" : "Efface le texte saisi")
        // Story 7.4 AC1 Task 3.4: Confirmation dialog
        .alert("Effacer le texte ?", isPresented: $showClearConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Effacer", role: .destructive) {
                performClear()
            }
        }
    }

    // Story 7.4 Task 3.5: Extract clear action for reuse
    private func performClear() {
        recognizedText = ""
        speakTask?.cancel()
    }
}

// Button style for improved interaction feedback
// Story 7.3 AC2: Updated with configurable animation duration
struct ScaleButtonStyle: ButtonStyle {
    var scaleAmount: CGFloat
    var pressedColor: Color
    var normalColor: Color
    var animationDuration: Double = 0.2  // Story 7.3: Default for backward compatibility

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressedColor : normalColor)
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .animation(.easeInOut(duration: animationDuration), value: configuration.isPressed)
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

    // Story 10.1 Task 2.1: State for fatigue mode view presentation
    // H1 Fix (Code Review): Removed - presentation now handled by ContentView via onChange
    // @State private var showFatigueModeView: Bool = false

    var body: some View {
        // Story 6.2 AC1, AC3: Reorganized VStack with clear hierarchy
        VStack(spacing: 16) {
            // MARK: Story 7.2 AC4: PRIMARY ACTION - PARLER (conditional 200x100pt enhanced, 200x80pt standard)
            SpeakControlButton(
                text: recognizedText,
                isLoading: speechService.isLoading,
                onSpeak: {
                    guard !recognizedText.isEmpty else { return }
                    speechService.speakText(recognizedText)
                    recognizedText = ""
                },
                primaryButtonHeight: accessibilitySettings.primaryButtonHeight,  // Story 7.2 AC4
                scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
            )

            // MARK: Story 7.2 AC4: SECONDARY ACTIONS - Side by side (conditional 95x80pt enhanced, 95x60pt standard)
            HStack(spacing: 12) {
                CompactRepeatButton(
                    lastText: speechService.lastSpokenText,
                    isLoading: speechService.isLoading,
                    onRepeat: {
                        guard !speechService.lastSpokenText.isEmpty else { return }
                        speechService.speakText(speechService.lastSpokenText)
                    },
                    buttonHeight: accessibilitySettings.buttonHeight,  // Story 7.2 AC4
                    scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                    animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                )

                CompactClearButton(
                    recognizedText: $recognizedText,
                    speakTask: $speakTask,
                    isLoading: speechService.isLoading,
                    buttonHeight: accessibilitySettings.buttonHeight,  // Story 7.2 AC4
                    scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                    animationDuration: accessibilitySettings.animationDuration,  // Story 7.3 AC2
                    requireConfirmation: accessibilitySettings.requireConfirmationDialogs  // Story 7.4 AC1 Task 3.6
                )
            }

            // MARK: Story 7.2 AC4: TERTIARY - Mes phrases (conditional 60pt enhanced, 50pt standard)
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
                .frame(minHeight: accessibilitySettings.tertiaryButtonHeight)  // Story 7.2 AC4
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(
                scaleAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                pressedColor: .clear,
                normalColor: .clear,
                animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
            ))
            // Story 6.2 AC5: French accessibility labels
            .accessibilityLabel("Mes phrases")
            .accessibilityHint("Ouvre la gestion des phrases rapides")

            // MARK: Story 10.1 AC1, AC3: MODE FATIGUE BUTTON
            // Task 2.2, 2.3, 2.4, 2.5, 2.6: Fatigue mode trigger button
            Button(action: {
                // Story 10.1 Task 2.5: Haptic feedback for navigation (.light)
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                // Story 10.1 Task 4.1: Enable fatigue mode
                // H1 Fix (Code Review): Only set the flag - ContentView handles presentation via onChange
                accessibilitySettings.isFatigueModeEnabled = true
            }) {
                HStack {
                    // Story 10.1 Task 2.2: moon.zzz icon
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 18))
                    Text("Mode Fatigue")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                // Story 10.1 Task 2.3, AC1, AC3: Conditional height (60pt standard, 80pt enhanced)
                // H1 Fix (Code Review): Use fatigueModeButtonHeight instead of tertiaryButtonHeight to meet AC requirements
                .frame(minHeight: accessibilitySettings.fatigueModeButtonHeight)
                // Story 10.1 Task 2.4: Orange/amber gradient for "rest" mode
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(
                scaleAmount: accessibilitySettings.scaleAnimationAmount,
                pressedColor: .clear,
                normalColor: .clear,
                animationDuration: accessibilitySettings.animationDuration
            ))
            // Story 10.1 Task 2.6: French accessibility labels
            // M1 Fix (Code Review): Added accessibilityValue for VoiceOver state awareness
            .accessibilityLabel("Mode Fatigue")
            .accessibilityHint("Active l'interface simplifiée pour la fatigue")
            .accessibilityValue(accessibilitySettings.isFatigueModeEnabled ? "Activé" : "Désactivé")

            // MARK: Story 7.2 AC4: SETTINGS ENTRY POINT (conditional 60pt enhanced, 50pt standard)
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
                        .foregroundColor(.white.opacity(accessibilitySettings.secondaryTextOpacity))  // Story 7.3 AC1
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: accessibilitySettings.tertiaryButtonHeight)  // Story 7.2 AC4
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
            .buttonStyle(ScaleButtonStyle(
                scaleAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                pressedColor: .clear,
                normalColor: .clear,
                animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
            ))
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
        // H1 Fix (Code Review 7.3): Explicit environmentObject injection for fullScreenCover context
        .fullScreenCover(isPresented: $showSettingsSubmenu) {
            SettingsSubmenuView(
                onSelectSetting: { setting in
                    handleSettingSelection(setting)
                },
                onDismiss: { showSettingsSubmenu = false },
                showPrivacyOption: !AppConfig.Features.skipAuthentication
            )
            .environmentObject(accessibilitySettings)
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
        // H1 Fix (Code Review): Removed duplicate fullScreenCover for FatigueModeView
        // Story 10.2 Task 5.1: Fatigue mode presentation is now centralized in ContentView
        // ContentView watches accessibilitySettings.isFatigueModeEnabled via onChange
        // This eliminates dual state management and potential inconsistencies
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
// Story 10.2 Task 5.2: Removed FatigueModeViewPlaceholder - replaced by FatigueModeView.swift
// M1 Fix (Code Review): Removed legacy RepeatControlButton struct (65 lines of dead code)
// Original Story 4.2 implementation was replaced by CompactRepeatButton in Story 6.2.
// See git history for original implementation if needed.
