//
//  KeywordChipsView.swift
//  HandwritingToSpeechSwiftUI
//
//  InvincibleVoice: Quick keyword chips for rapid responses.
//  Displays horizontal scrollable keyword buttons that speak immediately on tap.
//  Created by CalliVox on 2026-01-27.
//

import SwiftUI
import UIKit

// MARK: - KeywordChipsView

/// Horizontal scrollable view of keyword chips for quick responses.
/// Each chip speaks the keyword immediately via TTS when tapped.
///
/// InvincibleVoice Integration:
/// - Displays 10 quick keywords from LLM response
/// - Tap to speak keyword immediately
/// - Visual feedback on selection
@MainActor
struct KeywordChipsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared
    @EnvironmentObject var speechService: SpeechService

    var body: some View {
        // Only show when keywords are available
        if !suggestionService.keywords.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Header
                Text("Réponses rapides")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                // Keyword chips - horizontal scroll
                // Story 5.1: Increased spacing from 8pt to 12pt for better touch target separation
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(suggestionService.keywords, id: \.self) { keyword in
                            KeywordChip(
                                keyword: keyword,
                                onTap: { speakKeyword(keyword) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Mots-clés de réponse rapide")
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
@MainActor
struct KeywordChip: View {
    let keyword: String
    let onTap: () -> Void

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
                // Story 5.1 AC1: Ensure minimum touch target height of 60pt
                .frame(minHeight: 60)
        }
        .buttonStyle(KeywordChipButtonStyle())
        .accessibilityLabel(keyword)
        .accessibilityHint("Double-tapez pour prononcer \(keyword)")
    }
}

// MARK: - KeywordChipButtonStyle

/// Custom button style for keyword chips with scale and color feedback.
struct KeywordChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    VStack {
        KeywordChipsView()
            .environmentObject(SpeechService.shared)
    }
    .padding()
}
