import SwiftUI
import UIKit

// MARK: - Story 6.2: Settings Submenu Modal (AC2)
// Provides a separate settings menu to reduce cognitive load in the main sidebar

/// Story 6.2 AC2: Settings submenu with all configuration options
/// Modal presentation consistent with Story 6.1 GuidanceContextModal pattern
/// Story 7.3: Added accessibility settings for reduced animations and high contrast
@MainActor
struct SettingsSubmenuView: View {
    let onSelectSetting: (SettingType) -> Void
    let onDismiss: () -> Void
    let showPrivacyOption: Bool  // Based on AppConfig.Features.skipAuthentication
    // Story 7.3 Task 4.1: Add accessibility settings for conditional opacity and animations
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 6.2 AC2: Available settings that were moved from main sidebar
    enum SettingType {
        case tts             // Opens GradiumSettingsView
        case llm             // Opens LLMSettingsView
        case personalization // Opens PersonalizationSettingsView
        case accessibility   // Story 7.1 AC1: Opens AccessibilitySettingsView
        case privacy         // Opens UsageSettingsView (conditional)
    }

    var body: some View {
        ZStack {
            // Story 6.2 AC2: Semi-transparent background (consistent with Story 6.1)
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Story 6.2 AC2: Header
                Text("Paramètres")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                // Story 6.2 AC2: Settings buttons list (60pt minimum each)
                VStack(spacing: 16) {
                    // Story 6.2 AC2: Service TTS button
                    SettingsMenuButton(
                        icon: "waveform",
                        title: "Service TTS",
                        color: .mint,
                        action: { handleSelection(.tts) },
                        secondaryTextOpacity: accessibilitySettings.secondaryTextOpacity,  // Story 7.3 AC1
                        scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                        animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                    )

                    // Story 6.2 AC2: Service IA button
                    SettingsMenuButton(
                        icon: "brain",
                        title: "Service IA",
                        color: .indigo,
                        action: { handleSelection(.llm) },
                        secondaryTextOpacity: accessibilitySettings.secondaryTextOpacity,  // Story 7.3 AC1
                        scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                        animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                    )

                    // Story 6.2 AC2: Personnalisation IA button
                    SettingsMenuButton(
                        icon: "person.text.rectangle",
                        title: "Personnalisation IA",
                        color: .cyan,
                        action: { handleSelection(.personalization) },
                        secondaryTextOpacity: accessibilitySettings.secondaryTextOpacity,  // Story 7.3 AC1
                        scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                        animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                    )

                    // Story 7.1 AC1: Accessibilité button
                    SettingsMenuButton(
                        icon: "accessibility",
                        title: "Accessibilité",
                        color: .orange,
                        action: { handleSelection(.accessibility) },
                        secondaryTextOpacity: accessibilitySettings.secondaryTextOpacity,  // Story 7.3 AC1
                        scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                        animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                    )

                    // Story 6.2 AC2: Confidentialité button (conditional)
                    if showPrivacyOption {
                        SettingsMenuButton(
                            icon: "lock.shield",
                            title: "Confidentialité",
                            color: .teal,
                            action: { handleSelection(.privacy) },
                            secondaryTextOpacity: accessibilitySettings.secondaryTextOpacity,  // Story 7.3 AC1
                            scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,  // Story 7.3 AC2
                            animationDuration: accessibilitySettings.animationDuration  // Story 7.3 AC2
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Story 6.2 AC2: Close button (60pt minimum height)
                Button(action: {
                    // Story 6.2 AC4: Haptic feedback on dismiss
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    onDismiss()
                }) {
                    Text("Fermer")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 60)  // Story 6.2 AC2: 60pt minimum
                        .background(Color(.systemGray4))
                        .cornerRadius(12)
                }
                // Story 7.3 AC2: Use configurable animation parameters
                .buttonStyle(ScaleButtonStyle(
                    scaleAmount: accessibilitySettings.scaleAnimationAmount,
                    pressedColor: .clear,
                    normalColor: .clear,
                    animationDuration: accessibilitySettings.animationDuration
                ))
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .accessibilityLabel("Fermer")
                .accessibilityHint("Ferme le menu des paramètres")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Menu des paramètres")
    }

    // Story 6.2 AC4: Handle selection with haptic feedback
    private func handleSelection(_ setting: SettingType) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        onSelectSetting(setting)
        onDismiss()
    }
}

// MARK: - Story 6.2: Settings Menu Button Component
/// Individual button in settings submenu with 60pt minimum height (AC2)
/// Story 7.3: Updated with configurable opacity and animation parameters
@MainActor
struct SettingsMenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    // Story 7.3 AC1, AC2: Configurable animation parameters
    var secondaryTextOpacity: Double = 0.6
    var scaleAnimationAmount: CGFloat = 0.97
    var animationDuration: Double = 0.2

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.body)
                    // Story 7.3 AC1, Task 4.2: Use configurable secondary text opacity
                    .foregroundColor(.white.opacity(secondaryTextOpacity))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)  // Story 6.2 AC2: minimum 60pt
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
        }
        // Story 7.3 AC2: Use configurable animation parameters
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: scaleAnimationAmount,
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: animationDuration
        ))
        // Story 6.2 AC5: French accessibility labels
        .accessibilityLabel(title)
        .accessibilityHint("Ouvre les réglages \(title.lowercased())")
    }
}

// MARK: - Preview
// Story 7.3: Preview with AccessibilitySettings environment object
#Preview {
    SettingsSubmenuView(
        onSelectSetting: { _ in },
        onDismiss: {},
        showPrivacyOption: true
    )
    .environmentObject(AccessibilitySettings())
}
