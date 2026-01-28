//
//  SpeechShortcutsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 8.1: Updated with category grouping and accessibility support
//  Story 8.2: Added recent phrases history section
//  Story 11.1: Added time-based predictive phrases section
//

import SwiftUI
import UIKit

// MARK: - Story 8.2 Task 4.1: Recent Phrases Header View

/// Story 8.2 AC1, AC5: Header for the "Récents" section with long-press clear option
struct RecentPhrasesHeaderView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @EnvironmentObject var presetManager: PresetSentenceManager

    // Story 8.2 AC5 Task 5.3: State for clear confirmation dialog
    @Binding var showClearConfirmation: Bool

    // Story 8.2 AC4: Header height based on accessibility mode
    private var headerHeight: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 80 : 60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Story 8.2 Task 4.1: Clock icon for recent phrases
                Image(systemName: "clock.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)

                // Story 8.2 Task 4.1: "Récents" label
                Text("Récents")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .frame(height: headerHeight)
            .padding(.horizontal, 16)
            // Story 8.2 Task 5.1, AC5: Long-press context menu for clearing history
            .contextMenu {
                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    Label("Effacer l'historique", systemImage: "trash")
                }
            }

            // Separator line below header
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
        .accessibilityLabel("Récents")
        .accessibilityHint("Maintenez appuyé pour effacer l'historique")
    }
}

// MARK: - Story 8.2 Task 4: Recent Phrases Section

/// Story 8.2 AC1, AC2, AC4: Section displaying recently spoken phrases
struct RecentPhrasesSection: View {
    @EnvironmentObject var presetManager: PresetSentenceManager
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 8.2 Task 5.3: State for clear confirmation dialog
    @State private var showClearConfirmation = false

    // Code Review Fix L2: Constants for grid layout
    private static let recentPhraseMinWidth: CGFloat = 140
    private static let gridSpacing: CGFloat = 10

    // Story 8.2 Task 4.4: Grid columns for recent phrases (wider to fit time text)
    private let recentGridColumns = [
        GridItem(.adaptive(minimum: recentPhraseMinWidth), spacing: gridSpacing)
    ]

    // Story 8.2 Task 4.2, AC4: Button height from accessibility settings
    private var buttonHeight: CGFloat {
        accessibilitySettings.chipHeight
    }

    var body: some View {
        // Story 8.2 Task 6.2: Only display if there are recent phrases
        if !presetManager.displayedRecentPhrases.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Story 8.2 Task 4.1: Recent phrases header
                RecentPhrasesHeaderView(showClearConfirmation: $showClearConfirmation)
                    .environmentObject(accessibilitySettings)
                    .environmentObject(presetManager)

                // Story 8.2 AC1, AC2: Recent phrases in grid
                LazyVGrid(columns: recentGridColumns, spacing: 10) {
                    ForEach(presetManager.displayedRecentPhrases) { phrase in
                        recentPhraseButton(for: phrase)
                    }
                }
            }
            // Story 8.2 Task 5.3, AC5: Confirmation alert before clearing
            .alert("Effacer l'historique ?", isPresented: $showClearConfirmation) {
                Button("Annuler", role: .cancel) { }
                Button("Effacer", role: .destructive) {
                    presetManager.clearRecentHistory()
                }
            } message: {
                Text("Cette action supprimera toutes les phrases récentes.")
            }
        }
    }

    // MARK: - Story 8.2 Task 4.3: Recent Phrase Button

    @ViewBuilder
    private func recentPhraseButton(for phrase: RecentPhrase) -> some View {
        Button(action: {
            // Story 8.2 Task 4.5: Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Speak and add to history (moves to top)
            speechService.speakText(phrase.text)
            presetManager.addToRecentHistory(phrase.text)
        }) {
            VStack(spacing: 4) {
                // Story 8.2 AC2: Main phrase text
                Text(phrase.text)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)

                // Story 8.2 AC2: Relative time on second line
                Text(phrase.relativeTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(8)
            .frame(minWidth: 140, minHeight: buttonHeight)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .accessibilityLabel(phrase.text)
        .accessibilityHint("Prononcé \(phrase.relativeTimeString). Appuyez pour prononcer à nouveau.")
    }
}

// MARK: - Story 8.1 Task 3.2: Category Header View

/// Story 8.1 AC2: Category header with icon, label, and separator
struct CategoryHeaderView: View {
    let category: PhraseCategory
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 8.1 AC4: Header height based on accessibility mode
    private var headerHeight: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 80 : 60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Story 8.1 AC2: Icon for category
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)

                // Story 8.1 AC2: Category label with larger font
                Text(category.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()
            }
            .frame(height: headerHeight)
            .padding(.horizontal, 16)

            // Story 8.1 AC2: Separator line below header
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
    }
}

// MARK: - Story 8.1: Main SpeechShortcutsView

struct SpeechShortcutsView: View {
    @EnvironmentObject var presetManager: PresetSentenceManager
    @EnvironmentObject var speechService: SpeechService

    // Story 8.1 Task 3.1: Add accessibility settings
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Story 11.1 Task 4.1: Add time-based phrase settings
    @EnvironmentObject var timeSettings: TimeBasedPhraseSettings

    // Story 8.1: Grid columns for phrase display
    private let gridColumns = [
        GridItem(.adaptive(minimum: 120), spacing: 10)
    ]

    // Story 8.1 Task 3.5: Button height from accessibility settings
    private var buttonHeight: CGFloat {
        accessibilitySettings.chipHeight
    }

    // Calcul de la hauteur maximale requise pour les boutons, en fonction du texte
    private func calculateMaxButtonHeight(for phrases: [CategorizedPhrase]) -> CGFloat {
        let horizontalPadding: CGFloat = 16
        let textWidth: CGFloat = 120 - horizontalPadding
        let font = UIFont.preferredFont(forTextStyle: .subheadline)
        let verticalPadding: CGFloat = 16

        let heights = phrases.map { phrase -> CGFloat in
            let boundingBox = phrase.text.boundingRect(
                with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
                options: .usesLineFragmentOrigin,
                attributes: [.font: font],
                context: nil
            )
            return ceil(boundingBox.height) + verticalPadding
        }

        let calculatedMax = heights.max() ?? buttonHeight
        return max(calculatedMax, buttonHeight)
    }

    var body: some View {
        // Story 8.2 Task 6: Show content if recent phrases OR selected phrases exist
        // Story 11.1 Task 4.4: Also check for time-based phrases
        let hasRecentPhrases = !presetManager.displayedRecentPhrases.isEmpty
        let hasSelectedPhrases = !presetManager.selectedCategorizedPresets.isEmpty
        let hasTimeBasedPhrases = timeSettings.hasPhrasesForCurrentPeriod

        if hasRecentPhrases || hasSelectedPhrases || hasTimeBasedPhrases {
            VStack(alignment: .leading, spacing: 16) {
                // Story 11.1 Task 4.1, AC1: Time-based phrases section at top
                TimeBasedPhrasesSection()
                    .environmentObject(timeSettings)
                    .environmentObject(presetManager)
                    .environmentObject(speechService)
                    .environmentObject(accessibilitySettings)

                // Story 8.2 Task 6.1, AC1: Recent phrases section above categories
                RecentPhrasesSection()
                    .environmentObject(presetManager)
                    .environmentObject(speechService)
                    .environmentObject(accessibilitySettings)

                // Story 8.1 Task 3.3: Iterate over categories with phrases
                ForEach(presetManager.categoriesWithPhrases(), id: \.self) { category in
                    categorySection(for: category)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Story 8.1 AC1, AC2: Category Section

    @ViewBuilder
    private func categorySection(for category: PhraseCategory) -> some View {
        let phrasesInCategory = presetManager.phrasesByCategory()[category] ?? []

        // Story 8.1 Task 3.4: Only display categories that have phrases
        if !phrasesInCategory.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Story 8.1 Task 3.2: Category header
                CategoryHeaderView(category: category)
                    .environmentObject(accessibilitySettings)

                // Story 8.1 AC2: Phrases in grid below header
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(phrasesInCategory) { phrase in
                        phraseButton(for: phrase, maxHeight: calculateMaxButtonHeight(for: phrasesInCategory))
                    }
                }
            }
        }
    }

    // MARK: - Phrase Button

    @ViewBuilder
    private func phraseButton(for phrase: CategorizedPhrase, maxHeight: CGFloat) -> some View {
        Button(action: {
            speechService.speakText(phrase.text)
            presetManager.addToRecentHistory(phrase.text)  // Story 8.2 Task 3.1, AC3
        }) {
            Text(phrase.text)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 120, height: maxHeight)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .accessibilityLabel(phrase.text)
        .accessibilityHint("Appuyez pour prononcer cette phrase")
    }
}

// MARK: - Code Review Fix L3: Preview Provider

#Preview("SpeechShortcutsView") {
    SpeechShortcutsView()
        .environmentObject(PresetSentenceManager.shared)
        .environmentObject(SpeechService.shared)
        .environmentObject(AccessibilitySettings())
        .environmentObject(TimeBasedPhraseSettings.shared)
}

#Preview("RecentPhrasesSection") {
    RecentPhrasesSection()
        .environmentObject(PresetSentenceManager.shared)
        .environmentObject(SpeechService.shared)
        .environmentObject(AccessibilitySettings())
        .padding()
}
