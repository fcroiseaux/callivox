//
//  PersonalizationSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 4.1: LLM Personalization Settings
//  Settings view for customizing AI suggestion behavior.
//  Created by CalliVox on 2026-01-26.
//

import SwiftUI

/// Settings view for AI personalization (Story 4.1)
///
/// Allows users to:
/// - Select communication tone (formal, neutral, casual) (AC2)
/// - Select response length (short, medium, long) (AC2)
/// - Enter personal context for more relevant suggestions (AC3)
/// - Reset all settings to defaults (AC6)
///
/// Settings are auto-saved on change (AC4).
struct PersonalizationSettingsView: View {

    // MARK: - State Properties

    @State private var config: PersonalizationConfig = .loadFromUserDefaults()
    @State private var showSaveSuccess: Bool = false
    @State private var saveConfirmationTask: Task<Void, Never>?
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        List {
            // MARK: - Tone Section (AC2)
            Section {
                Picker("Ton de communication", selection: $config.tone) {
                    ForEach(CommunicationTone.allCases, id: \.self) { tone in
                        Text(tone.displayName).tag(tone)
                    }
                }
                .accessibilityLabel("Ton de communication")
                .accessibilityHint("Choisissez le style de langage des suggestions")
            } header: {
                Text("Style de communication")
            } footer: {
                Text(toneFooterText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // MARK: - Response Length Section (AC2)
            Section {
                Picker("Longueur des réponses", selection: $config.responseLength) {
                    ForEach(ResponseLength.allCases, id: \.self) { length in
                        Text(length.displayName).tag(length)
                    }
                }
                .accessibilityLabel("Longueur des réponses")
                .accessibilityHint("Choisissez la longueur des suggestions générées")
            } header: {
                Text("Longueur des réponses")
            } footer: {
                Text(lengthFooterText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // MARK: - Personal Context Section (AC3)
            Section {
                TextEditor(text: $config.personalContext)
                    .frame(minHeight: 100)
                    .accessibilityLabel("Contexte personnel")
                    .accessibilityHint("Décrivez votre situation pour des suggestions plus pertinentes")

                // Character count indicator
                HStack {
                    Spacer()
                    Text("\(config.personalContext.count)/\(PersonalizationConfig.maxContextLength)")
                        .font(.caption)
                        .foregroundColor(characterCountColor)
                        .accessibilityLabel("Caractères utilisés: \(config.personalContext.count) sur \(PersonalizationConfig.maxContextLength)")
                }
            } header: {
                Text("Contexte personnel")
            } footer: {
                Text("Décrivez votre situation, vos préférences ou votre style de communication. Ces informations aident l'IA à générer des suggestions plus adaptées.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // MARK: - Actions Section (AC6)
            Section {
                Button(action: resetToDefaults) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Réinitialiser par défaut")
                    }
                    .foregroundColor(.red)
                }
                .disabled(!config.isModified)
                .opacity(config.isModified ? 1.0 : 0.5)
                .accessibilityLabel("Réinitialiser les paramètres")
                .accessibilityHint(config.isModified
                    ? "Efface toutes les personnalisations et revient aux valeurs par défaut"
                    : "Les paramètres sont déjà aux valeurs par défaut")
            }

            // MARK: - Save Status Indicator
            if showSaveSuccess {
                Section {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Enregistré")
                            .foregroundColor(.green)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Paramètres enregistrés")
                }
            }
        }
        .navigationTitle("Personnalisation IA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Fermer") {
                    dismiss()
                }
                .accessibilityLabel("Fermer")
                .accessibilityHint("Ferme les paramètres de personnalisation")
            }
        }
        .onChange(of: config) { _, newConfig in
            // M2 Fix: Handle truncation and save in single onChange to avoid double saves
            var finalConfig = newConfig

            // Enforce character limit on personal context
            if finalConfig.personalContext.count > PersonalizationConfig.maxContextLength {
                finalConfig.personalContext = String(finalConfig.personalContext.prefix(PersonalizationConfig.maxContextLength))
            }

            // If truncation changed the config, update it (will re-trigger this onChange)
            if finalConfig != newConfig {
                config = finalConfig
                return
            }

            // Auto-save on every change (AC4)
            finalConfig.saveToUserDefaults()
            showSaveConfirmation()
        }
    }

    // MARK: - Private Computed Properties

    /// Footer text explaining current tone setting
    private var toneFooterText: String {
        switch config.tone {
        case .formal:
            return "Les suggestions utiliseront un langage soutenu avec vouvoiement."
        case .neutral:
            return "Les suggestions utiliseront un langage courant et naturel."
        case .casual:
            return "Les suggestions utiliseront un langage familier avec tutoiement."
        }
    }

    /// Footer text explaining current length setting
    private var lengthFooterText: String {
        switch config.responseLength {
        case .short:
            return "Suggestions de 1 à 2 phrases."
        case .medium:
            return "Suggestions de 2 à 4 phrases."
        case .long:
            return "Suggestions de 4 phrases ou plus."
        }
    }

    /// Color for character count based on proximity to limit
    private var characterCountColor: Color {
        let ratio = Double(config.personalContext.count) / Double(PersonalizationConfig.maxContextLength)
        if ratio >= 1.0 {
            return .red
        } else if ratio >= 0.9 {
            return .orange
        } else {
            return .secondary
        }
    }

    // MARK: - Private Methods

    /// Shows save confirmation briefly (L1: Cancel previous timer to prevent overlap)
    private func showSaveConfirmation() {
        // Cancel any pending hide task
        saveConfirmationTask?.cancel()

        withAnimation {
            showSaveSuccess = true
        }

        saveConfirmationTask = Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation {
                    showSaveSuccess = false
                }
            }
        }
    }

    /// Resets all settings to default values (AC6)
    private func resetToDefaults() {
        PersonalizationConfig.resetToDefaults()
        withAnimation {
            config = .defaultConfig
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PersonalizationSettingsView()
    }
}
