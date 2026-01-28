//
//  EmergencyPanelView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 9.2: Create Emergency Panel with Critical Messages
//  Story 11.3: Scanning mode integration (AC5)
//  Full-screen emergency panel with large buttons for urgent communication
//

import SwiftUI
import UIKit

// MARK: - Emergency Message Model
// L3 Fix: Added Hashable conformance for efficient SwiftUI diffing
struct EmergencyMessage: Identifiable, Hashable {
    let id = UUID()
    let emoji: String
    let text: String
    let spokenText: String
    let backgroundColor: Color
    let accessibilityLabel: String
    let accessibilityHint: String

    // Hashable conformance (Color is not Hashable, so custom implementation)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: EmergencyMessage, rhs: EmergencyMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Story 9.2: Emergency Panel View (AC1-7)
@MainActor
struct EmergencyPanelView: View {
    // Story 9.2: AccessibilitySettings for enhanced mode reactivity
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    // Story 9.2 AC3, AC5: SpeechService for TTS with priority interruption
    @ObservedObject var speechService = SpeechService.shared
    // Story 9.2 AC3: PresetSentenceManager for recent history
    @ObservedObject var presetManager = PresetSentenceManager.shared
    // Story 9.3 Task 6.4: EmergencyMessageSettings for customizable messages
    @ObservedObject var messageSettings = EmergencyMessageSettings.shared

    // Story 11.3 Task 8.1: Add scanning mode references (AC5)
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared
    @ObservedObject private var scanningController = ScanningModeController.shared

    // Story 9.2 AC4: Callback for panel dismissal
    let onDismiss: () -> Void

    /// Task 8.5: Total scannable items (4 message buttons + 1 close button)
    private var totalScannableItems: Int {
        emergencyMessages.count + 1  // +1 for close button
    }

    // MARK: - Story 9.3 Task 6.1, 6.2, 6.3: Dynamic emergency messages from settings
    // AC3: Convert CustomEmergencyMessage to EmergencyMessage, keeping emojis/colors fixed
    private var emergencyMessages: [EmergencyMessage] {
        messageSettings.customMessages.map { custom in
            EmergencyMessage(
                emoji: custom.emoji,
                text: custom.displayText,
                spokenText: custom.spokenText,
                backgroundColor: custom.color,
                accessibilityLabel: custom.displayText,
                accessibilityHint: "Dit: \(custom.spokenText)"
            )
        }
    }

    // MARK: - AC2, AC6: Button dimensions based on accessibility mode
    // H1 Fix: Use accessibilitySettings properties instead of magic numbers
    // M5 Fix: Use minWidth constraint instead of fixed width for screen adaptability
    private var buttonMinWidth: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 180 : 160
    }

    // H1 Fix: Use existing modalButtonHeight property (120pt enhanced, 100pt standard)
    private var buttonHeight: CGFloat {
        accessibilitySettings.modalButtonHeight
    }

    // MARK: - AC6: Close button height based on accessibility mode
    // H1 Fix: Use existing primaryButtonHeight property (100pt enhanced, 80pt standard)
    private var closeButtonHeight: CGFloat {
        accessibilitySettings.primaryButtonHeight
    }

    // L2 Fix: Grid spacing conditional on accessibility mode
    private var gridSpacing: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 20 : 16
    }

    var body: some View {
        ZStack {
            // MARK: AC1: Semi-transparent dark background (0.85 opacity)
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                // AC4: Tap background to close panel
                .onTapGesture {
                    dismissPanel()
                }

            // Story 11.3 Task 8.2: Wrap grid and close button in ScannableContainer (AC5)
            ScannableContainer(
                itemCount: totalScannableItems,
                onSelect: { index in
                    // Task 8.4, 8.5: Handle selection based on index
                    if index < emergencyMessages.count {
                        // Message button: speak the emergency message
                        let message = emergencyMessages[index]
                        speakEmergencyMessage(message)
                    } else {
                        // Close button: dismiss panel
                        dismissPanel()
                    }
                }
            ) { highlightedIndex in
                VStack(spacing: 24) {
                    // MARK: AC1: Header "⚠️ URGENCE ⚠️" in large text
                    // M1 Fix: Added VoiceOver accessibility label for blind users
                    Text("⚠️ URGENCE ⚠️")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                        .accessibilityLabel("Panneau d'urgence")
                        .accessibilityAddTraits(.isHeader)

                    Spacer()

                    // MARK: AC2: 2x2 Grid of emergency buttons
                    // L2 Fix: Use conditional gridSpacing for enhanced accessibility
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: gridSpacing),
                        GridItem(.flexible(), spacing: gridSpacing)
                    ], spacing: gridSpacing) {
                        ForEach(Array(emergencyMessages.enumerated()), id: \.element) { index, message in
                            EmergencyMessageButton(
                                message: message,
                                minWidth: buttonMinWidth,
                                height: buttonHeight,
                                isEnhancedMode: accessibilitySettings.isEnhancedModeEnabled,
                                onTap: {
                                    // Task 8.6: Existing tap behavior preserved
                                    speakEmergencyMessage(message)
                                }
                            )
                            .environmentObject(accessibilitySettings)
                            // Task 8.3: Apply scanning highlight
                            .scanningHighlight(index: index, highlightedIndex: highlightedIndex)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()

                    // MARK: AC2: Close button "✕ Fermer" at bottom (minimum 80pt, 100pt enhanced)
                    Button(action: {
                        // Task 8.6: Existing tap behavior preserved
                        dismissPanel()
                    }) {
                        HStack(spacing: 8) {
                            Text("✕")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Fermer")
                                .font(.title2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 200, minHeight: closeButtonHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.5))
                        )
                    }
                    .buttonStyle(ScaleButtonStyle(
                        scaleAmount: accessibilitySettings.scaleAnimationAmount,
                        pressedColor: .clear,
                        normalColor: .clear,
                        animationDuration: accessibilitySettings.animationDuration
                    ))
                    // AC7: VoiceOver accessibility for close button
                    .accessibilityLabel("Fermer")
                    .accessibilityHint("Ferme le panneau d'urgence")
                    .accessibilityAddTraits(.isButton)
                    // Task 8.5: Close button is last in scanning sequence
                    .scanningHighlight(index: emergencyMessages.count, highlightedIndex: highlightedIndex)
                    .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - AC3, AC5: Speak emergency message with TTS priority
    private func speakEmergencyMessage(_ message: EmergencyMessage) {
        // AC3: Strong haptic feedback (.heavy)
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // AC5: SpeechService.speakText() handles TTS interruption internally
        // (calls currentSpeechTask?.cancel() and pcmStreamPlayer.stop())
        speechService.speakText(message.spokenText)

        // AC3: Add spoken message to recent history
        presetManager.addToRecentHistory(message.spokenText)

        // AC3: Panel remains open for additional messages (do NOT call onDismiss)
    }

    // MARK: - AC4: Dismiss panel with haptic feedback
    private func dismissPanel() {
        // AC4: Medium haptic feedback on close
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        onDismiss()
    }
}

// MARK: - Story 9.2 Task 2: Emergency Message Button Component (AC2, AC6, AC7)
@MainActor
struct EmergencyMessageButton: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    let message: EmergencyMessage
    let minWidth: CGFloat  // M5 Fix: Use minWidth for flexible sizing
    let height: CGFloat
    let isEnhancedMode: Bool  // L1 Fix: For conditional border opacity
    let onTap: () -> Void

    // L1 Fix: Border opacity conditional on enhanced mode for "maximized" contrast
    private var borderOpacity: Double {
        isEnhancedMode ? 0.5 : 0.3
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(message.emoji)
                    .font(.system(size: 36))
                Text(message.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            // M5 Fix: Use minWidth with flexible maxWidth for screen adaptability
            .frame(minWidth: minWidth, maxWidth: .infinity, minHeight: height)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(message.backgroundColor)
            )
            // AC2, L1 Fix: High contrast - conditional border opacity
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(borderOpacity), lineWidth: 2)
            )
            .shadow(color: message.backgroundColor.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: accessibilitySettings.scaleAnimationAmount,
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: accessibilitySettings.animationDuration
        ))
        // AC7: VoiceOver accessibility with French labels
        .accessibilityLabel(message.accessibilityLabel)
        .accessibilityHint(message.accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct EmergencyPanelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard Mode Preview
            EmergencyPanelView(onDismiss: {})
                .environmentObject(AccessibilitySettings())
                .previewDisplayName("Standard Mode")

            // Enhanced Accessibility Mode Preview
            EmergencyPanelView(onDismiss: {})
                .environmentObject({
                    let settings = AccessibilitySettings()
                    settings.isEnhancedModeEnabled = true
                    return settings
                }())
                .previewDisplayName("Enhanced Mode")
        }
    }
}
#endif
