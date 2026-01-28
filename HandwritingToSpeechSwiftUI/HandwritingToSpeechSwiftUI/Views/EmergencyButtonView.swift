//
//  EmergencyButtonView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 9.1: Add Emergency Panel Trigger
//  Emergency button component with high visibility and accessibility support
//

import SwiftUI
import UIKit

// MARK: - Story 9.1: Emergency Button Component (AC1, AC2, AC3, AC4, AC5)
// Always-visible emergency button with enhanced accessibility support
@MainActor
struct EmergencyButtonView: View {
    // Story 9.1 AC1, AC3: AccessibilitySettings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    // Story 9.1 AC2 Task 2.4: System reduce motion setting
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // Callback when button is tapped
    var onTap: () -> Void

    // Story 9.1 AC2 Task 2.2: Subtle pulse animation state
    @State private var isPulsing = false

    // MARK: - Story 9.1 AC3: Enhanced mode pure red color
    // Standard mode: Color.red, Enhanced mode: Pure #FF0000
    private var buttonColor: Color {
        accessibilitySettings.isEnhancedModeEnabled
            ? Color(red: 1.0, green: 0, blue: 0)  // Pure #FF0000
            : Color.red
    }

    // MARK: - Story 9.1 AC3 Task 5.2: Shadow parameters based on mode
    private var shadowRadius: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 10 : 8
    }

    private var shadowOpacity: Double {
        accessibilitySettings.isEnhancedModeEnabled ? 0.8 : 0.6
    }

    var body: some View {
        Button(action: {
            // Story 9.1 AC4 Task 4.2: Heavy haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 8) {
                // Story 9.1 AC1 Task 1.3: SF Symbol for emergency
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20, weight: .bold))
                // Story 9.1 AC1: "⚡ URGENCE" label (M1 Fix: Added lightning emoji per AC1 spec)
                Text("⚡ URGENCE")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            // Story 9.1 AC1, AC3 Task 1.4, 5.1: Conditional height (60pt standard, 80pt enhanced)
            .frame(minHeight: accessibilitySettings.buttonHeight)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(buttonColor)
            )
            // Story 9.1 AC2 Task 2.1: White border for visibility
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.5), lineWidth: 2)
            )
            // Story 9.1 AC2 Task 2.1, AC3 Task 5.2: Shadow glow effect
            .shadow(color: buttonColor.opacity(shadowOpacity), radius: shadowRadius, x: 0, y: 4)
        }
        // Story 9.1: Use existing ScaleButtonStyle pattern from ControlButtonsView
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: accessibilitySettings.scaleAnimationAmount,
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: accessibilitySettings.animationDuration
        ))
        // Story 9.1 AC2 Task 2.2, 2.3: Subtle opacity pulse animation
        .opacity(isPulsing ? 0.85 : 1.0)
        .onAppear {
            // Story 9.1 AC2 Task 2.4: Only animate if reduce motion is not enabled
            // Check both system setting and app setting
            if !reduceMotion && !accessibilitySettings.shouldReduceMotion {
                withAnimation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
        }
        // Story 9.1 AC5 Task 1.5: French VoiceOver accessibility
        .accessibilityLabel("Urgence")
        .accessibilityHint("Ouvre le panneau d'urgence pour les messages critiques")
        // Story 9.1 AC5 Task 1.6: Button trait for VoiceOver
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Story 9.2: EmergencyPanelPlaceholderView removed
// The full emergency panel is now implemented in EmergencyPanelView.swift

// MARK: - Preview Provider
#if DEBUG
struct EmergencyButtonView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Standard Mode Preview
            Text("Standard Mode (60pt)")
                .font(.caption)
                .foregroundColor(.secondary)
            EmergencyButtonView(onTap: {})
                .environmentObject(AccessibilitySettings())

            Divider()
                .padding(.vertical, 8)

            // M2 Fix: Enhanced Mode Preview
            Text("Enhanced Mode (80pt)")
                .font(.caption)
                .foregroundColor(.secondary)
            EmergencyButtonView(onTap: {})
                .environmentObject({
                    let settings = AccessibilitySettings()
                    settings.isEnhancedModeEnabled = true
                    return settings
                }())
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
#endif
