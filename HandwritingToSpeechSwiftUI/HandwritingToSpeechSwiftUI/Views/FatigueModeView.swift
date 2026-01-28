//
//  FatigueModeView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 10.2: Create Minimal Fatigue Mode Interface
//  Story 10.3: Updated to use customizable messages from FatigueModeSettings
//  Story 11.3: Scanning mode integration (AC5)
//  Provides an extremely simplified interface with only essential buttons
//  for users with very limited energy.
//

import SwiftUI
import UIKit

// Note: FatigueModeMessage model moved to FatigueModeSettings.swift (Story 10.3)

// MARK: - Story 10.2: FatigueModeButton Component
// Task 2.1: Reusable button component with standard styling for fatigue mode
// AC2: Full-width, 100pt minimum height, .largeTitle font
// AC3: Gentle haptic feedback (.light style)
@MainActor
struct FatigueModeButton: View {
    let message: String
    let backgroundColor: Color
    let icon: String?  // M2 Fix: Optional icon for exit button
    let onTap: () -> Void

    // L1 Fix (Code Review): Prepare haptic generator for optimal timing
    @State private var impactGenerator: UIImpactFeedbackGenerator?

    init(message: String, backgroundColor: Color, icon: String? = nil, onTap: @escaping () -> Void) {
        self.message = message
        self.backgroundColor = backgroundColor
        self.icon = icon
        self.onTap = onTap
    }

    var body: some View {
        Button(action: {
            // AC3: Gentle haptic feedback (.light style for fatigue mode)
            // L1 Fix: Use prepared generator for optimal timing
            impactGenerator?.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                // M2 Fix: Optional icon for exit button visual indicator
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title)
                }
                Text(message)
                    // AC2: Large text (.largeTitle font)
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            // AC2: Full-width layout
            .frame(maxWidth: .infinity)
            // AC2: 100pt minimum height
            .frame(minHeight: 100)
            .background(backgroundColor)
            .cornerRadius(16)
        }
        // Task 2.5: French accessibility label
        .accessibilityLabel(message)
        // M1 Fix (Code Review): Explicit accessibility trait for VoiceOver consistency
        .accessibilityAddTraits(.isButton)
        // L1 Fix: Prepare haptic generator on appear
        .onAppear {
            impactGenerator = UIImpactFeedbackGenerator(style: .light)
            impactGenerator?.prepare()
        }
    }
}

// MARK: - Story 10.2, 10.3: FatigueModeView
// Main view for fatigue mode - extremely simplified interface
// AC1: Full-screen simplified interface with calm dark background
// AC2: Maximum 6 buttons in single vertical column
// AC3: TTS action on message buttons
// AC4: Exit confirmation dialog
// Story 10.3 AC4: Uses customizable messages from FatigueModeSettings
@MainActor
struct FatigueModeView: View {
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    let onDismiss: () -> Void

    // AC4: State for exit confirmation dialog
    @State private var showExitConfirmation: Bool = false

    // Story 10.3 Task 4.1: Use customizable messages from FatigueModeSettings
    // Replaces hardcoded messages array with user-customizable messages
    @ObservedObject private var messageSettings = FatigueModeSettings.shared

    // Story 11.3 Task 7.1: Add scanning mode references (AC5)
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared
    @ObservedObject private var scanningController = ScanningModeController.shared

    /// Task 7.5: Total scannable items (messages + exit button)
    private var totalScannableItems: Int {
        messageSettings.customMessages.count + 1  // +1 for exit button
    }

    var body: some View {
        ZStack {
            // AC1: Calm, low-contrast dark background
            // Task 1.2: Color.black.opacity(0.9)
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            // Task 1.3, 1.6: VStack with vertical column layout
            // Story 11.3 Task 7.2: Wrap in ScannableContainer (AC5)
            ScannableContainer(
                itemCount: totalScannableItems,
                onSelect: { index in
                    // Task 7.4, 7.5: Handle selection based on index
                    if index < messageSettings.customMessages.count {
                        // Message button: speak the message
                        let message = messageSettings.customMessages[index]
                        speakMessage(message.text)
                    } else {
                        // Exit button: show confirmation
                        showExitConfirmation = true
                    }
                }
            ) { highlightedIndex in
                VStack(spacing: 16) {
                    Spacer()

                    // Story 10.3 AC4: Message buttons from customizable settings
                    // Task 4.1, 4.3: Display custom messages with custom colors
                    ForEach(Array(messageSettings.customMessages.enumerated()), id: \.element.id) { index, message in
                        FatigueModeButton(
                            message: message.text,
                            backgroundColor: message.color,
                            onTap: {
                                // Story 10.3 Task 4.4: Speak the custom message text via TTS
                                // Task 7.6: Existing tap behavior preserved
                                speakMessage(message.text)
                            }
                        )
                        // Task 7.3: Apply scanning highlight
                        .scanningHighlight(index: index, highlightedIndex: highlightedIndex)
                    }

                    // AC4, Task 3.1: Exit button with distinct styling (gray color)
                    // M2 Fix (Code Review): Added icon for visual exit indicator
                    FatigueModeButton(
                        message: "Mode normal",
                        backgroundColor: Color.gray,
                        icon: "arrow.backward.circle",
                        onTap: {
                            // Task 3.2: Show confirmation dialog
                            // Task 7.6: Existing tap behavior preserved
                            showExitConfirmation = true
                        }
                    )
                    // Task 3.1: Additional accessibility hint for exit button
                    .accessibilityHint("Retourne à l'interface normale")
                    // Task 7.5: Exit button is last in scanning sequence
                    .scanningHighlight(index: messageSettings.customMessages.count, highlightedIndex: highlightedIndex)

                    Spacer()
                }
            }
            // Task 1.6: Horizontal padding (32pt)
            .padding(.horizontal, 32)
        }
        // AC4, Task 3.3: Exit confirmation dialog
        .alert("Quitter le mode fatigue ?", isPresented: $showExitConfirmation) {
            // Task 3.5: Cancel action - close dialog, stay in fatigue mode
            Button("Annuler", role: .cancel) { }
            // Task 3.4: Confirmation action - disable fatigue mode and dismiss
            Button("Quitter", role: .destructive) {
                accessibilitySettings.isFatigueModeEnabled = false
                // H2 Fix (Code Review): VoiceOver announcement for mode change
                UIAccessibility.post(notification: .announcement, argument: "Mode normal activé")
                onDismiss()
            }
        }
    }

    // MARK: - AC3: TTS Action
    // Task 2.3: Connect button actions to speechService.speakText()
    private func speakMessage(_ message: String) {
        speechService.speakText(message)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct FatigueModeView_Previews: PreviewProvider {
    // L3 Fix (Code Review): Create preview-specific instances instead of shared singletons
    static var previews: some View {
        FatigueModeView(onDismiss: { })
            .environmentObject(SpeechService())  // L3 Fix: Use new instance for preview isolation
            .environmentObject(AccessibilitySettings())
    }
}
#endif
