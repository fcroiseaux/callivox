//
//  GuidanceContextModal.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 6.1: Modal menu for guidance contexts (Epic 6 - Simplified Navigation)
//  Replaces horizontal scroll with accessible full-screen selection.
//  Created by CalliVox on 2026-01-27.
//

import SwiftUI
import UIKit

// MARK: - GuidanceContextModal

/// Full-screen modal for selecting guidance contexts (Story 6.1)
/// Provides large touch targets in a 2-column grid for users with motor impairments.
/// AC2: Full-screen modal opens with all context options
/// AC3: Contexts displayed in 2-column grid with 150x100pt minimum buttons
/// AC4: Close button with 60pt minimum height
/// AC5: Context selection with haptic feedback
/// AC6: Deselection support (tap selected context to clear)
@MainActor
struct GuidanceContextModal: View {
    let currentContext: GuidanceContext?
    let isLoading: Bool
    let onSelect: (GuidanceContext?) -> Void  // nil for deselection
    let onDismiss: () -> Void

    // Story 7.2: Add accessibility settings for conditional sizing (AC2)
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 6.1 AC3: 2 flexible columns with minimum 150pt each
    private let columns = [
        GridItem(.flexible(minimum: 150), spacing: 16),
        GridItem(.flexible(minimum: 150), spacing: 16)
    ]

    // L3 Fix: VoiceOver focus state for header announcement
    @AccessibilityFocusState private var isHeaderFocused: Bool

    var body: some View {
        ZStack {
            // Story 6.1 AC2: Semi-transparent dark background (0.85 opacity)
            // M3 Fix: Removed background tap dismiss - users with motor impairments
            // may accidentally dismiss when trying to reach buttons. Use close button instead.
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Story 6.1 AC3: Header with clear styling
                Text("Choisir un contexte")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($isHeaderFocused)  // L3 Fix: Focus on open

                // Story 6.1 AC3: Context grid with 2 columns
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(GuidanceContext.allCases) { context in
                        GuidanceContextButton(  // L1 Fix: Renamed from ModalGuidanceButton
                            context: context,
                            isSelected: currentContext == context,
                            isDisabled: isLoading,
                            modalButtonHeight: accessibilitySettings.modalButtonHeight,  // Story 7.2 AC2
                            action: {
                                handleSelection(context)
                            }
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Story 7.2 AC2: Close button with conditional height (80pt enhanced, 60pt standard)
                Button(action: onDismiss) {
                    Text("Fermer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: accessibilitySettings.buttonHeight)  // Story 7.2 AC2
                        .background(Color(.systemGray4))
                        .cornerRadius(12)
                }
                .buttonStyle(ScaleButtonStyle(scaleAmount: 0.95, pressedColor: .clear, normalColor: .clear))
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .accessibilityLabel("Fermer")
                .accessibilityHint("Ferme le menu de sélection sans changer le contexte")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Menu de sélection de contexte")
        .onAppear {
            // L3 Fix: Announce modal to VoiceOver users
            isHeaderFocused = true
        }
    }

    // MARK: - Private Methods

    /// Handles context selection with haptic feedback (AC5) and deselection support (AC6)
    private func handleSelection(_ context: GuidanceContext) {
        // Story 6.1 AC5: Haptic feedback on selection (.medium style consistent with Story 5.2)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        if currentContext == context {
            // Story 6.1 AC6: Deselect if tapping already selected context
            onSelect(nil)
        } else {
            // Select new context
            onSelect(context)
        }
        onDismiss()
    }
}

// MARK: - GuidanceContextButton Component

/// Large button for modal context selection (Story 6.1 AC3)
/// Minimum 150x100pt touch target with icon and text label.
/// L1 Fix: Renamed from ModalGuidanceButton for consistency with Dev Notes
/// Story 7.2: Accepts modalButtonHeight parameter for Enhanced Mode conditional sizing
@MainActor
struct GuidanceContextButton: View {
    let context: GuidanceContext
    let isSelected: Bool
    var isDisabled: Bool = false
    let modalButtonHeight: CGFloat  // Story 7.2 AC2: Conditional height (120pt enhanced, 100pt standard)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: context.icon)
                    .font(.system(size: 32))
                Text(context.displayName)
                    .font(.headline)
                    .multilineTextAlignment(.center)
            }
            .frame(minWidth: 150, minHeight: modalButtonHeight)  // Story 7.2 AC2: Conditional height
            .padding()
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.95, pressedColor: .clear, normalColor: .clear))
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .accessibilityLabel(context.displayName)
        .accessibilityHint(isSelected
            ? "Contexte actif. Tapez pour désélectionner"
            : "Tapez pour sélectionner ce contexte")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview
// L2 Fix (Code Review): Added #Preview for Xcode Canvas testing

#Preview("Modal - No Selection") {
    GuidanceContextModal(
        currentContext: nil,
        isLoading: false,
        onSelect: { _ in },
        onDismiss: { }
    )
    .environmentObject(AccessibilitySettings())
}

#Preview("Modal - With Selection") {
    GuidanceContextModal(
        currentContext: .greeting,
        isLoading: false,
        onSelect: { _ in },
        onDismiss: { }
    )
    .environmentObject(AccessibilitySettings())
}
