import Foundation

class PresetSentenceManager: ObservableObject {
    static let shared = PresetSentenceManager()
    
    // Clés pour la persistance dans UserDefaults
    private let presetSentencesKey = "presetSentencesKey"
    private let selectedPresetsKey = "selectedPresetsKey"
    
    // Liste de phrases prédéfinies
    @Published var presetSentences: [String] = []
    
    // Tableau ordonné des phrases sélectionnées
    @Published var selectedPresets: [String] = []
    
    // Nouvelle phrase à ajouter (dans la fenêtre modale)
    @Published var newPresetSentence: String = ""
    
    init() {
        loadPresetSentences()
        loadSelectedPresets()
    }
    
    private func loadPresetSentences() {
        let defaultList = [
            "Oui.",
            "Non.",
            "Bonjour",
            "Au revoir.",
            "Merci",
            "Je ne sais pas.",
            "Pouvez-vous répéter ?",
            "Je ne comprends pas.",
            "Excusez-moi.",
            "Je suis désolé, je ne peux pas répondre."
        ]
        
        if let data = UserDefaults.standard.data(forKey: presetSentencesKey),
           let saved = try? JSONDecoder().decode([String].self, from: data) {
            presetSentences = saved
        } else {
            presetSentences = defaultList
        }
    }
    
    func savePresetSentences() {
        if let data = try? JSONEncoder().encode(presetSentences) {
            UserDefaults.standard.set(data, forKey: presetSentencesKey)
        }
    }
    
    func deletePresetSentences(at offsets: IndexSet) {
        let removed = offsets.map { presetSentences[$0] }
        presetSentences.remove(atOffsets: offsets)
        // On retire également les phrases supprimées de la sélection ordonnée
        for sentence in removed {
            selectedPresets.removeAll { $0 == sentence }
        }
        savePresetSentences()
        saveSelectedPresets()
    }
    
    func addPresetSentence(_ sentence: String) {
        if !sentence.isEmpty {
            presetSentences.append(sentence)
            savePresetSentences()
        }
    }
    
    func loadSelectedPresets() {
        if let savedArray = UserDefaults.standard.array(forKey: selectedPresetsKey) as? [String] {
            selectedPresets = savedArray
        }
    }
    
    func saveSelectedPresets() {
        // Enregistre le tableau ordonné des phrases sélectionnées
        UserDefaults.standard.set(selectedPresets, forKey: selectedPresetsKey)
    }
    
    func togglePresetSelection(for sentence: String) -> Bool {
        if selectedPresets.contains(sentence) {
            selectedPresets.removeAll { $0 == sentence }
            saveSelectedPresets()
            return false
        } else {
            selectedPresets.append(sentence)
            saveSelectedPresets()
            return true
        }
    }
}