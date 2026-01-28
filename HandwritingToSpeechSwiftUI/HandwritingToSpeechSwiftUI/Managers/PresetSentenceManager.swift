//
//  PresetSentenceManager.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 8.1: Modified for categorized phrases support
//

import Foundation
import os.log

// Story 8.1 Task 2: Manager updated to support categorized phrases
// Code Review Fix H1: Added @MainActor for thread safety with @Published properties
@MainActor
class PresetSentenceManager: ObservableObject {

    // Code Review Fix M2: Logger for persistence error tracking
    private static let logger = Logger(subsystem: "com.callivox", category: "PresetSentenceManager")
    static let shared = PresetSentenceManager()

    // MARK: - Story 8.1 Task 2.1: UserDefaults Keys

    // Legacy keys (for migration)
    private let legacyPresetSentencesKey = "presetSentencesKey"
    private let legacySelectedPresetsKey = "selectedPresetsKey"

    // Story 8.1: New keys for categorized storage
    private let categorizedPhrasesKey = "categorizedPhrasesKey"
    private let selectedCategorizedPresetsKey = "selectedCategorizedPresetsKey"
    private let migrationCompletedKey = "phraseCategoryMigrationCompleted"

    // Story 8.2 Task 2.1: UserDefaults key for recent phrases history
    private let recentPhrasesKey = "recentPhrasesHistoryKey"

    // Story 8.2 AC3: History limits
    private let maxRecentPhrases = 10
    private let displayedRecentCount = 5

    // MARK: - Story 8.1 Task 2.1: Published Properties

    /// Story 8.1 AC1, AC3: All phrases with their categories
    @Published var categorizedPhrases: [CategorizedPhrase] = []

    /// Story 8.1 Task 2.6: Selected phrases for display (with categories)
    @Published var selectedCategorizedPresets: [CategorizedPhrase] = []

    /// Nouvelle phrase à ajouter (dans la fenêtre modale)
    @Published var newPresetSentence: String = ""

    // Story 8.2 Task 2.2: Recent phrases history (max 10 stored)
    @Published var recentPhrases: [RecentPhrase] = []

    // MARK: - Computed Properties (Backward Compatibility)

    /// Legacy computed property for backward compatibility
    var presetSentences: [String] {
        categorizedPhrases.map { $0.text }
    }

    /// Legacy computed property for backward compatibility
    var selectedPresets: [String] {
        selectedCategorizedPresets.map { $0.text }
    }

    // MARK: - Initialization

    init() {
        loadCategorizedPhrases()
        loadSelectedCategorizedPresets()
        loadRecentPhrases()  // Story 8.2 Task 2.5
    }

    // MARK: - Story 8.1 Task 2.2: Migration Logic

    private func loadCategorizedPhrases() {
        // Check if migration already completed
        let migrationCompleted = UserDefaults.standard.bool(forKey: migrationCompletedKey)

        if migrationCompleted {
            // Load from new categorized format
            if let data = UserDefaults.standard.data(forKey: categorizedPhrasesKey),
               let saved = try? JSONDecoder().decode([CategorizedPhrase].self, from: data) {
                categorizedPhrases = saved
                return
            }
        }

        // Story 8.1 Task 2.2: Migration from legacy [String] format
        if let data = UserDefaults.standard.data(forKey: legacyPresetSentencesKey),
           let legacySentences = try? JSONDecoder().decode([String].self, from: data) {
            // Convert each string to CategorizedPhrase with appropriate category
            categorizedPhrases = legacySentences.map { text in
                CategorizedPhrase(text: text, category: inferCategory(for: text))
            }
            // Save in new format and mark migration complete
            saveCategorizedPhrases()
            UserDefaults.standard.set(true, forKey: migrationCompletedKey)
            return
        }

        // No existing data - use defaults with categories
        let defaultPhrases: [CategorizedPhrase] = [
            CategorizedPhrase(text: "Oui.", category: .autre),
            CategorizedPhrase(text: "Non.", category: .autre),
            CategorizedPhrase(text: "Bonjour", category: .social),
            CategorizedPhrase(text: "Au revoir.", category: .social),
            CategorizedPhrase(text: "Merci", category: .social),
            CategorizedPhrase(text: "Je ne sais pas.", category: .autre),
            CategorizedPhrase(text: "Pouvez-vous répéter ?", category: .autre),
            CategorizedPhrase(text: "Je ne comprends pas.", category: .autre),
            CategorizedPhrase(text: "Excusez-moi.", category: .social),
            CategorizedPhrase(text: "Je suis désolé, je ne peux pas répondre.", category: .social)
        ]

        categorizedPhrases = defaultPhrases
        saveCategorizedPhrases()
        UserDefaults.standard.set(true, forKey: migrationCompletedKey)
    }

    /// Story 8.1 Task 2.2: Infer category for migrated phrases
    private func inferCategory(for text: String) -> PhraseCategory {
        let lowercased = text.lowercased()

        // Social phrases
        if lowercased.contains("bonjour") || lowercased.contains("au revoir") ||
           lowercased.contains("merci") || lowercased.contains("excusez") ||
           lowercased.contains("désolé") || lowercased.contains("pardon") {
            return .social
        }

        // Health-related phrases
        if lowercased.contains("douleur") || lowercased.contains("mal") ||
           lowercased.contains("médecin") || lowercased.contains("médicament") ||
           lowercased.contains("fatigue") || lowercased.contains("malade") {
            return .sante
        }

        // Needs phrases
        if lowercased.contains("faim") || lowercased.contains("soif") ||
           lowercased.contains("toilette") || lowercased.contains("besoin") ||
           lowercased.contains("aide") || lowercased.contains("appeler") {
            return .besoins
        }

        // Default to autre
        return .autre
    }

    // MARK: - Story 8.1 Task 2.3: Persistence Methods

    // Code Review Fix M2: Added error handling with logging
    func saveCategorizedPhrases() {
        do {
            let data = try JSONEncoder().encode(categorizedPhrases)
            UserDefaults.standard.set(data, forKey: categorizedPhrasesKey)
        } catch {
            Self.logger.error("Failed to encode categorizedPhrases: \(error.localizedDescription)")
        }
    }

    /// Legacy method name for backward compatibility
    func savePresetSentences() {
        saveCategorizedPhrases()
    }

    // MARK: - Story 8.1 Task 2.6: Selected Presets Management

    private func loadSelectedCategorizedPresets() {
        // Try new format first
        if let data = UserDefaults.standard.data(forKey: selectedCategorizedPresetsKey),
           let saved = try? JSONDecoder().decode([CategorizedPhrase].self, from: data) {
            selectedCategorizedPresets = saved
            return
        }

        // Migrate from legacy format
        if let legacySelected = UserDefaults.standard.array(forKey: legacySelectedPresetsKey) as? [String] {
            // Match legacy selected strings to categorized phrases
            selectedCategorizedPresets = legacySelected.compactMap { text in
                categorizedPhrases.first { $0.text == text }
            }
            saveSelectedCategorizedPresets()
        }
    }

    // Code Review Fix M2: Added error handling with logging
    func saveSelectedCategorizedPresets() {
        do {
            let data = try JSONEncoder().encode(selectedCategorizedPresets)
            UserDefaults.standard.set(data, forKey: selectedCategorizedPresetsKey)
        } catch {
            Self.logger.error("Failed to encode selectedCategorizedPresets: \(error.localizedDescription)")
        }
    }

    /// Legacy method name for backward compatibility
    func saveSelectedPresets() {
        saveSelectedCategorizedPresets()
    }

    /// Legacy method name for backward compatibility
    func loadSelectedPresets() {
        loadSelectedCategorizedPresets()
    }

    // MARK: - Story 8.1 Task 2.4: Helper Methods

    /// Story 8.1 AC1, AC2: Group phrases by category for display
    func phrasesByCategory() -> [PhraseCategory: [CategorizedPhrase]] {
        Dictionary(grouping: selectedCategorizedPresets, by: { $0.category })
    }

    /// Story 8.1 AC1: Get sorted categories that have at least one phrase
    func categoriesWithPhrases() -> [PhraseCategory] {
        let grouped = phrasesByCategory()
        return PhraseCategory.allCases
            .filter { grouped[$0]?.isEmpty == false }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    // MARK: - Story 8.1 Task 2.5: Add/Delete Methods

    /// Story 8.1 AC3: Add phrase with category
    // Code Review Fix M3: Added text trimming and whitespace validation
    func addPresetSentence(_ sentence: String, category: PhraseCategory = .autre) {
        let trimmedSentence = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSentence.isEmpty else { return }
        let newPhrase = CategorizedPhrase(text: trimmedSentence, category: category)
        categorizedPhrases.append(newPhrase)
        saveCategorizedPhrases()
    }

    /// Legacy method for backward compatibility
    func addPresetSentence(_ sentence: String) {
        addPresetSentence(sentence, category: .autre)
    }

    /// Delete phrases at given offsets
    func deletePresetSentences(at offsets: IndexSet) {
        let removed = offsets.map { categorizedPhrases[$0] }
        categorizedPhrases.remove(atOffsets: offsets)

        // Remove from selected presets
        for phrase in removed {
            selectedCategorizedPresets.removeAll { $0.id == phrase.id }
        }

        saveCategorizedPhrases()
        saveSelectedCategorizedPresets()
    }

    /// Delete a specific categorized phrase
    func deleteCategorizedPhrase(_ phrase: CategorizedPhrase) {
        categorizedPhrases.removeAll { $0.id == phrase.id }
        selectedCategorizedPresets.removeAll { $0.id == phrase.id }
        saveCategorizedPhrases()
        saveSelectedCategorizedPresets()
    }

    // MARK: - Story 8.1: Selection Toggle Methods

    /// Toggle selection for a categorized phrase
    @discardableResult
    func togglePresetSelection(for phrase: CategorizedPhrase) -> Bool {
        if let index = selectedCategorizedPresets.firstIndex(where: { $0.id == phrase.id }) {
            selectedCategorizedPresets.remove(at: index)
            saveSelectedCategorizedPresets()
            return false
        } else {
            selectedCategorizedPresets.append(phrase)
            saveSelectedCategorizedPresets()
            return true
        }
    }

    /// Legacy toggle by text (for backward compatibility)
    @discardableResult
    func togglePresetSelection(for sentence: String) -> Bool {
        if let phrase = categorizedPhrases.first(where: { $0.text == sentence }) {
            return togglePresetSelection(for: phrase)
        }
        return false
    }

    /// Check if a phrase is selected
    func isSelected(_ phrase: CategorizedPhrase) -> Bool {
        selectedCategorizedPresets.contains { $0.id == phrase.id }
    }

    // MARK: - Story 8.1 AC3: Category Update

    /// Update the category of an existing phrase
    func updateCategory(for phrase: CategorizedPhrase, to newCategory: PhraseCategory) {
        if let index = categorizedPhrases.firstIndex(where: { $0.id == phrase.id }) {
            categorizedPhrases[index].category = newCategory
            saveCategorizedPhrases()
        }
        if let index = selectedCategorizedPresets.firstIndex(where: { $0.id == phrase.id }) {
            selectedCategorizedPresets[index].category = newCategory
            saveSelectedCategorizedPresets()
        }
    }

    // MARK: - Story 8.2: Recent Phrases History

    /// Story 8.2 Task 2.4, AC1: Get 5 most recent phrases for display
    var displayedRecentPhrases: [RecentPhrase] {
        Array(recentPhrases.prefix(displayedRecentCount))
    }

    /// Story 8.2 Task 2.3, AC3: Add phrase to history with duplicate handling
    func addToRecentHistory(_ text: String) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // AC3: Remove existing duplicate (move to top, not duplicated)
        recentPhrases.removeAll { $0.text == trimmedText }

        // Insert new phrase at beginning
        let newPhrase = RecentPhrase(text: trimmedText)
        recentPhrases.insert(newPhrase, at: 0)

        // AC3: Trim to max 10 entries
        if recentPhrases.count > maxRecentPhrases {
            recentPhrases = Array(recentPhrases.prefix(maxRecentPhrases))
        }

        saveRecentPhrases()
    }

    /// Story 8.2 Task 2.5: Load recent phrases from UserDefaults
    /// Code Review Fix M1: Added error logging consistent with save methods
    private func loadRecentPhrases() {
        guard let data = UserDefaults.standard.data(forKey: recentPhrasesKey) else {
            recentPhrases = []
            return
        }
        do {
            recentPhrases = try JSONDecoder().decode([RecentPhrase].self, from: data)
        } catch {
            Self.logger.error("Failed to decode recentPhrases: \(error.localizedDescription)")
            recentPhrases = []
        }
    }

    /// Story 8.2 Task 2.5, AC3: Save recent phrases to UserDefaults
    func saveRecentPhrases() {
        do {
            let data = try JSONEncoder().encode(recentPhrases)
            UserDefaults.standard.set(data, forKey: recentPhrasesKey)
        } catch {
            Self.logger.error("Failed to encode recentPhrases: \(error.localizedDescription)")
        }
    }

    /// Story 8.2 Task 2.6, AC5: Clear all recent history
    func clearRecentHistory() {
        recentPhrases.removeAll()
        saveRecentPhrases()
    }
}
