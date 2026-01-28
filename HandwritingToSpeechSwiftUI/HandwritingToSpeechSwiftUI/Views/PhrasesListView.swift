//
//  PhrasesListView.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 8.1: Updated with category picker and grouped display
//

import SwiftUI

struct PhrasesListView: View {
    @EnvironmentObject var presetManager: PresetSentenceManager
    @Environment(\.dismiss) var dismiss

    // Story 8.1 Task 4.1: Category selection for new phrases
    @State private var selectedCategory: PhraseCategory = .autre

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Story 8.1 Task 4.4: Grouped phrase list by category
                List {
                    ForEach(PhraseCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }, id: \.self) { category in
                        categorySection(for: category)
                    }
                }
                .listStyle(PlainListStyle())
                .accessibilityLabel("Liste des phrases prédéfinies par catégorie")

                // New phrase input area
                newPhraseInputView
            }
            .navigationTitle("Phrases prédéfinies")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        presetManager.saveCategorizedPhrases()
                        presetManager.saveSelectedCategorizedPresets()
                        dismiss()
                    }
                    .accessibilityLabel("Fermer")
                    .accessibilityHint("Ferme la fenêtre de gestion des phrases et enregistre les modifications")
                }
            }
        }
    }

    // MARK: - Story 8.1 Task 4.4: Category Section

    @ViewBuilder
    private func categorySection(for category: PhraseCategory) -> some View {
        let phrasesInCategory = presetManager.categorizedPhrases.filter { $0.category == category }

        if !phrasesInCategory.isEmpty {
            Section {
                ForEach(phrasesInCategory) { phrase in
                    phraseRow(for: phrase)
                }
                .onDelete { offsets in
                    deletePhrases(in: category, at: offsets)
                }
            } header: {
                // Story 8.1 AC2: Category header with icon
                HStack(spacing: 8) {
                    Image(systemName: category.icon)
                        .foregroundColor(.accentColor)
                    Text(category.displayName)
                        .font(.headline)
                }
            }
        }
    }

    // MARK: - Phrase Row

    @ViewBuilder
    private func phraseRow(for phrase: CategorizedPhrase) -> some View {
        HStack {
            // Selection toggle
            Toggle(isOn: Binding<Bool>(
                get: { presetManager.isSelected(phrase) },
                set: { _ in
                    presetManager.togglePresetSelection(for: phrase)
                }
            )) {
                Text(phrase.text)
            }

            Spacer()

            // Story 8.1 Task 4.5: Category change via context menu
            Menu {
                ForEach(PhraseCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }, id: \.self) { newCategory in
                    Button {
                        presetManager.updateCategory(for: phrase, to: newCategory)
                    } label: {
                        HStack {
                            Image(systemName: newCategory.icon)
                            Text(newCategory.displayName)
                            if phrase.category == newCategory {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "folder")
                    .foregroundColor(.secondary)
            }
            .accessibilityLabel("Changer la catégorie")
            .accessibilityHint("Ouvrir le menu pour changer la catégorie de cette phrase")
        }
        .accessibilityHint(presetManager.isSelected(phrase) ?
            "Phrase actuellement sélectionnée. Désactiver pour supprimer des raccourcis." :
            "Phrase non sélectionnée. Activer pour ajouter aux raccourcis.")
        .accessibilityAction(named: "Supprimer cette phrase") {
            presetManager.deleteCategorizedPhrase(phrase)
        }
    }

    // MARK: - Delete Phrases Helper

    private func deletePhrases(in category: PhraseCategory, at offsets: IndexSet) {
        let phrasesInCategory = presetManager.categorizedPhrases.filter { $0.category == category }
        let phrasesToDelete = offsets.map { phrasesInCategory[$0] }

        for phrase in phrasesToDelete {
            presetManager.deleteCategorizedPhrase(phrase)
        }
    }

    // MARK: - Story 8.1 Task 4.2, 4.3: New Phrase Input View

    private var newPhraseInputView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Glissez vers la gauche pour supprimer une phrase")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Story 8.1 Task 4.2: Category picker
            HStack {
                Text("Catégorie:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Picker("Catégorie", selection: $selectedCategory) {
                    ForEach(PhraseCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }, id: \.self) { category in
                        HStack {
                            Image(systemName: category.icon)
                            Text(category.displayName)
                        }
                        .tag(category)
                    }
                }
                .pickerStyle(.menu)
                .accessibilityLabel("Sélectionner une catégorie")
                .accessibilityHint("Choisir la catégorie pour la nouvelle phrase")
            }
            .padding(.horizontal)

            // Text field and add button
            HStack {
                TextField("Nouvelle phrase", text: $presetManager.newPresetSentence)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Champ pour nouvelle phrase")
                    .accessibilityHint("Entrez le texte d'une nouvelle phrase prédéfinie")

                // Story 8.1 Task 4.3: Add button passes category
                Button(action: {
                    if !presetManager.newPresetSentence.isEmpty {
                        presetManager.addPresetSentence(presetManager.newPresetSentence, category: selectedCategory)
                        presetManager.newPresetSentence = ""
                    }
                }) {
                    Text("Ajouter")
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(presetManager.newPresetSentence.isEmpty)
                .accessibilityLabel("Ajouter une nouvelle phrase")
                .accessibilityHint("Ajoute la phrase saisie à la catégorie sélectionnée")
            }
            .padding(.horizontal)
        }
    }
}
