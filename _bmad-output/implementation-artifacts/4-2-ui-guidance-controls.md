# Story 4.2: UI Guidance Controls

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a CalliVox user,
I want quick controls to guide AI suggestions in real-time,
so that I can get contextually appropriate responses faster.

## Acceptance Criteria

1. **Given** the user is on the main communication screen
   **When** they want to guide the AI
   **Then** quick context buttons are visible (e.g., "Salutation", "Question", "Reponse", "Remerciement")
   **And** the buttons are easily accessible

2. **Given** quick context buttons are displayed
   **When** the user taps a context button (e.g., "Salutation")
   **Then** the AI generates suggestions appropriate for that context
   **And** suggestions like "Bonjour", "Salut", "Bonsoir" appear

3. **Given** suggestions are displayed
   **When** the user taps "More like this" on a suggestion
   **Then** the AI generates variations of that suggestion
   **And** the new suggestions are similar in tone/content

4. **Given** suggestions are displayed
   **When** the user taps "Different" or swipes to refresh
   **Then** the AI generates completely different suggestions
   **And** the previous suggestions are replaced

5. **Given** the user adjusts the response length control
   **When** they select "Short", "Medium", or "Long"
   **Then** subsequent suggestions match the selected length
   **And** the control state is visually indicated

6. **Given** the user is in a specific conversation context
   **When** they use guidance controls
   **Then** the conversation history is still considered
   **And** guidance adds to rather than replaces context

## Tasks / Subtasks

- [x] Task 1: Create GuidanceContext enum and model (AC: 1, 2)
  - [x] Create `Models/GuidanceContext.swift`
  - [x] Define GuidanceContext enum: `greeting`, `question`, `answer`, `thanks`, `goodbye`
  - [x] Add `displayName: String` computed property (French labels)
  - [x] Add `icon: String` computed property (SF Symbols)
  - [x] Add `promptInstruction: String` computed property for LLM guidance

- [x] Task 2: Extend SuggestionService for guided generation (AC: 2, 3, 4, 6)
  - [x] Add `@Published var currentGuidance: GuidanceContext?` property
  - [x] Add `@Published var lastSelectedSuggestion: String?` for "more like this"
  - [x] Create `generateGuidedSuggestions(context: GuidanceContext, prompt: String?)` method
  - [x] Create `generateVariations(of suggestion: String)` method for "more like this"
  - [x] Create `generateDifferentSuggestions()` method to request different suggestions
  - [x] Modify `generateSuggestions()` to include guidance in prompt when set

- [x] Task 3: Modify OpenAICompatibleLLMProvider for guidance (AC: 2, 3, 4)
  - [x] Extend `buildSystemPrompt()` to accept optional guidance context
  - [x] Add guidance-specific instructions to system prompt
  - [x] Add "more like this" instruction format
  - [x] Add "different from previous" instruction format

- [x] Task 4: Create GuidanceControlsView (AC: 1, 5)
  - [x] Create `Views/GuidanceControlsView.swift`
  - [x] Create horizontal scrollable button row for quick context
  - [x] Use capsule/pill button style with icons and labels
  - [x] Add visual selection state for active guidance context
  - [x] Response length control already exists in PersonalizationSettingsView (Story 4.1)
  - [x] Add French labels and accessibility hints
  - [x] Add haptic feedback on button tap

- [x] Task 5: Add "More Like This" and "Different" buttons to SuggestionView (AC: 3, 4)
  - [x] Add "Plus comme ça" (more like this) via context menu on suggestion cards
  - [x] Add "Autre" (different) button in header to refresh with different suggestions
  - [x] Wire buttons to SuggestionService methods
  - [x] Add visual feedback (haptic, opacity on disabled state)

- [x] Task 6: Integrate GuidanceControlsView into ContentView (AC: 1, 6)
  - [x] Add GuidanceControlsView above SuggestionView in main layout
  - [x] Connect guidance context changes to SuggestionService
  - [x] Conversation history is preserved (SuggestionService reuses existing history)
  - [x] Add proper spacing and visual hierarchy

- [x] Task 7: Create unit tests for GuidanceContext and service extensions (AC: 2, 3, 4)
  - [x] Test: GuidanceContext enum has correct French display names
  - [x] Test: GuidanceContext has appropriate prompt instructions
  - [x] Test: GuidanceContext icon properties validated
  - [x] Test: GuidanceContext CaseIterable and Identifiable conformance
  - [x] Test: GuidanceContext raw value initialization

- [x] Task 8: Integration testing and UI polish (AC: 1-6)
  - [x] Build succeeded for iOS Simulator (clean build passed)
  - [x] Quick context buttons visible in GuidanceControlsView (horizontal scroll)
  - [x] Guided suggestions pass guidance context to LLM
  - [x] "More like this" (context menu) calls generateVariations()
  - [x] "Different" button calls generateDifferentSuggestions()
  - [x] Response length from PersonalizationConfig respected (Story 4.1)
  - [x] Accessibility labels complete on all controls

## Dev Notes

### Architecture Context

This is **Story 4.2 of Epic 4: Personalized AI Experience**. Epic 4 structure:
- Story 4.1: LLM Personalization Settings (DONE) - User preferences for AI behavior
- Story 4.2: UI Guidance Controls (THIS STORY) - Real-time controls to guide suggestions

Story 4.2 builds on Story 4.1 (PersonalizationConfig) and Story 3.2/3.3 (SuggestionService/SuggestionView) to add real-time guidance controls.

### Functional Requirements Addressed

- **FR-12**: UI Guidance Controls - Interface allows guiding LLM responses

### Critical Implementation Requirements

**FOLLOW EXISTING PATTERNS - Reference SuggestionView.swift and PersonalizationConfig.swift**

The codebase has established patterns that MUST be followed:

**1. GuidanceContext Enum Pattern:**

```swift
// Models/GuidanceContext.swift
import Foundation

/// Quick context options for guiding AI suggestions (Story 4.2)
enum GuidanceContext: String, CaseIterable, Identifiable {
    case greeting = "greeting"      // Salutation
    case question = "question"      // Question
    case answer = "answer"          // Reponse
    case thanks = "thanks"          // Remerciement
    case goodbye = "goodbye"        // Au revoir

    var id: String { rawValue }

    /// French display name for UI (AC1)
    var displayName: String {
        switch self {
        case .greeting: return "Salutation"
        case .question: return "Question"
        case .answer: return "Reponse"
        case .thanks: return "Remerciement"
        case .goodbye: return "Au revoir"
        }
    }

    /// SF Symbol icon for button (AC1)
    var icon: String {
        switch self {
        case .greeting: return "hand.wave"
        case .question: return "questionmark.bubble"
        case .answer: return "text.bubble"
        case .thanks: return "heart"
        case .goodbye: return "hand.raised"
        }
    }

    /// Prompt instruction for LLM (AC2)
    var promptInstruction: String {
        switch self {
        case .greeting:
            return "Genere des salutations appropriees (Bonjour, Salut, Bonsoir, etc.)"
        case .question:
            return "Genere des questions pertinentes au contexte"
        case .answer:
            return "Genere des reponses adaptees a la conversation"
        case .thanks:
            return "Genere des expressions de remerciement (Merci, Je vous remercie, etc.)"
        case .goodbye:
            return "Genere des formules de depart (Au revoir, A bientot, Bonne journee, etc.)"
        }
    }
}
```

**2. SuggestionService Extensions:**

```swift
// In SuggestionService.swift - Add these properties and methods

// MARK: - Guidance Properties (Story 4.2)

/// Current guidance context for suggestions (AC1, AC2)
@Published var currentGuidance: GuidanceContext?

/// Last selected suggestion for "more like this" feature (AC3)
@Published private(set) var lastSelectedSuggestion: String?

/// Last prompt used for "different" feature (AC4)
private var lastPrompt: String = ""

// MARK: - Guided Generation Methods (Story 4.2)

/// Generates suggestions with a specific guidance context.
/// AC2: Guidance context influences the type of suggestions generated.
/// AC6: Conversation history is still considered.
func generateGuidedSuggestions(context: GuidanceContext, prompt: String? = nil) async {
    currentGuidance = context
    let effectivePrompt = prompt ?? context.displayName
    lastPrompt = effectivePrompt
    await generateSuggestions(for: effectivePrompt)
}

/// Generates variations of a specific suggestion.
/// AC3: "More like this" creates similar suggestions.
func generateVariations(of suggestion: String) async {
    lastSelectedSuggestion = suggestion
    // The LLM provider will include this in the system prompt
    await generateSuggestions(for: lastPrompt.isEmpty ? suggestion : lastPrompt)
}

/// Generates completely different suggestions.
/// AC4: Replaces current suggestions with new, different ones.
func generateDifferentSuggestions() async {
    // Clear last selected to signal "different" mode
    lastSelectedSuggestion = nil
    if !lastPrompt.isEmpty {
        await generateSuggestions(for: lastPrompt)
    }
}

/// Clears guidance context
func clearGuidance() {
    currentGuidance = nil
    lastSelectedSuggestion = nil
}
```

**3. OpenAICompatibleLLMProvider System Prompt Enhancement:**

```swift
// In OpenAICompatibleLLMProvider.swift - Enhance buildSystemPrompt()

private func buildSystemPrompt(
    guidance: GuidanceContext? = nil,
    moreLikeThis: String? = nil
) -> String {
    let config = PersonalizationConfig.loadFromUserDefaults()

    var prompt = """
    Tu es un assistant d'aide a la communication pour une personne qui ne peut pas parler. \
    Tu generes des suggestions de reponses courtes et naturelles en francais. \
    Genere exactement \(AppConfig.LLM.suggestionCount) suggestions differentes, \
    une par ligne, numerotees de 1 a \(AppConfig.LLM.suggestionCount).
    """

    // Add tone instruction (Story 4.1)
    prompt += " \(config.tone.promptInstruction)"

    // Add response length instruction (Story 4.1)
    prompt += " \(config.responseLength.promptInstruction)"

    // Add personal context if provided (Story 4.1)
    if !config.personalContext.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        prompt += " Contexte personnel de l'utilisateur: \(config.personalContext)"
    }

    // Add guidance context (Story 4.2 - AC2)
    if let guidance = guidance {
        prompt += " \(guidance.promptInstruction)"
    }

    // Add "more like this" instruction (Story 4.2 - AC3)
    if let reference = moreLikeThis {
        prompt += " Genere des variations similaires a: \"\(reference)\""
    }

    return prompt
}
```

**4. GuidanceControlsView Pattern:**

```swift
// Views/GuidanceControlsView.swift
import SwiftUI
import UIKit

/// Quick context controls for guiding AI suggestions (Story 4.2)
@MainActor
struct GuidanceControlsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Text("Guide rapide")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            // Quick context buttons - horizontal scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(GuidanceContext.allCases) { context in
                        GuidanceButton(
                            context: context,
                            isSelected: suggestionService.currentGuidance == context,
                            action: { selectGuidance(context) }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Controles de guidage IA")
    }

    private func selectGuidance(_ context: GuidanceContext) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        if suggestionService.currentGuidance == context {
            // Deselect if already selected
            suggestionService.clearGuidance()
        } else {
            Task {
                await suggestionService.generateGuidedSuggestions(context: context)
            }
        }
    }
}

/// Individual guidance button component (AC1)
@MainActor
struct GuidanceButton: View {
    let context: GuidanceContext
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: context.icon)
                    .font(.system(size: 14))
                Text(context.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.95, pressedColor: .clear, normalColor: .clear))
        .accessibilityLabel(context.displayName)
        .accessibilityHint("Genere des suggestions de type \(context.displayName.lowercased())")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
```

**5. SuggestionView Enhancement for "More Like This" and "Different":**

```swift
// In SuggestionView.swift - Add action buttons to headerView and SuggestionCard

// Add to headerView HStack, before refresh button:
// "Different" button (AC4)
Button(action: generateDifferent) {
    HStack(spacing: 4) {
        Image(systemName: "shuffle")
            .font(.system(size: 12, weight: .medium))
        Text("Autre")
            .font(.caption)
    }
    .foregroundColor(.secondary)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)
    .background(Color(.systemGray5))
    .cornerRadius(8)
}
.buttonStyle(ScaleButtonStyle(scaleAmount: 0.9, pressedColor: .clear, normalColor: .clear))
.disabled(suggestionService.isLoading || suggestionService.suggestions.isEmpty)
.opacity(suggestionService.isLoading || suggestionService.suggestions.isEmpty ? 0.4 : 1.0)
.accessibilityLabel("Autres suggestions")
.accessibilityHint("Genere des suggestions completement differentes")

// For "More like this" - add to SuggestionCard or as swipe action
// Option 1: Add small button to each card
// Option 2: Add as context menu
// Option 3: Long press gesture

// Recommended: Context menu on SuggestionCard
.contextMenu {
    Button {
        moreLikeThis(suggestion)
    } label: {
        Label("Plus comme ca", systemImage: "plus.circle")
    }
}

private func generateDifferent() {
    Task {
        await suggestionService.generateDifferentSuggestions()
    }
}

private func moreLikeThis(_ suggestion: String) {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
    Task {
        await suggestionService.generateVariations(of: suggestion)
    }
}
```

### Project Structure Notes

**Files to Create:**

| File | Purpose | Directory |
|------|---------|-----------|
| `GuidanceContext.swift` | Enum for guidance types | `Models/` |
| `GuidanceControlsView.swift` | UI for quick context buttons | `Views/` |

**Files to Modify:**

| File | Modification |
|------|-------------|
| `SuggestionService.swift` | Add guidance properties and methods |
| `OpenAICompatibleLLMProvider.swift` | Enhance buildSystemPrompt() for guidance |
| `SuggestionView.swift` | Add "Different" and "More like this" actions |
| `ContentView.swift` | Add GuidanceControlsView to layout |

**Files NOT to Modify:**

- `PersonalizationConfig.swift` - Already complete from Story 4.1
- `PersonalizationSettingsView.swift` - Response length control already exists there
- `LLMProvider.swift` - Protocol doesn't need changes
- `AppConfig.swift` - No configuration changes needed

**Project Path:**
```
HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/
|-- Models/
|   |-- GuidanceContext.swift           # NEW - This story
|   |-- PersonalizationConfig.swift     # DO NOT MODIFY (Story 4.1)
|   |-- LLMProvider.swift               # DO NOT MODIFY
|-- Managers/
|   |-- SuggestionService.swift         # MODIFY - Add guidance support
|-- Services/
|   |-- OpenAICompatibleLLMProvider.swift  # MODIFY - buildSystemPrompt()
|-- Views/
|   |-- GuidanceControlsView.swift      # NEW - This story
|   |-- SuggestionView.swift            # MODIFY - Add action buttons
|   |-- ContentView.swift               # MODIFY - Add GuidanceControlsView
|-- Tests/
    |-- GuidanceContextTests.swift      # NEW - Unit tests
```

### Previous Story Intelligence (Story 4.1)

**Key Learnings Applied:**

1. **Enum with displayName pattern** - CommunicationTone/ResponseLength enums have displayName and promptInstruction computed properties - follow same pattern for GuidanceContext

2. **@ObservedObject for singletons** - Use `@ObservedObject` not `@StateObject` for SuggestionService.shared

3. **French UI labels** - All text in French with proper accessibility hints

4. **Haptic feedback** - Use UIImpactFeedbackGenerator for button interactions (see SuggestionView.swift)

5. **ScaleButtonStyle** - Existing button style for consistent press animation

6. **Prompt integration pattern** - PersonalizationConfig is loaded in buildSystemPrompt() - add guidance the same way

**Files Created in Story 4.1 (Reference for patterns):**

| File | Relevant Pattern |
|------|------------------|
| `Models/PersonalizationConfig.swift` | Enum with displayName/promptInstruction |
| `Views/PersonalizationSettingsView.swift` | List/Section layout (not needed here) |

**Story 3.3 Patterns to Reuse:**

| File | Relevant Pattern |
|------|------------------|
| `Views/SuggestionView.swift` | SuggestionCard, headerView, button styling |
| `Managers/SuggestionService.swift` | @Published properties, async methods |

### Git Intelligence

**Recent Commits:**
- `3e6ddda Implement Stories 3.3, 4.1: Suggestion Selection UI and LLM Personalization with code review fixes`
- `9d6599b Implement Story 3.2: Multi-Suggestion Generation with code review fixes`

**Patterns from Recent Work:**
- Horizontal ScrollView for button groups (see existing patterns)
- `@ObservedObject` for shared service instances
- French labels for all UI text
- `.accessibilityLabel()` and `.accessibilityHint()` on all interactive elements
- Context menus for secondary actions
- Haptic feedback with UIImpactFeedbackGenerator

### Anti-Patterns to AVOID

- DO NOT create a new SuggestionService - extend the existing singleton
- DO NOT use `@StateObject` for SuggestionService - use `@ObservedObject`
- DO NOT duplicate response length UI - it already exists in PersonalizationSettingsView (AC5 refers to the persistent setting)
- DO NOT break existing SuggestionView functionality
- DO NOT use English text in UI - all labels must be in French
- DO NOT skip accessibility labels
- DO NOT forget haptic feedback on interactive elements
- DO NOT use completion handlers - use async/await with Task
- DO NOT modify PersonalizationConfig - guidance is transient, not persistent

### Technical Requirements from Architecture

From architecture document and project patterns:
- **@MainActor** on ObservableObject classes and Views
- **async/await** for all async operations
- **@Published** for reactive state
- **No external dependencies** - use native iOS APIs only
- **Singleton pattern** for SuggestionService (extend, don't replace)
- **French localization** for all user-facing text

### Guidance Prompt Engineering

The guidance should be injected into the system prompt in this order:
1. Base instruction (assistant role)
2. Suggestion count requirement
3. Tone instruction (from PersonalizationConfig)
4. Response length instruction (from PersonalizationConfig)
5. Personal context (from PersonalizationConfig, if provided)
6. **Guidance context instruction (NEW - this story)**
7. **"More like this" reference (NEW - this story, if applicable)**

**Example system prompt with greeting guidance:**
```
Tu es un assistant d'aide a la communication pour une personne qui ne peut pas parler. Tu generes des suggestions de reponses courtes et naturelles en francais. Genere exactement 4 suggestions differentes, une par ligne, numerotees de 1 a 4. Utilisez un langage courant et naturel. Genere des reponses de longueur moyenne de 2 a 4 phrases. Genere des salutations appropriees (Bonjour, Salut, Bonsoir, etc.)
```

**Example with "more like this":**
```
... Genere des variations similaires a: "Bonjour, comment allez-vous ?"
```

### Testing Checklist

After implementation, verify:

1. [ ] **Guidance buttons display**: GuidanceControlsView shows all context options
2. [ ] **Guidance selection**: Tapping a button generates appropriate suggestions
3. [ ] **Visual feedback**: Selected guidance button is highlighted
4. [ ] **Deselection**: Tapping selected button clears guidance
5. [ ] **More like this**: Context menu generates variations
6. [ ] **Different button**: Generates completely different suggestions
7. [ ] **History preserved**: Conversation history still affects suggestions
8. [ ] **Personalization respected**: Tone/length from 4.1 still applies
9. [ ] **Haptic feedback**: All buttons provide haptic feedback
10. [ ] **French labels**: All UI text is in French
11. [ ] **Accessibility**: All controls have proper labels and hints
12. [ ] **Loading state**: Shows loading while generating
13. [ ] **Project builds**: No warnings or errors

### References

- [Source: _bmad-output/planning-artifacts/epics.md#Story 4.2]
- [Source: HandwritingToSpeechSwiftUI/Views/SuggestionView.swift - Suggestion patterns]
- [Source: HandwritingToSpeechSwiftUI/Managers/SuggestionService.swift - Service patterns]
- [Source: HandwritingToSpeechSwiftUI/Services/OpenAICompatibleLLMProvider.swift - Prompt building]
- [Source: HandwritingToSpeechSwiftUI/Models/PersonalizationConfig.swift - Enum pattern]
- [Source: _bmad-output/implementation-artifacts/4-1-llm-personalization-settings.md - Previous story]
- [Source: _bmad-output/implementation-artifacts/3-3-suggestion-selection-ui.md - SuggestionView patterns]

### Dependencies

- **Depends on:** Story 4.1 (LLM Personalization Settings) - DONE
- **Depends on:** Story 3.2 (Multi-Suggestion Generation) - DONE
- **Depends on:** Story 3.3 (Suggestion Selection UI) - DONE
- **Blocks:** None - This is the final story of Epic 4

### Definition of Done

- [x] GuidanceContext enum created with French display names and prompt instructions
- [x] GuidanceControlsView created with horizontal scrollable buttons
- [x] SuggestionService extended with guidance properties and methods
- [x] buildSystemPrompt() includes guidance context when set
- [x] "More like this" generates variations via context menu
- [x] "Different" button replaces suggestions with new ones
- [x] Conversation history preserved when using guidance
- [x] All UI text in French
- [x] Accessibility labels on all controls
- [x] Haptic feedback on all interactive elements
- [x] Unit tests for GuidanceContext enum
- [x] Project builds successfully (iOS Simulator)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build verified: Clean build succeeded for iOS Simulator (iPad Pro 13-inch M4)

### Completion Notes List

- Created GuidanceContext enum with 5 context types (greeting, question, answer, thanks, goodbye)
- Extended SuggestionService with guidance properties and methods (generateGuidedSuggestions, generateVariations, generateDifferentSuggestions, clearGuidance)
- Modified OpenAICompatibleLLMProvider.buildSystemPrompt() to include guidance context and "more like this" reference
- Created GuidanceControlsView with horizontal scrollable button row and haptic feedback
- Added "Autre" (Different) button to SuggestionView header
- Added context menu "Plus comme ça" (More like this) to SuggestionCard
- Integrated GuidanceControlsView into ContentView above SuggestionView
- Created comprehensive unit tests for GuidanceContext enum

### Change Log

- 2026-01-26: Story created by create-story workflow (BMad Method)
- 2026-01-26: Implemented all 8 tasks - UI guidance controls fully functional
- 2026-01-26: Code review completed - 7 issues fixed:
  - H1: Added disable state to GuidanceButton during loading (prevents race condition)
  - H2: Added haptic feedback to "Autre" (Different) button
  - H3: Clear guidance state on error in handleError()
  - M1: Added 13 unit tests for SuggestionService guidance methods
  - M2: Added fallback in generateDifferentSuggestions() when no lastPrompt
  - M3: Fixed incorrect test assertion in testAllDisplayNamesAreFrench()
  - M4: GuidanceButton now visually indicates disabled state with opacity

### File List

| File | Action | Lines Changed |
|------|--------|---------------|
| Models/GuidanceContext.swift | Create | ~65 |
| Views/GuidanceControlsView.swift | Create | ~95 |
| Managers/SuggestionService.swift | Modify | +55 |
| Services/OpenAICompatibleLLMProvider.swift | Modify | +15 |
| Views/SuggestionView.swift | Modify | +45 |
| Views/ContentView.swift | Modify | +5 |
| Tests/GuidanceContextTests.swift | Create | ~115 |
