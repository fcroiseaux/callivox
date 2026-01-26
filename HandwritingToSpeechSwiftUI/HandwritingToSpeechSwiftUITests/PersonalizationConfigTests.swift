//
//  PersonalizationConfigTests.swift
//  HandwritingToSpeechSwiftUITests
//
//  Story 4.1: LLM Personalization Settings
//  Unit tests for PersonalizationConfig model, enums, and UserDefaults persistence.
//  Created by CalliVox on 2026-01-26.
//

import XCTest
@testable import HandwritingToSpeechSwiftUI

final class PersonalizationConfigTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()
        // Reset to clean state before each test
        PersonalizationConfig.resetToDefaults()
    }

    override func tearDown() {
        // Clean up after each test
        PersonalizationConfig.resetToDefaults()
        super.tearDown()
    }

    // MARK: - CommunicationTone Tests

    func testCommunicationToneDisplayNames() {
        XCTAssertEqual(CommunicationTone.formal.displayName, "Formel")
        XCTAssertEqual(CommunicationTone.neutral.displayName, "Neutre")
        XCTAssertEqual(CommunicationTone.casual.displayName, "Décontracté")
    }

    func testCommunicationTonePromptInstructions() {
        XCTAssertEqual(
            CommunicationTone.formal.promptInstruction,
            "Utilisez un langage soutenu et le vouvoiement."
        )
        XCTAssertEqual(
            CommunicationTone.neutral.promptInstruction,
            "Utilisez un langage courant et naturel."
        )
        XCTAssertEqual(
            CommunicationTone.casual.promptInstruction,
            "Utilisez un langage familier et le tutoiement."
        )
    }

    func testCommunicationToneAllCases() {
        let allCases = CommunicationTone.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.formal))
        XCTAssertTrue(allCases.contains(.neutral))
        XCTAssertTrue(allCases.contains(.casual))
    }

    func testCommunicationToneRawValues() {
        XCTAssertEqual(CommunicationTone.formal.rawValue, "formal")
        XCTAssertEqual(CommunicationTone.neutral.rawValue, "neutral")
        XCTAssertEqual(CommunicationTone.casual.rawValue, "casual")
    }

    func testCommunicationToneCodable() throws {
        let original = CommunicationTone.formal
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CommunicationTone.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - ResponseLength Tests

    func testResponseLengthDisplayNames() {
        XCTAssertEqual(ResponseLength.short.displayName, "Court")
        XCTAssertEqual(ResponseLength.medium.displayName, "Moyen")
        XCTAssertEqual(ResponseLength.long.displayName, "Long")
    }

    func testResponseLengthPromptInstructions() {
        XCTAssertEqual(
            ResponseLength.short.promptInstruction,
            "Génère des réponses courtes de 1 à 2 phrases maximum."
        )
        XCTAssertEqual(
            ResponseLength.medium.promptInstruction,
            "Génère des réponses de longueur moyenne de 2 à 4 phrases."
        )
        XCTAssertEqual(
            ResponseLength.long.promptInstruction,
            "Génère des réponses détaillées de 4 phrases ou plus."
        )
    }

    func testResponseLengthAllCases() {
        let allCases = ResponseLength.allCases
        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.short))
        XCTAssertTrue(allCases.contains(.medium))
        XCTAssertTrue(allCases.contains(.long))
    }

    func testResponseLengthRawValues() {
        XCTAssertEqual(ResponseLength.short.rawValue, "short")
        XCTAssertEqual(ResponseLength.medium.rawValue, "medium")
        XCTAssertEqual(ResponseLength.long.rawValue, "long")
    }

    func testResponseLengthCodable() throws {
        let original = ResponseLength.long
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ResponseLength.self, from: encoded)
        XCTAssertEqual(original, decoded)
    }

    // MARK: - PersonalizationConfig Default Values Tests

    func testDefaultConfigValues() {
        let config = PersonalizationConfig.defaultConfig
        XCTAssertEqual(config.tone, .neutral)
        XCTAssertEqual(config.responseLength, .medium)
        XCTAssertEqual(config.personalContext, "")
    }

    func testMaxContextLengthConstant() {
        XCTAssertEqual(PersonalizationConfig.maxContextLength, 500)
    }

    // MARK: - PersonalizationConfig UserDefaults Persistence Tests (AC4)

    func testSaveAndLoadFromUserDefaults() {
        // Create custom config
        var config = PersonalizationConfig(
            tone: .formal,
            responseLength: .long,
            personalContext: "Je suis développeur Swift."
        )

        // Save to UserDefaults
        config.saveToUserDefaults()

        // Load from UserDefaults
        let loadedConfig = PersonalizationConfig.loadFromUserDefaults()

        XCTAssertEqual(loadedConfig.tone, .formal)
        XCTAssertEqual(loadedConfig.responseLength, .long)
        XCTAssertEqual(loadedConfig.personalContext, "Je suis développeur Swift.")
    }

    func testLoadReturnsDefaultWhenNoSavedConfig() {
        // Ensure no config exists
        PersonalizationConfig.resetToDefaults()

        let config = PersonalizationConfig.loadFromUserDefaults()

        XCTAssertEqual(config.tone, .neutral)
        XCTAssertEqual(config.responseLength, .medium)
        XCTAssertEqual(config.personalContext, "")
    }

    func testResetToDefaults() {
        // Save a custom config
        var config = PersonalizationConfig(
            tone: .casual,
            responseLength: .short,
            personalContext: "Test context"
        )
        config.saveToUserDefaults()

        // Reset to defaults
        PersonalizationConfig.resetToDefaults()

        // Load should return default values
        let loadedConfig = PersonalizationConfig.loadFromUserDefaults()
        XCTAssertEqual(loadedConfig.tone, .neutral)
        XCTAssertEqual(loadedConfig.responseLength, .medium)
        XCTAssertEqual(loadedConfig.personalContext, "")
    }

    // MARK: - PersonalizationConfig isModified Tests (AC6)

    func testIsModifiedReturnsFalseForDefaultConfig() {
        let config = PersonalizationConfig.defaultConfig
        XCTAssertFalse(config.isModified)
    }

    func testIsModifiedReturnsTrueWhenToneChanged() {
        var config = PersonalizationConfig.defaultConfig
        config.tone = .formal
        XCTAssertTrue(config.isModified)
    }

    func testIsModifiedReturnsTrueWhenResponseLengthChanged() {
        var config = PersonalizationConfig.defaultConfig
        config.responseLength = .short
        XCTAssertTrue(config.isModified)
    }

    func testIsModifiedReturnsTrueWhenPersonalContextChanged() {
        var config = PersonalizationConfig.defaultConfig
        config.personalContext = "Some context"
        XCTAssertTrue(config.isModified)
    }

    func testIsModifiedReturnsFalseWhenRevertedToDefaults() {
        var config = PersonalizationConfig.defaultConfig
        config.tone = .formal
        config.tone = .neutral  // Revert
        XCTAssertFalse(config.isModified)
    }

    // MARK: - PersonalizationConfig Context Length Truncation Tests

    func testLoadTruncatesOverlongContext() {
        // Create config with overlength context
        let longContext = String(repeating: "a", count: 600)
        var config = PersonalizationConfig(
            tone: .neutral,
            responseLength: .medium,
            personalContext: longContext
        )

        // Manually save with overlength (bypassing normal save)
        if let encoded = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(encoded, forKey: "llm_personalization_config")
        }

        // Load should truncate to maxContextLength
        let loadedConfig = PersonalizationConfig.loadFromUserDefaults()
        XCTAssertEqual(loadedConfig.personalContext.count, PersonalizationConfig.maxContextLength)
    }

    // MARK: - PersonalizationConfig Equatable Tests

    func testEquatableEqual() {
        let config1 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test"
        )
        let config2 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test"
        )
        XCTAssertEqual(config1, config2)
    }

    func testEquatableNotEqualTone() {
        let config1 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test"
        )
        let config2 = PersonalizationConfig(
            tone: .casual,
            responseLength: .short,
            personalContext: "Test"
        )
        XCTAssertNotEqual(config1, config2)
    }

    func testEquatableNotEqualLength() {
        let config1 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test"
        )
        let config2 = PersonalizationConfig(
            tone: .formal,
            responseLength: .long,
            personalContext: "Test"
        )
        XCTAssertNotEqual(config1, config2)
    }

    func testEquatableNotEqualContext() {
        let config1 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test 1"
        )
        let config2 = PersonalizationConfig(
            tone: .formal,
            responseLength: .short,
            personalContext: "Test 2"
        )
        XCTAssertNotEqual(config1, config2)
    }

    // MARK: - PersonalizationConfig Codable Tests

    func testCodableRoundTrip() throws {
        let original = PersonalizationConfig(
            tone: .casual,
            responseLength: .long,
            personalContext: "Je préfère les réponses détaillées."
        )

        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(PersonalizationConfig.self, from: encoded)

        XCTAssertEqual(original, decoded)
    }

    // MARK: - French Content Verification Tests

    func testAllToneDisplayNamesAreFrench() {
        for tone in CommunicationTone.allCases {
            let name = tone.displayName
            // Verify it's not English
            XCTAssertFalse(name == "Formal" || name == "Neutral" || name == "Casual",
                          "Tone \(tone) display name should be in French, not English")
        }
    }

    func testAllLengthDisplayNamesAreFrench() {
        for length in ResponseLength.allCases {
            let name = length.displayName
            // Verify it's not English
            XCTAssertFalse(name == "Short" || name == "Medium" || name == "Long",
                          "Length \(length) display name should be in French, not English")
        }
    }

    func testAllPromptInstructionsAreFrench() {
        for tone in CommunicationTone.allCases {
            let instruction = tone.promptInstruction
            // Verify French content
            XCTAssertTrue(
                instruction.contains("Utilisez") || instruction.contains("langage"),
                "Tone \(tone) prompt instruction should be in French"
            )
        }

        for length in ResponseLength.allCases {
            let instruction = length.promptInstruction
            // Verify French content
            XCTAssertTrue(
                instruction.contains("Génère") || instruction.contains("réponses") || instruction.contains("phrases"),
                "Length \(length) prompt instruction should be in French"
            )
        }
    }
}
