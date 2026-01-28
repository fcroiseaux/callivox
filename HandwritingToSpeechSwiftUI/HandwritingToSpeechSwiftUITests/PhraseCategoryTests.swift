//
//  PhraseCategoryTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 8.1: Categorize Quick Phrases by Theme
//  Unit tests for PhraseCategory enum and CategorizedPhrase struct
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class PhraseCategoryTests: XCTestCase {

    // MARK: - Story 8.1 Task 1.1: PhraseCategory Enum Tests

    func testPhraseCategoryAllCases() {
        // Story 8.1 AC1: Verify all four categories exist
        let allCases = PhraseCategory.allCases
        XCTAssertEqual(allCases.count, 4, "Should have exactly 4 categories")
        XCTAssertTrue(allCases.contains(.besoins), "Should contain besoins category")
        XCTAssertTrue(allCases.contains(.social), "Should contain social category")
        XCTAssertTrue(allCases.contains(.sante), "Should contain sante category")
        XCTAssertTrue(allCases.contains(.autre), "Should contain autre category")
    }

    func testPhraseCategoryRawValues() {
        // Story 8.1: Verify raw values for serialization
        XCTAssertEqual(PhraseCategory.besoins.rawValue, "besoins")
        XCTAssertEqual(PhraseCategory.social.rawValue, "social")
        XCTAssertEqual(PhraseCategory.sante.rawValue, "sante")
        XCTAssertEqual(PhraseCategory.autre.rawValue, "autre")
    }

    // MARK: - Story 8.1 Task 1.2: Display Names Tests

    func testPhraseCategoryDisplayNames() {
        // Story 8.1 AC1: Verify French display names
        XCTAssertEqual(PhraseCategory.besoins.displayName, "Besoins")
        XCTAssertEqual(PhraseCategory.social.displayName, "Social")
        XCTAssertEqual(PhraseCategory.sante.displayName, "Santé")
        XCTAssertEqual(PhraseCategory.autre.displayName, "Autre")
    }

    func testPhraseCategoryIcons() {
        // Story 8.1 AC2: Verify SF Symbol icons are defined
        XCTAssertFalse(PhraseCategory.besoins.icon.isEmpty, "Besoins should have an icon")
        XCTAssertFalse(PhraseCategory.social.icon.isEmpty, "Social should have an icon")
        XCTAssertFalse(PhraseCategory.sante.icon.isEmpty, "Sante should have an icon")
        XCTAssertFalse(PhraseCategory.autre.icon.isEmpty, "Autre should have an icon")

        // Verify they are valid SF Symbol names (contain common patterns)
        XCTAssertTrue(PhraseCategory.besoins.icon.contains("fill") || PhraseCategory.besoins.icon.contains("."), "Icon should be SF Symbol format")
    }

    // MARK: - Story 8.1 Task 1.2: Sort Order Tests

    func testPhraseCategorySortOrder() {
        // Story 8.1 AC1: Verify sort order (Besoins, Social, Santé, Autre)
        XCTAssertLessThan(PhraseCategory.besoins.sortOrder, PhraseCategory.social.sortOrder)
        XCTAssertLessThan(PhraseCategory.social.sortOrder, PhraseCategory.sante.sortOrder)
        XCTAssertLessThan(PhraseCategory.sante.sortOrder, PhraseCategory.autre.sortOrder)
    }

    func testPhraseCategorySortedArray() {
        // Story 8.1 AC1: Verify sorting produces correct order
        let sorted = PhraseCategory.allCases.sorted { $0.sortOrder < $1.sortOrder }
        XCTAssertEqual(sorted[0], .besoins, "First should be besoins")
        XCTAssertEqual(sorted[1], .social, "Second should be social")
        XCTAssertEqual(sorted[2], .sante, "Third should be sante")
        XCTAssertEqual(sorted[3], .autre, "Fourth should be autre")
    }

    // MARK: - Story 8.1 Task 1.3, 1.4: CategorizedPhrase Tests

    func testCategorizedPhraseInitWithDefaultCategory() {
        // Story 8.1 Task 1.3: Default category should be .autre
        let phrase = CategorizedPhrase(text: "Test phrase")
        XCTAssertEqual(phrase.text, "Test phrase")
        XCTAssertEqual(phrase.category, .autre, "Default category should be .autre")
        XCTAssertNotNil(phrase.id, "Should have a valid UUID")
    }

    func testCategorizedPhraseInitWithSpecificCategory() {
        // Story 8.1 AC3: Can assign specific category
        let phrase = CategorizedPhrase(text: "Bonjour", category: .social)
        XCTAssertEqual(phrase.text, "Bonjour")
        XCTAssertEqual(phrase.category, .social)
    }

    func testCategorizedPhraseIdentifiable() {
        // Story 8.1 Task 1.4: Identifiable conformance
        let phrase1 = CategorizedPhrase(text: "Test 1")
        let phrase2 = CategorizedPhrase(text: "Test 2")
        XCTAssertNotEqual(phrase1.id, phrase2.id, "Different phrases should have different IDs")
    }

    func testCategorizedPhraseHashable() {
        // Story 8.1 Task 1.4: Hashable conformance
        var set = Set<CategorizedPhrase>()
        let phrase1 = CategorizedPhrase(text: "Test 1", category: .social)
        let phrase2 = CategorizedPhrase(text: "Test 2", category: .besoins)

        set.insert(phrase1)
        set.insert(phrase2)

        XCTAssertEqual(set.count, 2, "Should be able to add phrases to a Set")
    }

    // MARK: - Story 8.1 Task 1.4: Codable Tests

    func testCategorizedPhraseCodable() throws {
        // Story 8.1 AC3: Codable for persistence
        let original = CategorizedPhrase(text: "Test phrase", category: .sante)

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CategorizedPhrase.self, from: data)

        XCTAssertEqual(decoded.text, original.text)
        XCTAssertEqual(decoded.category, original.category)
        XCTAssertEqual(decoded.id, original.id, "ID should be preserved through encoding/decoding")
    }

    func testPhraseCategoryCodable() throws {
        // Story 8.1: PhraseCategory should be Codable
        let original = PhraseCategory.besoins

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PhraseCategory.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testCategorizedPhraseArrayCodable() throws {
        // Story 8.1: Array of CategorizedPhrase should be Codable (for storage)
        let original: [CategorizedPhrase] = [
            CategorizedPhrase(text: "Oui", category: .autre),
            CategorizedPhrase(text: "Bonjour", category: .social),
            CategorizedPhrase(text: "J'ai mal", category: .sante)
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([CategorizedPhrase].self, from: data)

        XCTAssertEqual(decoded.count, original.count)
        for (decodedPhrase, originalPhrase) in zip(decoded, original) {
            XCTAssertEqual(decodedPhrase.text, originalPhrase.text)
            XCTAssertEqual(decodedPhrase.category, originalPhrase.category)
            XCTAssertEqual(decodedPhrase.id, originalPhrase.id)
        }
    }

    // MARK: - Story 8.1: Category Mutation Tests

    func testCategorizedPhraseCategoryCanBeMutated() {
        // Story 8.1 AC3: Category can be changed
        var phrase = CategorizedPhrase(text: "Test", category: .autre)
        XCTAssertEqual(phrase.category, .autre)

        phrase.category = .social
        XCTAssertEqual(phrase.category, .social)

        phrase.category = .besoins
        XCTAssertEqual(phrase.category, .besoins)
    }

    func testCategorizedPhraseTextCanBeMutated() {
        var phrase = CategorizedPhrase(text: "Original", category: .autre)
        XCTAssertEqual(phrase.text, "Original")

        phrase.text = "Modified"
        XCTAssertEqual(phrase.text, "Modified")
    }

    // MARK: - Story 8.2 Task 1: RecentPhrase Tests

    func testRecentPhraseInit() {
        // Story 8.2 Task 1.1: Initialize with text and auto-generated timestamp
        let phrase = RecentPhrase(text: "Test recent phrase")
        XCTAssertEqual(phrase.text, "Test recent phrase")
        XCTAssertNotNil(phrase.id, "Should have a valid UUID")
        XCTAssertNotNil(phrase.timestamp, "Should have a timestamp")
    }

    func testRecentPhraseTimestampIsRecent() {
        // Story 8.2 Task 1.1: Timestamp should be close to current time
        let before = Date()
        let phrase = RecentPhrase(text: "Test")
        let after = Date()

        XCTAssertGreaterThanOrEqual(phrase.timestamp, before)
        XCTAssertLessThanOrEqual(phrase.timestamp, after)
    }

    func testRecentPhraseIdentifiable() {
        // Story 8.2 Task 1.2: Identifiable conformance
        let phrase1 = RecentPhrase(text: "Test 1")
        let phrase2 = RecentPhrase(text: "Test 2")
        XCTAssertNotEqual(phrase1.id, phrase2.id, "Different phrases should have different IDs")
    }

    func testRecentPhraseHashable() {
        // Story 8.2 Task 1.2: Hashable conformance
        var set = Set<RecentPhrase>()
        let phrase1 = RecentPhrase(text: "Test 1")
        let phrase2 = RecentPhrase(text: "Test 2")

        set.insert(phrase1)
        set.insert(phrase2)

        XCTAssertEqual(set.count, 2, "Should be able to add phrases to a Set")
    }

    func testRecentPhraseCodable() throws {
        // Story 8.2 Task 1.2: Codable for persistence
        let original = RecentPhrase(text: "Test phrase")

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(RecentPhrase.self, from: data)

        XCTAssertEqual(decoded.text, original.text)
        XCTAssertEqual(decoded.id, original.id, "ID should be preserved through encoding/decoding")
        XCTAssertEqual(decoded.timestamp, original.timestamp, "Timestamp should be preserved")
    }

    func testRecentPhraseArrayCodable() throws {
        // Story 8.2 AC3: Array of RecentPhrase should be Codable (for storage)
        let original: [RecentPhrase] = [
            RecentPhrase(text: "First"),
            RecentPhrase(text: "Second"),
            RecentPhrase(text: "Third")
        ]

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode([RecentPhrase].self, from: data)

        XCTAssertEqual(decoded.count, original.count)
        for (decodedPhrase, originalPhrase) in zip(decoded, original) {
            XCTAssertEqual(decodedPhrase.text, originalPhrase.text)
            XCTAssertEqual(decodedPhrase.id, originalPhrase.id)
            XCTAssertEqual(decodedPhrase.timestamp, originalPhrase.timestamp)
        }
    }

    func testRecentPhraseRelativeTimeString() {
        // Story 8.2 Task 1.3, AC2: Relative time formatting in French
        let phrase = RecentPhrase(text: "Test")
        let relativeTime = phrase.relativeTimeString

        // Should return a non-empty string
        XCTAssertFalse(relativeTime.isEmpty, "Should have a relative time string")

        // Code Review Fix M3: Verify French locale formatting
        // For a just-created phrase, should contain French time indicators
        // RelativeDateTimeFormatter with fr_FR locale produces: "il y a X", "dans X", or "maintenant"
        let frenchIndicators = ["il y a", "dans", "maintenant", "à l'instant", "seconde", "minute", "heure"]
        let containsFrenchFormat = frenchIndicators.contains { relativeTime.lowercased().contains($0) }
        XCTAssertTrue(containsFrenchFormat, "Relative time should be in French format, got: \(relativeTime)")
    }

    func testRecentPhraseCustomInit() {
        // Story 8.2 Task 1.2: Custom init for decoding
        let id = UUID()
        let text = "Custom text"
        let timestamp = Date(timeIntervalSince1970: 1000)

        let phrase = RecentPhrase(id: id, text: text, timestamp: timestamp)

        XCTAssertEqual(phrase.id, id)
        XCTAssertEqual(phrase.text, text)
        XCTAssertEqual(phrase.timestamp, timestamp)
    }
}
