//
//  FatigueModeSettingsView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 10.3: Fatigue Mode Messages Configuration Screen
//  Allows users to customize the 5 fatigue mode messages
//  Pattern: Follows EmergencyMessagesSettingsView.swift exactly
//

import SwiftUI
import UIKit

// MARK: - Task 2: FatigueModeSettingsView (AC1, AC5, AC6)
/// Story 10.3 AC1: Configuration screen showing the 5 fatigue mode messages
@MainActor
struct FatigueModeSettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var messageSettings = FatigueModeSettings.shared

    // AC5: State for reset confirmation dialog
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        List {
            // Task 2.3: Show all 5 editable message slots
            Section {
                ForEach(Array(messageSettings.customMessages.enumerated()), id: \.element.id) { index, message in
                    // Task 2.4: NavigationLink to message editor
                    NavigationLink {
                        FatigueModeMessageEditorView(
                            messageSettings: messageSettings,
                            messageIndex: index
                        )
                        .environmentObject(accessibilitySettings)
                    } label: {
                        HStack(spacing: 12) {
                            // Color indicator circle
                            Circle()
                                .fill(message.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(message.text)
                                    .font(.headline)
                                Text("Bouton \(index + 1)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        // Task 2.5: Apply accessibilitySettings.buttonHeight (60pt/80pt)
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    // Task 2.7: French VoiceOver labels (AC6)
                    .accessibilityLabel(message.text)
                    .accessibilityHint("Modifier ce message du mode fatigue")
                }
            } header: {
                Text("Messages du mode fatigue")
            } footer: {
                Text("Personnalisez les 5 messages essentiels. Le bouton « Mode normal » est toujours présent et ne peut pas être modifié.")
            }

            // Task 2.6: Reset to defaults button (AC5)
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
                    // Task 2.5: Minimum height based on accessibility mode
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
                // Task 2.7: VoiceOver accessibility (AC6)
                .accessibilityLabel("Réinitialiser par défaut")
                .accessibilityHint("Restaure les 5 messages du mode fatigue originaux")
                .accessibilityAddTraits(.isButton)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Mode Fatigue")
        .navigationBarTitleDisplayMode(.large)
        // AC5: Reset confirmation dialog
        .alert("Réinitialiser les messages ?", isPresented: $showResetConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Réinitialiser", role: .destructive) {
                // Haptic feedback (medium)
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                messageSettings.resetToDefaults()
            }
        } message: {
            Text("Les 5 messages seront restaurés à leurs valeurs par défaut : Oui, Non, Appeler, Douleur, Soif/Faim.")
        }
    }
}

// MARK: - Task 3: FatigueModeMessageEditorView (AC2, AC3, AC6)
/// Story 10.3 AC2, AC3: Edit individual fatigue mode message with predefined options or custom text
@MainActor
struct FatigueModeMessageEditorView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var messageSettings: FatigueModeSettings
    let messageIndex: Int

    // Task 3.4: State for editing text field
    @State private var customText: String = ""
    // Task 3.5: State for selected color
    @State private var selectedColorName: String = "green"

    // Current message reference
    private var message: FatigueModeMessage {
        messageSettings.customMessages[messageIndex]
    }

    var body: some View {
        List {
            // Task 3.2: Preview section showing current message with color
            Section {
                HStack {
                    // Color preview circle
                    Circle()
                        .fill(FatigueModeSettings.color(for:selectedColorName))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                        )

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(customText.isEmpty ? message.text : customText)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Aperçu du bouton")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                // Task 3.7: Minimum height based on accessibility mode
                .frame(minHeight: accessibilitySettings.buttonHeight)
            } header: {
                Text("Aperçu")
            }

            // Task 3.3: Predefined options section grouped by category (AC2)
            ForEach(FatigueModeSettings.predefinedCategories) { category in
                Section {
                    ForEach(category.options) { option in
                        Button(action: {
                            // H1 Fix (Code Review): Add haptic feedback for selection
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            // Select predefined option
                            customText = option.text
                            selectedColorName = option.colorName
                            // Task 3.6: Save immediately
                            saveChanges()
                        }) {
                            HStack {
                                // Color indicator
                                Circle()
                                    .fill(FatigueModeSettings.color(for:option.colorName))
                                    .frame(width: 24, height: 24)

                                Text(option.text)
                                    .font(.headline)
                                    .foregroundColor(.primary)

                                Spacer()

                                // Checkmark for current selection
                                if customText == option.text && selectedColorName == option.colorName {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                            // Task 3.7: Minimum height
                            .frame(minHeight: accessibilitySettings.buttonHeight)
                        }
                        .buttonStyle(.plain)
                        // Task 3.8: VoiceOver accessibility (AC6)
                        .accessibilityLabel(option.text)
                        .accessibilityHint("Sélectionner cette option prédéfinie")
                        .accessibilityAddTraits(.isButton)
                    }
                } header: {
                    Label(category.name, systemImage: category.icon)
                }
            }

            // Task 3.4: Custom text input section (AC3)
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Texte personnalisé")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    TextField("Ex: BESOIN", text: $customText)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.characters)
                        .frame(minHeight: 44)
                        // M2 Fix (Code Review): Removed onChange to avoid saving on every keystroke
                        // Text changes are saved via onDisappear when leaving the view
                        .onSubmit {
                            // Save when user presses Return
                            saveChanges()
                        }
                }
                // Task 3.7: Minimum height
                .frame(minHeight: accessibilitySettings.buttonHeight)
                // Task 3.8: VoiceOver (AC6)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Texte personnalisé: \(customText)")
            } header: {
                Text("Texte personnalisé")
            } footer: {
                Text("Entrez un texte personnalisé ou choisissez une option prédéfinie ci-dessus.")
            }

            // Task 3.5: Color picker section (AC3)
            Section {
                ForEach(FatigueModeSettings.availableColors, id: \.name) { colorInfo in
                    Button(action: {
                        // H1 Fix (Code Review): Add haptic feedback for color selection
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        selectedColorName = colorInfo.name
                        // Task 3.6: Save immediately
                        saveChanges()
                    }) {
                        HStack {
                            Circle()
                                .fill(colorInfo.color)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                                )

                            Text(colorInfo.displayName)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedColorName == colorInfo.name {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                        // Task 3.7: Minimum height
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    .buttonStyle(.plain)
                    // Task 3.8: VoiceOver (AC6)
                    .accessibilityLabel(colorInfo.displayName)
                    .accessibilityHint("Sélectionner cette couleur")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityValue(selectedColorName == colorInfo.name ? "Sélectionné" : "")
                }
            } header: {
                Text("Couleur du bouton")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Bouton \(messageIndex + 1)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Initialize with current values
            customText = message.text
            selectedColorName = message.colorName
        }
        // M2 Fix (Code Review): Save on navigation back instead of every keystroke
        .onDisappear {
            saveChanges()
        }
    }

    // MARK: - Task 3.6: Save Changes Immediately (AC3)
    private func saveChanges() {
        // Only save if text has content
        guard !customText.isEmpty else { return }
        messageSettings.updateMessage(at: messageIndex, text: customText, colorName: selectedColorName)
    }
    // M1 Fix (Code Review): Removed duplicate colorForName() - now uses FatigueModeSettings.color(for:)
}

// MARK: - Preview
// L3 Fix (Code Review): Updated to #Preview macro for consistency
#Preview {
    NavigationView {
        FatigueModeSettingsView()
            .environmentObject(AccessibilitySettings())
    }
}
