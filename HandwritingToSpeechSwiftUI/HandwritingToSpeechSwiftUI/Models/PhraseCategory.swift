//
//  PhraseCategory.swift
//  HandwritingToSpeechSwiftUI
//
//  Story 8.1: Categorize Quick Phrases by Theme
//  Task 1: PhraseCategory enum and CategorizedPhrase model
//

import Foundation

// MARK: - Story 8.1 Task 1.1, 1.2: PhraseCategory Enum

/// Represents the category of a quick phrase for organization and display
/// Story 8.1 AC1, AC3: Categories are Besoins, Social, Sante, Autre
enum PhraseCategory: String, CaseIterable, Codable {
    case besoins = "besoins"
    case social = "social"
    case sante = "sante"
    case autre = "autre"

    // Story 8.1 Task 1.2: French display names for UI
    var displayName: String {
        switch self {
        case .besoins: return "Besoins"
        case .social: return "Social"
        case .sante: return "Santé"
        case .autre: return "Autre"
        }
    }

    // Story 8.1 Task 1.2: SF Symbol icons for category headers
    var icon: String {
        switch self {
        case .besoins: return "hand.raised.fill"
        case .social: return "person.2.fill"
        case .sante: return "heart.fill"
        case .autre: return "ellipsis.circle.fill"
        }
    }

    // Story 8.1 AC1: Display order for categories (Besoins, Social, Sante first)
    var sortOrder: Int {
        switch self {
        case .besoins: return 0
        case .social: return 1
        case .sante: return 2
        case .autre: return 3
        }
    }
}

// MARK: - Story 8.1 Task 1.3, 1.4: CategorizedPhrase Struct

/// A phrase with an associated category for organization
/// Story 8.1 AC3: Persisted with the phrase
struct CategorizedPhrase: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var category: PhraseCategory

    // Story 8.1 Task 1.3: Default category is .autre for migration compatibility
    init(text: String, category: PhraseCategory = .autre) {
        self.id = UUID()
        self.text = text
        self.category = category
    }

    // Story 8.1 Task 1.4: Custom init for decoding with ID preservation
    init(id: UUID, text: String, category: PhraseCategory) {
        self.id = id
        self.text = text
        self.category = category
    }
}

// MARK: - Story 8.2 Task 1: RecentPhrase Struct

/// A recently spoken phrase with timestamp for history tracking
/// Story 8.2 AC1, AC2, AC3: Tracks spoken phrases with relative time display
struct RecentPhrase: Identifiable, Codable, Hashable {
    let id: UUID
    let text: String
    let timestamp: Date

    // Code Review Fix L1: Static formatter to avoid recreation on each access
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.unitsStyle = .short
        return formatter
    }()

    // Story 8.2 Task 1.1: Initialize with current timestamp
    init(text: String) {
        self.id = UUID()
        self.text = text
        self.timestamp = Date()
    }

    // Story 8.2 Task 1.2: Custom init for decoding with preserved values
    init(id: UUID, text: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }

    // Story 8.2 Task 1.3, AC2: Relative time string in French ("il y a 5 min")
    // Code Review Fix L1: Uses static formatter for performance
    var relativeTimeString: String {
        Self.relativeFormatter.localizedString(for: timestamp, relativeTo: Date())
    }
}
