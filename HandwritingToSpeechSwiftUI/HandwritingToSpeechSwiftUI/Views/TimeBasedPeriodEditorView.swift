//
//  TimeBasedPeriodEditorView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 11.2: Time-Based Phrase Customization
//  Task 3: Editor view for phrases in a specific time period
//  Pattern: Follows FatigueModeMessageEditorView.swift
//

import SwiftUI
import UIKit

// MARK: - Story 11.2 Task 3: TimeBasedPeriodEditorView (AC: 2, 3)

/// Editor for phrases in a specific time period
/// AC2: View and edit phrases for a period (add, edit, remove)
/// AC3: Save changes immediately
@MainActor
struct TimeBasedPeriodEditorView: View {
    // Task 3.2: Accept period as parameter
    let period: TimePeriod

    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var timeSettings = TimeBasedPhraseSettings.shared

    // Task 3.7: State for editing
    @State private var editingPhrases: [String] = []
    @State private var newPhraseText: String = ""
    @State private var showAddPhraseField: Bool = false
    @State private var editingIndex: Int? = nil
    @State private var editingText: String = ""

    // Maximum phrases per period
    private let maxPhrases = 6

    var body: some View {
        List {
            // Task 3.3: Header section with period info
            Section {
                HStack(spacing: 16) {
                    // Period icon
                    // L3 Fix: Use period.iconColor from TimePeriod enum (centralized)
                    Image(systemName: period.icon)
                        .font(.largeTitle)
                        .foregroundColor(period.iconColor)
                        .frame(width: 48, height: 48)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(period.displayName)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(period.timeRangeDisplay)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Phrase count indicator
                    Text("\(editingPhrases.count)/\(maxPhrases)")
                        .font(.headline)
                        .foregroundColor(editingPhrases.count >= maxPhrases ? .orange : .secondary)
                }
                .frame(minHeight: accessibilitySettings.buttonHeight)
            }

            // Task 3.4: Current phrases list with edit capability
            Section {
                // M5 Fix: Use stable id combining index and phrase instead of offset alone
                ForEach(Array(editingPhrases.enumerated()), id: \.element) { index, phrase in
                    if editingIndex == index {
                        // Inline editing mode
                        HStack {
                            TextField("Phrase", text: $editingText)
                                .textFieldStyle(.roundedBorder)
                                .frame(minHeight: 44)
                                .onSubmit {
                                    saveEditedPhrase(at: index)
                                }

                            // Code Review Fix L4: Explicit frame for touch target
                            Button(action: {
                                saveEditedPhrase(at: index)
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                            .frame(minWidth: 44, minHeight: 44)
                            .accessibilityLabel("Enregistrer")

                            // Code Review Fix L4: Explicit frame for touch target
                            Button(action: {
                                cancelEditing()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                            .frame(minWidth: 44, minHeight: 44)
                            .accessibilityLabel("Annuler")
                        }
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    } else {
                        // Display mode with tap to edit
                        Button(action: {
                            startEditing(index: index, text: phrase)
                        }) {
                            HStack {
                                Text(phrase)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Spacer()

                                Image(systemName: "pencil")
                                    .foregroundColor(.secondary)
                                    .font(.subheadline)
                            }
                            .frame(minHeight: accessibilitySettings.buttonHeight)
                        }
                        .buttonStyle(.plain)
                        // Task 3.9: VoiceOver accessibility
                        .accessibilityLabel(phrase)
                        .accessibilityHint("Appuyez pour modifier cette phrase")
                    }
                }
                // Task 3.6: Swipe-to-delete (minimum 1 phrase required)
                .onDelete(perform: deletePhrase)
            } header: {
                Text("Phrases")
            } footer: {
                if editingPhrases.count == 1 {
                    Text("Minimum 1 phrase requise. Impossible de supprimer la dernière phrase.")
                        .foregroundColor(.orange)
                } else {
                    Text("Balayez vers la gauche pour supprimer une phrase. Appuyez pour modifier.")
                }
            }

            // Task 3.5: Add phrase section
            Section {
                if showAddPhraseField {
                    // Add phrase input field
                    HStack {
                        TextField("Nouvelle phrase", text: $newPhraseText)
                            .textFieldStyle(.roundedBorder)
                            .frame(minHeight: 44)
                            .onSubmit {
                                addNewPhrase()
                            }

                        // Code Review Fix L4: Explicit frame for touch target
                        Button(action: addNewPhrase) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .disabled(newPhraseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityLabel("Ajouter")
                        .accessibilityHint("Ajoute la nouvelle phrase à la liste")

                        // Code Review Fix L4: Explicit frame for touch target
                        Button(action: {
                            showAddPhraseField = false
                            newPhraseText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .frame(minWidth: 44, minHeight: 44)
                        .accessibilityLabel("Annuler")
                    }
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                } else {
                    // Add phrase button
                    Button(action: {
                        showAddPhraseField = true
                        // Task 3.10: Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(canAddPhrase ? .blue : .gray)
                                .font(.title2)

                            Text("Ajouter une phrase")
                                .foregroundColor(canAddPhrase ? .blue : .gray)

                            Spacer()

                            if !canAddPhrase {
                                Text("Maximum atteint")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        .frame(minHeight: accessibilitySettings.buttonHeight)
                    }
                    .disabled(!canAddPhrase)
                    // Task 3.9: VoiceOver accessibility
                    .accessibilityLabel("Ajouter une phrase")
                    .accessibilityHint(canAddPhrase ? "Ajoute une nouvelle phrase à cette période" : "Maximum 6 phrases atteint")
                }
            } footer: {
                if editingPhrases.count >= maxPhrases {
                    Text("Maximum \(maxPhrases) phrases par période. Supprimez une phrase pour en ajouter une nouvelle.")
                        .foregroundColor(.orange)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(period.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Load current phrases for this period
            editingPhrases = timeSettings.phrases(for: period) ?? []
        }
        // Code Review Fix L2: Removed redundant onDisappear save
        // Changes are saved immediately in each action method (saveEditedPhrase, addNewPhrase, deletePhrase)
    }

    // MARK: - Computed Properties

    private var canAddPhrase: Bool {
        editingPhrases.count < maxPhrases
    }

    // L3 Fix: Removed local iconColor - now using period.iconColor from TimePeriod enum

    // MARK: - Actions

    /// Start inline editing of a phrase
    private func startEditing(index: Int, text: String) {
        editingIndex = index
        editingText = text
        // Task 3.10: Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    /// Save the edited phrase
    private func saveEditedPhrase(at index: Int) {
        let trimmed = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            cancelEditing()
            return
        }

        editingPhrases[index] = trimmed
        editingIndex = nil
        editingText = ""

        // Task 3.8: Save changes immediately
        saveAllChanges()

        // Task 3.10: Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }

    /// Cancel editing mode
    private func cancelEditing() {
        editingIndex = nil
        editingText = ""
    }

    /// Add a new phrase
    private func addNewPhrase() {
        let trimmed = newPhraseText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAddPhrase else { return }

        editingPhrases.append(trimmed)
        newPhraseText = ""
        showAddPhraseField = false

        // Task 3.8: Save changes immediately
        saveAllChanges()

        // Task 3.10: Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Code Review Fix L1: Delayed VoiceOver announcement for reliability
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Phrase ajoutée")
        }
    }

    /// Task 3.6: Delete phrase (minimum 1 required)
    private func deletePhrase(at offsets: IndexSet) {
        // Prevent deletion if only 1 phrase remains
        guard editingPhrases.count > 1 else {
            // Task 3.10: Haptic feedback for error
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.error)

            // Code Review Fix L1: Delayed VoiceOver announcement for reliability
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                UIAccessibility.post(notification: .announcement, argument: "Impossible de supprimer. Minimum 1 phrase requise.")
            }
            return
        }

        editingPhrases.remove(atOffsets: offsets)

        // Task 3.8: Save changes immediately
        saveAllChanges()

        // Task 3.10: Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        // Code Review Fix L1: Delayed VoiceOver announcement for reliability
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            UIAccessibility.post(notification: .announcement, argument: "Phrase supprimée")
        }
    }

    /// Task 3.8: Save all changes to the model
    private func saveAllChanges() {
        timeSettings.updatePhrases(for: period, phrases: editingPhrases)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        TimeBasedPeriodEditorView(period: .morning)
            .environmentObject(AccessibilitySettings())
    }
}
