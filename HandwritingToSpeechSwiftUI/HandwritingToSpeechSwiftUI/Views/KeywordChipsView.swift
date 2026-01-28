//
//  KeywordChipsView.swift
//  HandwritingToSpeechSwiftUI
//
//  InvincibleVoice: Quick keyword chips for rapid responses.
//  Story 5.4: Displays keywords in a grid layout for accessibility (no swiping required).
//  Story 11.3: Scanning mode integration (AC2, AC3)
//  Created by CalliVox on 2026-01-27.
//

import SwiftUI
import UIKit

// MARK: - KeywordChipsView

/// Grid view of keyword chips for quick responses (accessibility optimized).
/// Each chip speaks the keyword immediately via TTS when tapped.
///
/// InvincibleVoice Integration:
/// - Displays 10 quick keywords from LLM response in a grid layout
/// - Story 5.4: Grid layout eliminates swiping for users with motor impairments
/// - Tap to speak keyword immediately
/// - Visual feedback on selection
@MainActor
struct KeywordChipsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared
    @EnvironmentObject var speechService: SpeechService
    // Story 7.2: Add accessibility settings for conditional sizing (AC1, AC5)
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    // Story 8.2 Task 3.3: Add preset manager for recent history tracking
    @EnvironmentObject var presetManager: PresetSentenceManager
    // Story 11.3 Task 6.1: Add scanning mode references (AC2, AC3)
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared
    @ObservedObject private var scanningController = ScanningModeController.shared

    var body: some View {
        // Only show when keywords are available
        if !suggestionService.keywords.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                Text("Réponses rapides")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // Story 5.4: Replaced horizontal scroll with grid layout for accessibility (AC1)
                // Users with tremors can see all keywords without swiping gestures
                // Note: 12pt spacing preserved from Story 5.1 touch target improvements
                // Story 11.3 Task 6.1: Wrap grid in ScannableContainer for scanning mode (AC2, AC3)
                ScannableContainer(
                    itemCount: suggestionService.keywords.count,
                    onSelect: { index in
                        // Task 6.3: Handle selection - speak keyword at selected index
                        let keyword = suggestionService.keywords[index]
                        speakKeyword(keyword)
                    }
                ) { highlightedIndex in
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],  // Story 5.4 AC1: Adaptive columns, min 100pt
                        spacing: 12  // Story 5.4 AC3: 12pt spacing (originally Story 5.1)
                    ) {
                        ForEach(Array(suggestionService.keywords.enumerated()), id: \.element) { index, keyword in
                            KeywordChip(
                                keyword: keyword,
                                chipHeight: accessibilitySettings.chipHeight,  // Story 7.2 AC1
                                onTap: { speakKeyword(keyword) },  // Task 6.4: Existing tap behavior preserved
                                // Story 7.3 AC2: Conditional animation values
                                scaleAnimationAmount: accessibilitySettings.isEnhancedModeEnabled ? 0.98 : 0.92,
                                animationDuration: accessibilitySettings.isEnhancedModeEnabled ? 0.05 : 0.1
                            )
                            // Task 6.2: Apply scanning highlight to each chip
                            // L1 Fix: Use cornerRadius 24 to match KeywordChip's cornerRadius
                            .scanningHighlight(index: index, highlightedIndex: highlightedIndex, cornerRadius: 24)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mots-clés de réponse rapide")
            .accessibilityHint("Grille de réponses rapides, naviguez avec les gestes de balayage")  // Story 5.4: Grid navigation hint
        }
    }

    // MARK: - Actions

    /// Speaks the keyword immediately via TTS with haptic feedback.
    private func speakKeyword(_ keyword: String) {
        // Story 5.1 AC4: Enhanced haptic feedback for accessibility (medium instead of light)
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Speak the keyword
        speechService.speakText(keyword)

        // Story 8.2 Task 3.3, AC3: Add to recent phrases history
        presetManager.addToRecentHistory(keyword)

        // Add to conversation history for context
        suggestionService.addToHistory(userMessage: keyword)

        // Clear suggestions after speaking (conversation moved forward)
        suggestionService.clearSuggestions()

        // F1 Fix: Unfreeze suggestions after speaking (exit edit mode if active)
        suggestionService.unfreezeSuggestions()
    }
}

// MARK: - KeywordChip Component

/// Individual keyword chip button.
/// Speaks the keyword immediately when tapped.
/// Story 7.2: Accepts chipHeight parameter for Enhanced Mode conditional sizing
/// Story 7.3: Accepts animation parameters for reduced motion
@MainActor
struct KeywordChip: View {
    let keyword: String
    let chipHeight: CGFloat  // Story 7.2 AC1: Conditional height (80pt enhanced, 60pt standard)
    let onTap: () -> Void
    // Story 7.3 AC2: Animation parameters for reduced motion
    var scaleAnimationAmount: CGFloat = 0.92
    var animationDuration: Double = 0.1

    var body: some View {
        Button(action: onTap) {
            Text(keyword)
                // Story 5.1 AC3: Increased font from .subheadline to .body for readability
                .font(.body)
                .fontWeight(.medium)
                // Story 5.1 AC2: Increased horizontal padding from 14pt to 20pt
                .padding(.horizontal, 20)
                // Story 5.1 AC1: Increased vertical padding from 8pt to 16pt
                .padding(.vertical, 16)
                .background(Color.accentColor.opacity(0.15))
                .foregroundColor(.accentColor)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
                // Story 7.2 AC1: Conditional touch target height (80pt enhanced, 60pt standard)
                .frame(minHeight: chipHeight)
        }
        // Story 7.3 AC2: Use configurable animation parameters
        .buttonStyle(KeywordChipButtonStyle(
            scaleAmount: scaleAnimationAmount,
            animationDuration: animationDuration
        ))
        .accessibilityLabel(keyword)
        .accessibilityHint("Double-tapez pour prononcer \(keyword)")
    }
}

// MARK: - KeywordChipButtonStyle

/// Custom button style for keyword chips with scale and color feedback.
/// Story 7.3 AC2: Updated with configurable animation parameters
struct KeywordChipButtonStyle: ButtonStyle {
    // Story 7.3 AC2: Configurable animation parameters
    var scaleAmount: CGFloat = 0.92
    var animationDuration: Double = 0.1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Story 7.3 AC2: Use configurable scale amount
            .scaleEffect(configuration.isPressed ? scaleAmount : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            // Story 7.3 AC2: Use configurable animation duration
            .animation(.easeInOut(duration: animationDuration), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        KeywordChipsView()
            .environmentObject(SpeechService.shared)
            .environmentObject(AccessibilitySettings())  // Story 7.2: Required for conditional sizing
            .environmentObject(PresetSentenceManager.shared)  // Story 8.2: Required for recent history
    }
    .padding()
}
