//
//  GuidanceContextTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 4.2: UI Guidance Controls
//  Unit tests for GuidanceContext enum.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class GuidanceContextTests: XCTestCase {

    // MARK: - GuidanceContext Display Name Tests (AC1)

    func testGuidanceContextDisplayNames() {
        XCTAssertEqual(GuidanceContext.greeting.displayName, "Salutation")
        XCTAssertEqual(GuidanceContext.question.displayName, "Question")
        XCTAssertEqual(GuidanceContext.answer.displayName, "Réponse")
        XCTAssertEqual(GuidanceContext.thanks.displayName, "Remerciement")
        XCTAssertEqual(GuidanceContext.goodbye.displayName, "Au revoir")
    }

    func testAllDisplayNamesAreFrench() {
        // M3 Fix: Check for actual French content rather than absence of English
        // Note: "Question" is the same in both languages, so we verify other French markers
        let expectedFrenchNames = ["Salutation", "Question", "Réponse", "Remerciement", "Au revoir"]
        for context in GuidanceContext.allCases {
            let name = context.displayName
            XCTAssertTrue(
                expectedFrenchNames.contains(name),
                "Context \(context) display name '\(name)' should be one of the expected French names"
            )
        }
    }

    // MARK: - GuidanceContext Icon Tests (AC1)

    func testGuidanceContextIcons() {
        XCTAssertEqual(GuidanceContext.greeting.icon, "hand.wave")
        XCTAssertEqual(GuidanceContext.question.icon, "questionmark.bubble")
        XCTAssertEqual(GuidanceContext.answer.icon, "text.bubble")
        XCTAssertEqual(GuidanceContext.thanks.icon, "heart")
        XCTAssertEqual(GuidanceContext.goodbye.icon, "hand.raised")
    }

    func testAllIconsAreValidSFSymbols() {
        // All icons should be non-empty valid SF Symbol names
        for context in GuidanceContext.allCases {
            let icon = context.icon
            XCTAssertFalse(icon.isEmpty, "Context \(context) should have an icon")
            XCTAssertFalse(icon.contains(" "), "Icon \(icon) should not contain spaces")
        }
    }

    // MARK: - GuidanceContext Prompt Instruction Tests (AC2)

    func testGuidanceContextPromptInstructions() {
        XCTAssertEqual(
            GuidanceContext.greeting.promptInstruction,
            "Génère des salutations appropriées (Bonjour, Salut, Bonsoir, etc.)"
        )
        XCTAssertEqual(
            GuidanceContext.question.promptInstruction,
            "Génère des questions pertinentes au contexte"
        )
        XCTAssertEqual(
            GuidanceContext.answer.promptInstruction,
            "Génère des réponses adaptées à la conversation"
        )
        XCTAssertEqual(
            GuidanceContext.thanks.promptInstruction,
            "Génère des expressions de remerciement (Merci, Je vous remercie, etc.)"
        )
        XCTAssertEqual(
            GuidanceContext.goodbye.promptInstruction,
            "Génère des formules de départ (Au revoir, À bientôt, Bonne journée, etc.)"
        )
    }

    func testAllPromptInstructionsAreFrench() {
        for context in GuidanceContext.allCases {
            let instruction = context.promptInstruction
            // Verify French content
            XCTAssertTrue(
                instruction.contains("Génère") || instruction.contains("génère"),
                "Context \(context) prompt instruction should be in French and start with 'Génère'"
            )
        }
    }

    func testPromptInstructionsAreNonEmpty() {
        for context in GuidanceContext.allCases {
            let instruction = context.promptInstruction
            XCTAssertFalse(instruction.isEmpty, "Context \(context) should have a prompt instruction")
            XCTAssertGreaterThan(instruction.count, 20, "Prompt instruction should be descriptive")
        }
    }

    // MARK: - GuidanceContext CaseIterable Tests

    func testGuidanceContextAllCases() {
        let allCases = GuidanceContext.allCases
        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.greeting))
        XCTAssertTrue(allCases.contains(.question))
        XCTAssertTrue(allCases.contains(.answer))
        XCTAssertTrue(allCases.contains(.thanks))
        XCTAssertTrue(allCases.contains(.goodbye))
    }

    // MARK: - GuidanceContext Raw Value Tests

    func testGuidanceContextRawValues() {
        XCTAssertEqual(GuidanceContext.greeting.rawValue, "greeting")
        XCTAssertEqual(GuidanceContext.question.rawValue, "question")
        XCTAssertEqual(GuidanceContext.answer.rawValue, "answer")
        XCTAssertEqual(GuidanceContext.thanks.rawValue, "thanks")
        XCTAssertEqual(GuidanceContext.goodbye.rawValue, "goodbye")
    }

    func testGuidanceContextInitFromRawValue() {
        XCTAssertEqual(GuidanceContext(rawValue: "greeting"), .greeting)
        XCTAssertEqual(GuidanceContext(rawValue: "question"), .question)
        XCTAssertEqual(GuidanceContext(rawValue: "answer"), .answer)
        XCTAssertEqual(GuidanceContext(rawValue: "thanks"), .thanks)
        XCTAssertEqual(GuidanceContext(rawValue: "goodbye"), .goodbye)
        XCTAssertNil(GuidanceContext(rawValue: "invalid"))
    }

    // MARK: - GuidanceContext Identifiable Tests

    func testGuidanceContextIdentifiable() {
        for context in GuidanceContext.allCases {
            XCTAssertEqual(context.id, context.rawValue, "id should equal rawValue")
        }
    }

    func testAllIdsAreUnique() {
        let ids = GuidanceContext.allCases.map { $0.id }
        let uniqueIds = Set(ids)
        XCTAssertEqual(ids.count, uniqueIds.count, "All context IDs should be unique")
    }
}
