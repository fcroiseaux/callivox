//
//  EmergencyMessagesSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 9.3: Emergency Messages Configuration Screen
//  Allows users to customize the 4 emergency panel messages
//

import SwiftUI
import UIKit

// MARK: - Task 2: Emergency Messages Settings View (AC1, AC2, AC5, AC6)
/// Story 9.3 AC1: Configuration screen showing the 4 emergency messages
@MainActor
struct EmergencyMessagesSettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var messageSettings = EmergencyMessageSettings.shared

    var body: some View {
        List {
            // Task 2.2: Show all 4 emergency messages
            Section {
                ForEach(Array(messageSettings.customMessages.enumerated()), id: \.element.id) { index, message in
                    // Task 2.3: NavigationLink to message editor
                    NavigationLink {
                        EmergencyMessageEditorView(
                            messageSettings: messageSettings,
                            messageIndex: index
                        )
                        .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            // AC3: Emoji remains fixed (non-editable)
                            Text(message.emoji)
                                .font(.title)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.displayText)
                                    .font(.headline)
                                Text(message.spokenText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        // Task 2.5: Apply accessibilitySettings.buttonHeight (60pt/80pt)
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    // Task 2.6: French VoiceOver labels (AC6)
                    .accessibilityLabel(message.displayText)
                    .accessibilityHint("Modifier ce message d'urgence")
                }
            } header: {
                Text("Messages d'urgence")
            } footer: {
                Text("Appuyez sur un message pour le personnaliser. L'icône reste identique.")
            }

            // Task 2.4: Reset to defaults button (AC4)
            Section {
                Button(action: {
                    // Haptic feedback (medium)
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    messageSettings.resetToDefaults()
                }) {
                    HStack {
                        Spacer()
                        Text("Réinitialiser par défaut")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    // Task 2.5: Minimum height based on accessibility mode
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
                // Task 2.6: VoiceOver accessibility (AC6)
                .accessibilityLabel("Réinitialiser par défaut")
                .accessibilityHint("Restaure les 4 messages d'urgence originaux")
                .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Messages d'urgence")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Task 3: Emergency Message Editor View (AC2, AC5, AC6)
/// Story 9.3 AC2: Edit individual emergency message with predefined options or custom text
@MainActor
struct EmergencyMessageEditorView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var messageSettings: EmergencyMessageSettings
    let messageIndex: Int

    // Task 3.3, 3.4: State for editing text fields
    @State private var displayText: String = ""
    @State private var spokenText: String = ""

    // Current message reference
    private var message: CustomEmergencyMessage {
        messageSettings.customMessages[messageIndex]
    }

    // Task 3.5: Predefined options for this message type
    private var predefinedOptions: [PredefinedEmergencyOption] {
        guard messageIndex >= 0 && messageIndex < EmergencyMessageSettings.predefinedOptions.count else {
            return []
        }
        return EmergencyMessageSettings.predefinedOptions[messageIndex]
    }

    var body: some View {
        List {
            // Task 3.2: Preview section with fixed emoji
            Section {
                HStack {
                    // AC3: Emoji is non-editable (icons remain consistent)
                    Text(message.emoji)
                        .font(.system(size: 48))

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(displayText.isEmpty ? message.displayText : displayText)
                            .font(.headline)
                        Text("Icône non modifiable")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // Task 3.7: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
            } header: {
                Text("Aperçu")
            }

            // Task 3.5: Predefined options picker
            Section {
                ForEach(predefinedOptions) { option in
                    Button(action: {
                        // Select predefined option
                        displayText = option.displayText
                        spokenText = option.spokenText
                        // Task 3.6: Save immediately
                        saveChanges()
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.displayText)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(option.spokenText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            // Checkmark for current selection
                            if displayText == option.displayText && spokenText == option.spokenText {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        // Task 3.7: Minimum height
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    .buttonStyle(.plain)
                    // Task 3.8: VoiceOver accessibility (AC6)
                    .accessibilityLabel(option.displayText)
                    .accessibilityHint("Sélectionner cette option prédéfinie")
                    .accessibilityAddTraits(.isButton)
                }
            } header: {
                Text("Options prédéfinies")
            }

            // Task 3.3, 3.4, 4.3: Custom text input (allows "Autre" custom entry)
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Texte du bouton")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Task 3.3: TextField for display text
                    TextField("Ex: À L'AIDE", text: $displayText)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)
                        .onChange(of: displayText) {
                            // Task 3.6: Save immediately on change
                            saveChanges()
                        }
                }
                // Task 3.7: Minimum height
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 3.8: VoiceOver (AC6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Texte du bouton: \(displayText)")

                VStack(alignment: .leading, spacing: 8) {
                    Text("Texte prononcé")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // Task 3.4: TextField for spoken text
                    TextField("Ex: Aidez-moi s'il vous plaît !", text: $spokenText)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)
                        .onChange(of: spokenText) {
                            // Task 3.6: Save immediately on change
                            saveChanges()
                        }
                }
                // Task 3.7: Minimum height
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 3.8: VoiceOver (AC6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Texte prononcé: \(spokenText)")
            } header: {
                Text("Texte personnalisé")
            } footer: {
                Text("Le texte du bouton est affiché sur le panneau d'urgence. Le texte prononcé est lu par la synthèse vocale.")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("\(message.emoji) Message")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize with current values
            displayText = message.displayText
            spokenText = message.spokenText
        }
    }

    // MARK: - Task 3.6: Save Changes Immediately (AC2)
    private func saveChanges() {
        // Only save if both fields have content
        guard !displayText.isEmpty && !spokenText.isEmpty else { return }
        messageSettings.updateMessage(at: messageIndex, displayText: displayText, spokenText: spokenText)
    }
}

// MARK: - Preview Provider
#if DEBUG
struct EmergencyMessagesSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmergencyMessagesSettingsView()
                .environmentObject(AccessibilitySettings())
        }
    }
}
#endif
