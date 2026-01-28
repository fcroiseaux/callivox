//
//  TimeBasedPhrasesSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.2: Time-Based Phrase Customization
//  Task 2: Settings view for configuring time-based phrases
//  Pattern: Follows FatigueModeSettingsView.swift exactly
//

import SwiftUI
import UIKit

// MARK: - Story 11.2 Task 2: TimeBasedPhrasesSettingsView (AC: 1, 4)

/// Configuration screen for time-based phrase suggestions
/// AC1: Shows 4 time periods with navigation to editors
/// AC4: Toggle to enable/disable the feature
@MainActor
struct TimeBasedPhrasesSettingsView: View {
    // Task 2.2: EnvironmentObject for accessibility settings
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // Task 2.3: ObservedObject for time-based settings
    @ObservedObject var timeSettings = TimeBasedPhraseSettings.shared

    // Task 2.8: State for reset confirmation dialog
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        List {
            // Task 2.4: Toggle section for enabling/disabling feature (AC4)
            Section {
                Toggle(isOn: $timeSettings.isEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Activer les suggestions du moment")
                            .font(.title3)
                            .fontWeight(.medium)

                        Text("Affiche des phrases adaptées à chaque période de la journée")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                // Code Review Fix M2: Updated to iOS 17+ onChange syntax
                .onChange(of: timeSettings.isEnabled) {
                    // Haptic feedback on toggle (.medium)
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                // Task 2.9: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 2.10: French VoiceOver labels
                .accessibilityLabel("Activer les suggestions du moment")
                .accessibilityHint("Active ou désactive les phrases suggérées selon l'heure")
                .accessibilityValue(timeSettings.isEnabled ? "Activé" : "Désactivé")
            } header: {
                Text("Activation")
            } footer: {
                Text("Lorsque cette option est activée, des phrases adaptées à l'heure de la journée apparaissent automatiquement.")
            }

            // Task 2.5, 2.6, 2.7: Period list section (AC1)
            Section {
                // Filter out .none and iterate over active periods
                ForEach(TimePeriod.allCases.filter { $0 != .none }, id: \.self) { period in
                    // Task 2.7: NavigationLink to period editor
                    NavigationLink {
                        TimeBasedPeriodEditorView(period: period)
                            .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            // Task 2.6: Period icon
                            // L3 Fix: Use period.iconColor from TimePeriod enum (centralized)
                            Image(systemName: period.icon)
                                .font(.title2)
                                .foregroundColor(period.iconColor)
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                // Task 2.6: Period display name
                                Text(period.displayName)
                                    .font(.headline)

                                // Task 2.6: Time range and phrase count
                                HStack(spacing: 8) {
                                    Text(period.timeRangeDisplay)
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    // Show phrase count
                                    Text("•")
                                        .foregroundColor(.secondary)

                                    Text("\(timeSettings.phraseCount(for: period)) phrases")
                                        .font(.caption)
                                        .foregroundColor(.secondary)

                                    // Indicator if custom phrases are set
                                    if timeSettings.hasCustomPhrases(for: period) {
                                        Text("(personnalisé)")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }

                            Spacer()
                        }
                        // Task 2.9: Minimum height based on accessibility mode
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    // Task 2.10: French VoiceOver labels
                    .accessibilityLabel("\(period.displayName), \(period.timeRangeDisplay)")
                    .accessibilityHint("Ouvrir la configuration des phrases pour cette période")
                    .accessibilityValue("\(timeSettings.phraseCount(for: period)) phrases\(timeSettings.hasCustomPhrases(for: period) ? ", personnalisé" : "")")
                }
            } header: {
                Text("Périodes de la journée")
            } footer: {
                Text("Tapez sur une période pour personnaliser les phrases suggérées. Chaque période peut contenir de 1 à 6 phrases.")
            }

            // Task 2.8: Reset to defaults button
            Section {
                Button(action: {
                    showResetConfirmation = true
                }) {
                    HStack {
                        Spacer()
                        Text("Réinitialiser par défaut")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    // Task 2.9: Minimum height based on accessibility mode
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
                // Task 2.10: VoiceOver accessibility
                // Code Review Fix L3: Added accessibility value for customization state
                .accessibilityLabel("Réinitialiser par défaut")
                .accessibilityHint("Restaure toutes les phrases à leurs valeurs par défaut")
                .accessibilityValue(customizationStateDescription)
                .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Phrases du moment")
        .navigationBarTitleDisplayMode(.large)
        // Task 2.8: Reset confirmation dialog
        .alert("Réinitialiser les phrases ?", isPresented: $showResetConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Réinitialiser", role: .destructive) {
                // Haptic feedback (medium)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                timeSettings.resetToDefaults()
            }
        } message: {
            Text("Toutes les phrases personnalisées seront remplacées par les phrases par défaut.")
        }
    }

    // MARK: - Helper Methods

    // L3 Fix: Removed local iconColor function - now using period.iconColor from TimePeriod enum

    /// Code Review Fix L3: Description of current customization state for VoiceOver
    private var customizationStateDescription: String {
        let customizedCount = TimePeriod.allCases
            .filter { $0 != .none }
            .filter { timeSettings.hasCustomPhrases(for: $0) }
            .count
        if customizedCount == 0 {
            return "Aucune personnalisation"
        } else if customizedCount == 1 {
            return "1 période personnalisée"
        } else {
            return "\(customizedCount) périodes personnalisées"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        TimeBasedPhrasesSettingsView()
            .environmentObject(AccessibilitySettings())
    }
}
