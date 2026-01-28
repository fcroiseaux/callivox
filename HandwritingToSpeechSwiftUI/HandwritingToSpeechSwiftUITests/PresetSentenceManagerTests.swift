//
//  PresetSentenceManagerTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 8.1: Categorize Quick Phrases by Theme
//  Unit tests for PresetSentenceManager categorization functionality
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class PresetSentenceManagerTests: XCTestCase {

    // Keys used by PresetSentenceManager (copied for testing)
    private let categorizedPhrasesKey = "categorizedPhrasesKey"
    private let selectedCategorizedPresetsKey = "selectedCategorizedPresetsKey"
    private let migrationCompletedKey = "phraseCategoryMigrationCompleted"
    private let legacyPresetSentencesKey = "presetSentencesKey"
    private let legacySelectedPresetsKey = "selectedPresetsKey"
    // Story 8.2: Recent phrases key
    private let recentPhrasesKey = "recentPhrasesHistoryKey"

    // MARK: - Setup / Teardown

    override func setUp() async throws {
        // Clear all relevant UserDefaults keys before each test
        UserDefaults.standard.removeObject(forKey: categorizedPhrasesKey)
        UserDefaults.standard.removeObject(forKey: selectedCategorizedPresetsKey)
        UserDefaults.standard.removeObject(forKey: migrationCompletedKey)
        UserDefaults.standard.removeObject(forKey: legacyPresetSentencesKey)
        UserDefaults.standard.removeObject(forKey: legacySelectedPresetsKey)
        UserDefaults.standard.removeObject(forKey: recentPhrasesKey)  // Story 8.2
    }

    override func tearDown() async throws {
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: categorizedPhrasesKey)
        UserDefaults.standard.removeObject(forKey: selectedCategorizedPresetsKey)
        UserDefaults.standard.removeObject(forKey: migrationCompletedKey)
        UserDefaults.standard.removeObject(forKey: legacyPresetSentencesKey)
        UserDefaults.standard.removeObject(forKey: legacySelectedPresetsKey)
        UserDefaults.standard.removeObject(forKey: recentPhrasesKey)  // Story 8.2
    }

    // MARK: - Story 8.1 Task 2.1: Default Phrases Tests

    func testDefaultPhrasesAreLoaded() {
        let manager = PresetSentenceManager()
        XCTAssertFalse(manager.categorizedPhrases.isEmpty, "Should have default phrases")
        XCTAssertGreaterThanOrEqual(manager.categorizedPhrases.count, 10, "Should have at least 10 default phrases")
    }

    func testDefaultPhrasesHaveCategories() {
        let manager = PresetSentenceManager()

        // Verify social phrases are categorized correctly
        let socialPhrases = manager.categorizedPhrases.filter { $0.category == .social }
        XCTAssertFalse(socialPhrases.isEmpty, "Should have some social phrases")

        // Check specific phrases
        let bonjourPhrase = manager.categorizedPhrases.first { $0.text == "Bonjour" }
        XCTAssertNotNil(bonjourPhrase)
        XCTAssertEqual(bonjourPhrase?.category, .social, "Bonjour should be categorized as social")

        let merciPhrase = manager.categorizedPhrases.first { $0.text == "Merci" }
        XCTAssertNotNil(merciPhrase)
        XCTAssertEqual(merciPhrase?.category, .social, "Merci should be categorized as social")
    }

    // MARK: - Story 8.1 Task 2.2: Migration Tests

    func testMigrationFromLegacyFormat() {
        // Simulate legacy data
        let legacyPhrases = ["Oui.", "Non.", "Bonjour", "J'ai mal"]
        let legacyData = try! JSONEncoder().encode(legacyPhrases)
        UserDefaults.standard.set(legacyData, forKey: legacyPresetSentencesKey)

        // Create manager - should trigger migration
        let manager = PresetSentenceManager()

        // Verify migration occurred
        XCTAssertEqual(manager.categorizedPhrases.count, legacyPhrases.count, "Should have migrated all phrases")

        // Verify phrases are present
        let texts = manager.categorizedPhrases.map { $0.text }
        for legacyPhrase in legacyPhrases {
            XCTAssertTrue(texts.contains(legacyPhrase), "Should contain migrated phrase: \(legacyPhrase)")
        }

        // Verify migration flag is set
        XCTAssertTrue(UserDefaults.standard.bool(forKey: migrationCompletedKey), "Migration flag should be set")
    }

    func testMigrationInfersCategoriesCorrectly() {
        // Simulate legacy data with categorizable phrases
        let legacyPhrases = ["Bonjour", "J'ai mal", "J'ai faim", "Oui"]
        let legacyData = try! JSONEncoder().encode(legacyPhrases)
        UserDefaults.standard.set(legacyData, forKey: legacyPresetSentencesKey)

        let manager = PresetSentenceManager()

        // Check category inference
        let bonjourPhrase = manager.categorizedPhrases.first { $0.text == "Bonjour" }
        XCTAssertEqual(bonjourPhrase?.category, .social, "Bonjour should be inferred as social")

        let malPhrase = manager.categorizedPhrases.first { $0.text == "J'ai mal" }
        XCTAssertEqual(malPhrase?.category, .sante, "J'ai mal should be inferred as sante")

        let faimPhrase = manager.categorizedPhrases.first { $0.text == "J'ai faim" }
        XCTAssertEqual(faimPhrase?.category, .besoins, "J'ai faim should be inferred as besoins")

        let ouiPhrase = manager.categorizedPhrases.first { $0.text == "Oui" }
        XCTAssertEqual(ouiPhrase?.category, .autre, "Oui should default to autre")
    }

    // MARK: - Story 8.1 Task 2.3: Persistence Tests

    func testCategorizedPhrasesPersistence() {
        let manager = PresetSentenceManager()

        // Add a new phrase with category
        manager.addPresetSentence("Test phrase", category: .besoins)
        manager.saveCategorizedPhrases()

        // Create new manager instance - should load persisted data
        let manager2 = PresetSentenceManager()

        let testPhrase = manager2.categorizedPhrases.first { $0.text == "Test phrase" }
        XCTAssertNotNil(testPhrase, "Should persist new phrase")
        XCTAssertEqual(testPhrase?.category, .besoins, "Should persist category")
    }

    // MARK: - Story 8.1 Task 2.4: Helper Methods Tests

    func testPhrasesByCategory() {
        let manager = PresetSentenceManager()

        // Select some phrases
        let socialPhrase = manager.categorizedPhrases.first { $0.category == .social }
        let autrePhrase = manager.categorizedPhrases.first { $0.category == .autre }

        if let socialPhrase = socialPhrase {
            manager.togglePresetSelection(for: socialPhrase)
        }
        if let autrePhrase = autrePhrase {
            manager.togglePresetSelection(for: autrePhrase)
        }

        let grouped = manager.phrasesByCategory()

        // Should have grouped by category
        if socialPhrase != nil {
            XCTAssertNotNil(grouped[.social], "Should have social group")
        }
        if autrePhrase != nil {
            XCTAssertNotNil(grouped[.autre], "Should have autre group")
        }
    }

    func testCategoriesWithPhrases() {
        let manager = PresetSentenceManager()

        // Select phrases from specific categories
        if let socialPhrase = manager.categorizedPhrases.first(where: { $0.category == .social }) {
            manager.togglePresetSelection(for: socialPhrase)
        }
        if let autrePhrase = manager.categorizedPhrases.first(where: { $0.category == .autre }) {
            manager.togglePresetSelection(for: autrePhrase)
        }

        let categories = manager.categoriesWithPhrases()

        // Should return categories that have selected phrases
        XCTAssertFalse(categories.isEmpty, "Should return categories with phrases")

        // Should be sorted by sortOrder
        for i in 0..<categories.count - 1 {
            XCTAssertLessThan(categories[i].sortOrder, categories[i + 1].sortOrder, "Should be sorted by sortOrder")
        }
    }

    // MARK: - Story 8.1 Task 2.5: Add/Delete Tests

    func testAddPhraseWithCategory() {
        let manager = PresetSentenceManager()
        let initialCount = manager.categorizedPhrases.count

        manager.addPresetSentence("New health phrase", category: .sante)

        XCTAssertEqual(manager.categorizedPhrases.count, initialCount + 1)

        let newPhrase = manager.categorizedPhrases.last
        XCTAssertEqual(newPhrase?.text, "New health phrase")
        XCTAssertEqual(newPhrase?.category, .sante)
    }

    func testAddPhraseDefaultsToAutre() {
        let manager = PresetSentenceManager()

        manager.addPresetSentence("Generic phrase")

        let newPhrase = manager.categorizedPhrases.last
        XCTAssertEqual(newPhrase?.category, .autre, "Should default to .autre category")
    }

    func testDeleteCategorizedPhrase() {
        let manager = PresetSentenceManager()
        let phraseToDelete = manager.categorizedPhrases.first!

        manager.deleteCategorizedPhrase(phraseToDelete)

        XCTAssertFalse(manager.categorizedPhrases.contains { $0.id == phraseToDelete.id },
                       "Phrase should be removed")
    }

    func testDeleteRemovesFromSelectedPresets() {
        let manager = PresetSentenceManager()
        let phraseToDelete = manager.categorizedPhrases.first!

        // First select the phrase
        manager.togglePresetSelection(for: phraseToDelete)
        XCTAssertTrue(manager.selectedCategorizedPresets.contains { $0.id == phraseToDelete.id })

        // Delete the phrase
        manager.deleteCategorizedPhrase(phraseToDelete)

        // Should be removed from selected presets too
        XCTAssertFalse(manager.selectedCategorizedPresets.contains { $0.id == phraseToDelete.id },
                       "Should be removed from selected presets")
    }

    // MARK: - Story 8.1 Task 2.6: Selection Tests

    func testTogglePresetSelection() {
        let manager = PresetSentenceManager()
        let phrase = manager.categorizedPhrases.first!

        // Initially not selected
        XCTAssertFalse(manager.isSelected(phrase))

        // Toggle on
        let result1 = manager.togglePresetSelection(for: phrase)
        XCTAssertTrue(result1, "Should return true when selecting")
        XCTAssertTrue(manager.isSelected(phrase))

        // Toggle off
        let result2 = manager.togglePresetSelection(for: phrase)
        XCTAssertFalse(result2, "Should return false when deselecting")
        XCTAssertFalse(manager.isSelected(phrase))
    }

    func testSelectedCategorizedPresetsPersistence() {
        let manager = PresetSentenceManager()
        let phrase = manager.categorizedPhrases.first!

        manager.togglePresetSelection(for: phrase)
        manager.saveSelectedCategorizedPresets()

        // Create new manager - should load persisted selection
        let manager2 = PresetSentenceManager()

        let isSelected = manager2.selectedCategorizedPresets.contains { $0.text == phrase.text }
        XCTAssertTrue(isSelected, "Selection should persist")
    }

    // MARK: - Story 8.1 AC3: Category Update Tests

    func testUpdateCategory() {
        let manager = PresetSentenceManager()
        var phrase = manager.categorizedPhrases.first!
        let originalCategory = phrase.category

        // Update to different category
        let newCategory: PhraseCategory = originalCategory == .social ? .besoins : .social
        manager.updateCategory(for: phrase, to: newCategory)

        // Verify update in categorizedPhrases
        let updatedPhrase = manager.categorizedPhrases.first { $0.id == phrase.id }
        XCTAssertEqual(updatedPhrase?.category, newCategory, "Category should be updated")
    }

    func testUpdateCategoryAlsoUpdatesSelectedPresets() {
        let manager = PresetSentenceManager()
        let phrase = manager.categorizedPhrases.first!

        // Select the phrase
        manager.togglePresetSelection(for: phrase)

        // Update category
        let newCategory: PhraseCategory = phrase.category == .social ? .besoins : .social
        manager.updateCategory(for: phrase, to: newCategory)

        // Verify update in selectedCategorizedPresets
        let selectedPhrase = manager.selectedCategorizedPresets.first { $0.id == phrase.id }
        XCTAssertEqual(selectedPhrase?.category, newCategory, "Category should be updated in selected presets")
    }

    // MARK: - Backward Compatibility Tests

    func testLegacyPresetSentencesComputedProperty() {
        let manager = PresetSentenceManager()

        // Legacy computed property should return text strings
        let legacyPresets = manager.presetSentences
        XCTAssertFalse(legacyPresets.isEmpty)
        XCTAssertTrue(legacyPresets.allSatisfy { $0 is String })
    }

    func testLegacySelectedPresetsComputedProperty() {
        let manager = PresetSentenceManager()
        let phrase = manager.categorizedPhrases.first!

        manager.togglePresetSelection(for: phrase)

        // Legacy computed property should return selected text strings
        let legacySelected = manager.selectedPresets
        XCTAssertTrue(legacySelected.contains(phrase.text))
    }

    // MARK: - Story 8.2: Recent Phrases History Tests

    func testAddToRecentHistory() {
        // Story 8.2 Task 2.3, AC3: Adding phrase to history
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("Test phrase")

        XCTAssertEqual(manager.recentPhrases.count, 1)
        XCTAssertEqual(manager.recentPhrases.first?.text, "Test phrase")
    }

    func testRecentHistoryLimitedTo10() {
        // Story 8.2 AC3: History limited to 10 entries
        let manager = PresetSentenceManager()

        // Add 12 phrases
        for i in 1...12 {
            manager.addToRecentHistory("Phrase \(i)")
        }

        XCTAssertEqual(manager.recentPhrases.count, 10, "Should be limited to 10 entries")
        XCTAssertEqual(manager.recentPhrases.first?.text, "Phrase 12", "Most recent should be first")
        XCTAssertEqual(manager.recentPhrases.last?.text, "Phrase 3", "Oldest should be last")
    }

    func testDisplayedRecentPhrasesLimitedTo5() {
        // Story 8.2 Task 2.4, AC1: Only 5 displayed
        let manager = PresetSentenceManager()

        // Add 8 phrases
        for i in 1...8 {
            manager.addToRecentHistory("Phrase \(i)")
        }

        XCTAssertEqual(manager.displayedRecentPhrases.count, 5, "Should display only 5")
        XCTAssertEqual(manager.recentPhrases.count, 8, "Should store all 8")
    }

    func testDuplicatePhraseMovesToTop() {
        // Story 8.2 AC3: Duplicates moved to top, not duplicated
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("First")
        manager.addToRecentHistory("Second")
        manager.addToRecentHistory("Third")
        manager.addToRecentHistory("First")  // Re-add first

        XCTAssertEqual(manager.recentPhrases.count, 3, "Should not duplicate")
        XCTAssertEqual(manager.recentPhrases.first?.text, "First", "Re-added phrase should be at top")
        XCTAssertEqual(manager.recentPhrases[1].text, "Third")
        XCTAssertEqual(manager.recentPhrases[2].text, "Second")
    }

    func testRecentHistoryPersistence() {
        // Story 8.2 AC3: Persisted across sessions
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("Persistent phrase")
        manager.saveRecentPhrases()

        // Create new manager - should load persisted data
        let manager2 = PresetSentenceManager()

        XCTAssertEqual(manager2.recentPhrases.count, 1)
        XCTAssertEqual(manager2.recentPhrases.first?.text, "Persistent phrase")
    }

    func testClearRecentHistory() {
        // Story 8.2 Task 2.6, AC5: Clear history
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("Test 1")
        manager.addToRecentHistory("Test 2")
        XCTAssertEqual(manager.recentPhrases.count, 2)

        manager.clearRecentHistory()

        XCTAssertEqual(manager.recentPhrases.count, 0, "History should be cleared")
    }

    func testAddEmptyStringToHistory() {
        // Story 8.2: Should not add empty strings
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("")
        manager.addToRecentHistory("   ")  // Whitespace only
        manager.addToRecentHistory("\n\t")  // Newline/tab only

        XCTAssertEqual(manager.recentPhrases.count, 0, "Should not add empty/whitespace strings")
    }

    func testRecentPhrasesOrderIsMostRecentFirst() {
        // Story 8.2 AC1: Most recent at top
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("First")
        manager.addToRecentHistory("Second")
        manager.addToRecentHistory("Third")

        XCTAssertEqual(manager.recentPhrases[0].text, "Third", "Third should be first (most recent)")
        XCTAssertEqual(manager.recentPhrases[1].text, "Second")
        XCTAssertEqual(manager.recentPhrases[2].text, "First", "First should be last (oldest)")
    }

    func testRecentPhraseTrimsWhitespace() {
        // Story 8.2: Should trim whitespace
        let manager = PresetSentenceManager()

        manager.addToRecentHistory("  Test with spaces  ")

        XCTAssertEqual(manager.recentPhrases.first?.text, "Test with spaces")
    }
}
