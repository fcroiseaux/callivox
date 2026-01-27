//
//  GuidanceControlsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 4.2: UI Guidance Controls
//  Story 5.2: Enlarged touch targets for accessibility (60pt minimum)
//  Quick context controls for guiding AI suggestions in real-time.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI
import UIKit

// MARK: - GuidanceControlsView

/// Quick context controls for guiding AI suggestions (Story 4.2)
/// Displays a horizontal scrollable row of buttons for selecting guidance context.
/// AC1: Quick context buttons are visible and easily accessible
@MainActor
struct GuidanceControlsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            Text("Guide rapide")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Quick context buttons - horizontal scroll (AC1)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {  // Story 5.2: Increased from 10 for better accessibility (AC4)
                    ForEach(GuidanceContext.allCases) { context in
                        GuidanceButton(
                            context: context,
                            isSelected: suggestionService.currentGuidance == context,
                            isDisabled: suggestionService.isLoading,  // H1 Fix: Prevent race condition
                            action: { selectGuidance(context) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Contrôles de guidage IA")
    }

    // MARK: - Actions

    /// Handles guidance button tap with haptic feedback (AC1)
    private func selectGuidance(_ context: GuidanceContext) {
        // Haptic feedback - Story 5.2: Upgraded to .medium for better accessibility feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        if suggestionService.currentGuidance == context {
            // Deselect if already selected
            suggestionService.clearGuidance()
        } else {
            // Generate suggestions with new guidance
            Task {
                await suggestionService.generateGuidedSuggestions(context: context)
            }
        }
    }
}

// MARK: - GuidanceButton Component

/// Individual guidance button component (AC1)
/// Follows existing button patterns from SpeechShortcutsView.
/// H1 Fix: Added isDisabled parameter to prevent race conditions during loading.
@MainActor
struct GuidanceButton: View {
    let context: GuidanceContext
    let isSelected: Bool
    var isDisabled: Bool = false  // H1 Fix: Disable during loading
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: context.icon)
                    .font(.system(size: 16))  // Story 5.2: Increased from 14 for better visibility (AC3)
                Text(context.displayName)
                    .font(.body)  // Story 5.2: Increased from .subheadline for better readability (AC3)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 20)  // Story 5.2: Increased from 14 for larger touch target (AC2)
            .padding(.vertical, 16)  // Story 5.2: Increased from 8 for 60pt minimum height (AC1)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(24)  // Story 5.2: Proportional increase from 20 for larger button
            .frame(minHeight: 60)  // Story 5.2: Explicit 60pt minimum touch target (AC1)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.95, pressedColor: .clear, normalColor: .clear))
        .disabled(isDisabled)  // H1 Fix: Prevent interactions during loading
        .opacity(isDisabled ? 0.5 : 1.0)  // H1 Fix: Visual indication of disabled state
        .accessibilityLabel(context.displayName)
        .accessibilityHint(isDisabled
            ? "Chargement en cours, veuillez patienter"
            : "Génère des suggestions de type \(context.displayName.lowercased())")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
