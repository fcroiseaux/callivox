//
//  TimeBasedPhrasesSection.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.1: Time-Based Predictive Phrases
//  Task 2: View component for displaying time-based phrase suggestions
//

import SwiftUI
import UIKit

// MARK: - Story 11.1 Task 2.3: Time-Based Phrases Header View

/// Header for the "Suggestions du moment" section (AC1)
/// Follows RecentPhrasesHeaderView pattern with time period indicator
struct TimeBasedPhrasesHeaderView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @EnvironmentObject var timeSettings: TimeBasedPhraseSettings

    /// Current time period for display
    private var currentPeriod: TimePeriod {
        timeSettings.currentTimePeriod
    }

    /// Story 11.1 Task 2.6: Header height based on accessibility mode
    private var headerHeight: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 80 : 60
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                // Story 11.1 Task 2.3: Clock icon with time period icon
                Image(systemName: currentPeriod.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.accentColor)

                // Story 11.1 Task 2.3, 2.4: "Suggestions du moment" with period name
                Text("Suggestions du moment")
                    .font(.headline)
                    .foregroundColor(.primary)

                // Story 11.1 Task 2.4: Current period indicator
                Text("(\(currentPeriod.displayName))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .frame(height: headerHeight)
            .padding(.horizontal, 16)

            // Separator line below header
            Rectangle()
                .fill(Color.secondary.opacity(0.3))
                .frame(height: 1)
        }
        .accessibilityLabel("Suggestions du moment - \(currentPeriod.displayName)")
        .accessibilityHint("Phrases contextuelles pour cette période de la journée")
    }
}

// MARK: - Story 11.1 Task 2: Time-Based Phrases Section

/// Main section displaying time-based predictive phrases (AC: 1, 6)
/// Shows contextual phrase suggestions based on current time of day
struct TimeBasedPhrasesSection: View {
    // Story 11.1 Task 2.2: EnvironmentObject injections
    @EnvironmentObject var timeSettings: TimeBasedPhraseSettings
    @EnvironmentObject var presetManager: PresetSentenceManager
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Code Review Fix M3: Track if section was previously visible for VoiceOver announcement
    @State private var wasVisible = false

    // Grid columns for phrase display (same as RecentPhrasesSection)
    private static let phraseMinWidth: CGFloat = 120
    private static let gridSpacing: CGFloat = 10

    private let gridColumns = [
        GridItem(.adaptive(minimum: phraseMinWidth), spacing: gridSpacing)
    ]

    /// Story 11.1 Task 2.6: Button height from accessibility settings
    private var buttonHeight: CGFloat {
        accessibilitySettings.chipHeight
    }

    var body: some View {
        // Story 11.1 Task 2.7, AC1: Only show when enabled and current period has phrases
        if let phrases = timeSettings.phrasesForCurrentPeriod(), !phrases.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                // Story 11.1 Task 2.3: Header view
                TimeBasedPhrasesHeaderView()
                    .environmentObject(accessibilitySettings)
                    .environmentObject(timeSettings)

                // Story 11.1 Task 2.5, AC1: Phrase buttons in grid
                LazyVGrid(columns: gridColumns, spacing: 10) {
                    ForEach(phrases, id: \.self) { phrase in
                        phraseButton(for: phrase)
                    }
                }
            }
            // Code Review Fix M3: Announce to VoiceOver when section becomes visible
            .onAppear {
                if !wasVisible {
                    wasVisible = true
                    announceForVoiceOver("Suggestions du moment disponibles pour \(timeSettings.currentTimePeriod.displayName)")
                }
            }
            .onDisappear {
                wasVisible = false
            }
        }
    }

    // Code Review Fix M3: VoiceOver announcement helper
    private func announceForVoiceOver(_ message: String) {
        // Only announce if VoiceOver is running
        if UIAccessibility.isVoiceOverRunning {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                UIAccessibility.post(notification: .announcement, argument: message)
            }
        }
    }

    // MARK: - Story 11.1 Task 3: Phrase Button with Action

    @ViewBuilder
    private func phraseButton(for phrase: String) -> some View {
        Button(action: {
            // Story 11.1 Task 3.1, AC6: Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()

            // Story 11.1 Task 3.2, AC6: Speak phrase via TTS
            speechService.speakText(phrase)

            // Story 11.1 Task 3.3, AC6: Add to recent history
            presetManager.addToRecentHistory(phrase)
        }) {
            Text(phrase)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(8)
                .frame(minWidth: 100, minHeight: buttonHeight)
                .background(Color.accentColor.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.accentColor.opacity(0.4), lineWidth: 1)
                )
        }
        // Story 11.1 Task 3.4: VoiceOver accessibility
        .accessibilityLabel(phrase)
        .accessibilityHint("Appuyez pour prononcer cette suggestion")
    }
}

// MARK: - Preview Provider

#Preview("TimeBasedPhrasesSection - Morning") {
    TimeBasedPhrasesSection()
        .environmentObject(TimeBasedPhraseSettings.shared)
        .environmentObject(PresetSentenceManager.shared)
        .environmentObject(SpeechService.shared)
        .environmentObject(AccessibilitySettings())
        .padding()
}

#Preview("TimeBasedPhrasesHeaderView") {
    TimeBasedPhrasesHeaderView()
        .environmentObject(TimeBasedPhraseSettings.shared)
        .environmentObject(AccessibilitySettings())
        .padding()
}
