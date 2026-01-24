import SwiftUI

struct PhrasesListView: View {
    @EnvironmentObject var presetManager: PresetSentenceManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                List {
                    ForEach(presetManager.presetSentences, id: \.self) { sentence in
                        // Chaque ligne affiche la phrase et un Toggle pour la sélectionner
                        Toggle(isOn: Binding<Bool>(
                            get: { presetManager.selectedPresets.contains(sentence) },
                            set: { isSelected in
                                if isSelected, !presetManager.selectedPresets.contains(sentence) {
                                    presetManager.selectedPresets.append(sentence)
                                } else {
                                    presetManager.selectedPresets.removeAll { $0 == sentence }
                                }
                                presetManager.saveSelectedPresets()
                            }
                        )) {
                            Text(sentence)
                        }
                        .accessibilityHint(presetManager.selectedPresets.contains(sentence) ? 
                            "Phrase actuellement sélectionnée. Désactiver pour supprimer des raccourcis." : 
                            "Phrase non sélectionnée. Activer pour ajouter aux raccourcis.")
                        .accessibilityAction(named: "Supprimer cette phrase") {
                            if let index = presetManager.presetSentences.firstIndex(of: sentence) {
                                presetManager.deletePresetSentences(at: IndexSet(integer: index))
                            }
                        }
                    }
                    .onDelete(perform: presetManager.deletePresetSentences)
                }
                .listStyle(PlainListStyle())
                .accessibilityLabel("Liste des phrases prédéfinies")
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Glissez vers la gauche pour supprimer une phrase")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    HStack {
                        TextField("Nouvelle phrase", text: $presetManager.newPresetSentence)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityLabel("Champ pour nouvelle phrase")
                            .accessibilityHint("Entrez le texte d'une nouvelle phrase prédéfinie")
                        
                        Button(action: {
                            if !presetManager.newPresetSentence.isEmpty {
                                presetManager.addPresetSentence(presetManager.newPresetSentence)
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
                        .accessibilityHint("Ajoute la phrase saisie à la liste des phrases prédéfinies")
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Phrases prédéfinies")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") {
                        presetManager.savePresetSentences()
                        presetManager.saveSelectedPresets()
                        dismiss()
                    }
                    .accessibilityLabel("Fermer")
                    .accessibilityHint("Ferme la fenêtre de gestion des phrases et enregistre les modifications")
                }
            }
        }
    }
}