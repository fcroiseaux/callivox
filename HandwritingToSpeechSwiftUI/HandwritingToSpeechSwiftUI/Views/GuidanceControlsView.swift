//
//  GuidanceControlsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 4.2: UI Guidance Controls (original implementation)
//  Story 5.2: Enlarged touch targets for accessibility (60pt minimum)
//  Story 6.1: Replaced horizontal scroll with dropdown + modal menu for accessibility
//  Quick context controls for guiding AI suggestions in real-time.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI
import UIKit

// MARK: - GuidanceControlsView

/// Quick context controls for guiding AI suggestions (Story 4.2, modified in Story 6.1)
/// Story 6.1: Replaced horizontal scrollable row with dropdown button + full-screen modal
/// for better accessibility with motor impairments.
/// AC1: Single dropdown button showing current context or "Guide rapide"
@MainActor
struct GuidanceControlsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared
    // Story 7.2: Add accessibility settings for conditional sizing (AC2, AC5)
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 6.1 Task 2.3: State for modal presentation
    @State private var showContextModal = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Story 6.1 AC1: Dropdown button replacing horizontal scroll
            // Removed: Header "Guide rapide" - now shown in dropdown button itself
            // Removed: ScrollView(.horizontal) + HStack + ForEach GuidanceButton (Story 6.1 Task 2.1, 2.2)
            // M1 Fix: Removed legacy GuidanceButton struct (dead code cleanup)

            HStack {
                // Story 6.1 AC1: Dropdown trigger for guidance context modal
                Button(action: {
                    // L2 Fix: Haptic feedback on modal open
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                    showContextModal = true
                }) {
                    HStack(spacing: 8) {
                        if let context = suggestionService.currentGuidance {
                            Image(systemName: context.icon)
                            Text("Contexte: \(context.displayName)")
                        } else {
                            Image(systemName: "chevron.down.circle")
                            Text("Guide rapide")
                        }
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .font(.body)
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .frame(minHeight: accessibilitySettings.buttonHeight)  // Story 7.2 AC2: Conditional height (80pt enhanced, 60pt standard)
                    .background(suggestionService.currentGuidance != nil ? Color.accentColor : Color(.systemGray5))
                    .foregroundColor(suggestionService.currentGuidance != nil ? .white : .primary)
                    .cornerRadius(24)
                }
                // M1 Fix (Code Review 7.3): Use configurable animation values for AC2
                .buttonStyle(ScaleButtonStyle(
                    scaleAmount: accessibilitySettings.scaleAnimationAmount,
                    pressedColor: .clear,
                    normalColor: .clear,
                    animationDuration: accessibilitySettings.animationDuration
                ))
                .disabled(suggestionService.isLoading)
                .opacity(suggestionService.isLoading ? 0.5 : 1.0)
                // M4 Fix: Conditional accessibility hint for loading state
                .accessibilityLabel(suggestionService.currentGuidance?.displayName ?? "Aucun contexte sélectionné")
                .accessibilityHint(suggestionService.isLoading
                    ? "Chargement en cours, veuillez patienter"
                    : "Ouvre le menu de sélection de contexte")

                Spacer()
            }
            .padding(.horizontal)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Contrôles de guidage IA")
        // Story 6.1 Task 2.5: Connect dropdown to present modal
        .fullScreenCover(isPresented: $showContextModal) {
            GuidanceContextModal(
                currentContext: suggestionService.currentGuidance,
                isLoading: suggestionService.isLoading,
                onSelect: { context in
                    handleSelection(context)
                },
                onDismiss: {
                    showContextModal = false
                }
            )
            .environmentObject(accessibilitySettings)  // Story 7.2: Inject for conditional modal button sizes
        }
    }

    // MARK: - Actions

    /// Handles guidance selection from modal (Story 6.1 AC5, AC6)
    /// - Parameter context: The selected context, or nil to clear guidance
    private func handleSelection(_ context: GuidanceContext?) {
        if let context = context {
            // Select new context - generate suggestions
            Task {
                await suggestionService.generateGuidedSuggestions(context: context)
            }
        } else {
            // Deselect (AC6) - clear guidance
            suggestionService.clearGuidance()
        }
    }
}

// M1 Fix: Removed legacy GuidanceButton struct
// Original Story 4.2/5.2 implementation was replaced by Story 6.1 modal approach.
// Legacy code removed to reduce maintenance burden and improve code clarity.
// See git history for original implementation if needed.

// MARK: - Preview
// L2 Fix (Code Review): Added #Preview for Xcode Canvas testing

#Preview {
    GuidanceControlsView()
        .environmentObject(AccessibilitySettings())
        .padding()
}
