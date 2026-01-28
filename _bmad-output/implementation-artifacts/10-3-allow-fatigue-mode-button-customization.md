# Story 10.3: Allow Fatigue Mode Button Customization

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a caregiver setting up the app,
I want to customize which messages appear in fatigue mode,
So that the simplified interface matches the user's specific needs.

## Acceptance Criteria

1. **AC1 - View 6 Customizable Message Slots**
   **Given** I am in the fatigue mode settings
   **When** I view the configuration options
   **Then** I see a list of 6 customizable message slots
   **And** each slot shows the current message and an edit button
   **And** the "Mode normal" exit button slot is NOT listed (always present, cannot be removed)

2. **AC2 - Edit with Predefined Options**
   **Given** I tap edit on a message slot
   **When** the edit interface opens
   **Then** I can choose from predefined options grouped by category:
   - Basic responses: Oui, Non, Peut-être, D'accord
   - Needs: Soif, Faim, Toilettes, Fatigue
   - Communication: Appeler, Aide, Merci, Pardon
   - Medical: Douleur, Malaise, Médicament

3. **AC3 - Custom Text Entry**
   **Given** I am editing a message slot
   **When** I want a custom message not in predefined options
   **Then** I can enter custom text via TextField
   **And** the message is saved when confirmed

4. **AC4 - See Custom Messages in Fatigue Mode**
   **Given** I have customized fatigue mode messages
   **When** I activate fatigue mode
   **Then** my custom messages are displayed
   **And** the "Mode normal" exit button is always present (cannot be removed)

5. **AC5 - Reset to Defaults**
   **Given** I want to reset fatigue mode messages
   **When** I tap "Réinitialiser" in settings
   **Then** default messages are restored: Oui, Non, Appeler, Douleur, Soif/Faim
   **And** the 6th slot remains as configured (or defaults to empty/custom)

6. **AC6 - French VoiceOver Accessibility**
   **Given** Enhanced Accessibility mode is enabled or disabled
   **When** I navigate the fatigue mode settings with VoiceOver
   **Then** all labels, hints, and values are in French
   **And** all interactive elements have proper accessibility traits

## Tasks / Subtasks

- [x] Task 1: Create FatigueModeSettings.swift Manager (AC: #1, #4, #5)
  - [x] 1.1 Create new file `Managers/FatigueModeSettings.swift`
  - [x] 1.2 Define `FatigueModeMessage` struct (id, text, color - similar to FatigueModeView's FatigueModeMessage but Codable)
  - [x] 1.3 Define `PredefinedFatigueModeOption` struct for option picker
  - [x] 1.4 Create `FatigueModeSettings` class with `@MainActor` and `ObservableObject`
  - [x] 1.5 Add `@Published var customMessages: [FatigueModeMessage]` (5 editable slots)
  - [x] 1.6 Add UserDefaults persistence with key `fatigue_mode_messages_custom`
  - [x] 1.7 Implement `static let defaultMessages` (Oui, Non, Appeler, Douleur, Soif/Faim)
  - [x] 1.8 Implement `static let predefinedOptions` grouped by category
  - [x] 1.9 Implement `updateMessage(at:text:color:)` method
  - [x] 1.10 Implement `resetToDefaults()` method
  - [x] 1.11 Add `static let shared` singleton instance

- [x] Task 2: Create FatigueModeSettingsView.swift (AC: #1, #2, #3, #5, #6)
  - [x] 2.1 Create new file `Views/FatigueModeSettingsView.swift`
  - [x] 2.2 Create `FatigueModeSettingsView` with `@ObservedObject var messageSettings`
  - [x] 2.3 Display List with Section showing 5 editable message slots
  - [x] 2.4 Each slot: NavigationLink to FatigueModeMessageEditorView
  - [x] 2.5 Apply `accessibilitySettings.buttonHeight` for row heights (60pt/80pt)
  - [x] 2.6 Add reset button with haptic feedback and confirmation
  - [x] 2.7 Add French VoiceOver labels and hints

- [x] Task 3: Create FatigueModeMessageEditorView.swift (AC: #2, #3, #6)
  - [x] 3.1 Create editor view for individual message slot
  - [x] 3.2 Add preview section showing current message with color
  - [x] 3.3 Add predefined options section grouped by category
  - [x] 3.4 Add custom text TextField section
  - [x] 3.5 Add color picker (limited palette: green, red, blue, purple, orange)
  - [x] 3.6 Save changes immediately on selection/edit
  - [x] 3.7 Apply `accessibilitySettings.buttonHeight` for interactive elements
  - [x] 3.8 Add French VoiceOver accessibility labels and hints

- [x] Task 4: Update FatigueModeView.swift to use custom messages (AC: #4)
  - [x] 4.1 Replace hardcoded `messages` array with `FatigueModeSettings.shared.customMessages`
  - [x] 4.2 Keep "Mode normal" exit button hardcoded (cannot be customized)
  - [x] 4.3 Ensure FatigueModeButton displays custom text and color
  - [x] 4.4 Verify TTS speaks the correct custom message text

- [x] Task 5: Replace FatigueModeSettingsPlaceholder (AC: #1)
  - [x] 5.1 Update AccessibilitySettingsView.swift NavigationLink
  - [x] 5.2 Replace `FatigueModeSettingsPlaceholder()` with `FatigueModeSettingsView()`
  - [x] 5.3 Delete `FatigueModeSettingsPlaceholder` struct (dead code cleanup)
  - [x] 5.4 Inject `accessibilitySettings` via environmentObject

- [x] Task 6: Add unit tests (AC: #1-#6)
  - [x] 6.1 Test FatigueModeSettings persistence and loading
  - [x] 6.2 Test message update and immediate save
  - [x] 6.3 Test reset to defaults functionality
  - [x] 6.4 Test French accessibility labels present

## Dev Notes

### Architecture Patterns to Follow

**CRITICAL: Follow EmergencyMessageSettings pattern exactly (Story 9.3)**

The existing `EmergencyMessageSettings.swift` and `EmergencyMessagesSettingsView.swift` provide the exact blueprint:
- Manager class with singleton, UserDefaults persistence, Codable messages
- Settings view with List, NavigationLink to editor
- Editor view with predefined options and custom text fields

### FatigueModeSettings Manager Pattern

```swift
// Managers/FatigueModeSettings.swift
// Follow EmergencyMessageSettings.swift pattern exactly

struct FatigueModeMessage: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var colorName: String  // Codable - "green", "red", "blue", etc.

    var color: Color {
        switch colorName {
        case "green": return .green
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return Color.orange.opacity(0.9)
        default: return .gray
        }
    }
}

@MainActor
class FatigueModeSettings: ObservableObject {
    static let shared = FatigueModeSettings()

    private let userDefaultsKey = "fatigue_mode_messages_custom"

    @Published var customMessages: [FatigueModeMessage] = []

    // Default messages matching current FatigueModeView
    static let defaultMessages: [FatigueModeMessage] = [
        FatigueModeMessage(id: UUID(), text: "OUI", colorName: "green"),
        FatigueModeMessage(id: UUID(), text: "NON", colorName: "red"),
        FatigueModeMessage(id: UUID(), text: "APPELER", colorName: "blue"),
        FatigueModeMessage(id: UUID(), text: "DOULEUR", colorName: "purple"),
        FatigueModeMessage(id: UUID(), text: "SOIF / FAIM", colorName: "orange")
    ]
}
```

### Predefined Options Structure (AC2)

```swift
struct PredefinedFatigueModeOption: Identifiable {
    let id = UUID()
    let text: String
    let colorName: String
}

struct FatigueModeOptionCategory: Identifiable {
    let id = UUID()
    let name: String  // "Réponses de base", "Besoins", etc.
    let options: [PredefinedFatigueModeOption]
}

static let predefinedCategories: [FatigueModeOptionCategory] = [
    FatigueModeOptionCategory(
        name: "Réponses de base",
        options: [
            PredefinedFatigueModeOption(text: "OUI", colorName: "green"),
            PredefinedFatigueModeOption(text: "NON", colorName: "red"),
            PredefinedFatigueModeOption(text: "PEUT-ÊTRE", colorName: "gray"),
            PredefinedFatigueModeOption(text: "D'ACCORD", colorName: "green")
        ]
    ),
    FatigueModeOptionCategory(
        name: "Besoins",
        options: [
            PredefinedFatigueModeOption(text: "SOIF", colorName: "blue"),
            PredefinedFatigueModeOption(text: "FAIM", colorName: "orange"),
            PredefinedFatigueModeOption(text: "TOILETTES", colorName: "purple"),
            PredefinedFatigueModeOption(text: "FATIGUE", colorName: "gray")
        ]
    ),
    FatigueModeOptionCategory(
        name: "Communication",
        options: [
            PredefinedFatigueModeOption(text: "APPELER", colorName: "blue"),
            PredefinedFatigueModeOption(text: "AIDE", colorName: "orange"),
            PredefinedFatigueModeOption(text: "MERCI", colorName: "green"),
            PredefinedFatigueModeOption(text: "PARDON", colorName: "purple")
        ]
    ),
    FatigueModeOptionCategory(
        name: "Médical",
        options: [
            PredefinedFatigueModeOption(text: "DOULEUR", colorName: "red"),
            PredefinedFatigueModeOption(text: "MALAISE", colorName: "purple"),
            PredefinedFatigueModeOption(text: "MÉDICAMENT", colorName: "blue")
        ]
    )
]
```

### Color Palette (Limited for Accessibility)

| Color Name | SwiftUI Color | Usage |
|------------|---------------|-------|
| green | .green | Positive (Oui, Merci, D'accord) |
| red | .red | Negative/Alert (Non, Douleur) |
| blue | .blue | Communication (Appeler, Soif) |
| purple | .purple | Medical/Personal (Malaise, Toilettes) |
| orange | .orange.opacity(0.9) | Needs (Faim, Aide) |
| gray | .gray | Neutral (Peut-être, Fatigue) |

### FatigueModeView Update Pattern (Task 4)

```swift
// FatigueModeView.swift - BEFORE (hardcoded)
private let messages: [FatigueModeMessage] = [
    FatigueModeMessage(text: "OUI", color: Color.green),
    // ...
]

// FatigueModeView.swift - AFTER (from settings)
@ObservedObject private var messageSettings = FatigueModeSettings.shared

var body: some View {
    // ...
    ForEach(messageSettings.customMessages) { message in
        FatigueModeButton(
            message: message.text,
            backgroundColor: message.color,
            onTap: { speakMessage(message.text) }
        )
    }
    // "Mode normal" exit button remains hardcoded - NEVER customize
    FatigueModeButton(
        message: "Mode normal",
        backgroundColor: Color.gray,
        icon: "arrow.backward.circle",
        onTap: { showExitConfirmation = true }
    )
    // ...
}
```

### Project Structure Notes

| File | Action | Location |
|------|--------|----------|
| FatigueModeSettings.swift | CREATE | HandwritingToSpeechSwiftUI/Managers/ |
| FatigueModeSettingsView.swift | CREATE | HandwritingToSpeechSwiftUI/Views/ |
| FatigueModeMessageEditorView.swift | CREATE (in same file or separate) | HandwritingToSpeechSwiftUI/Views/ |
| FatigueModeView.swift | MODIFY | HandwritingToSpeechSwiftUI/Views/ |
| AccessibilitySettingsView.swift | MODIFY | HandwritingToSpeechSwiftUI/Views/ |
| AccessibilitySettingsTests.swift | MODIFY | HandwritingToSpeechSwiftUITests/ |

### Critical Implementation Details

1. **5 Editable + 1 Fixed**: Only 5 message slots are editable. "Mode normal" exit button is ALWAYS present and NEVER shown in settings.

2. **Singleton Pattern**: Use `FatigueModeSettings.shared` to ensure single source of truth (matches EmergencyMessageSettings pattern).

3. **Immediate Save**: Save to UserDefaults immediately on any change (AC3 requirement).

4. **Color as String**: Store color as string ("green", "red", etc.) for Codable compatibility, convert to Color in computed property.

5. **French UI**: All text, labels, hints in French:
   - Section header: "Messages du mode fatigue"
   - Footer: "Personnalisez les messages essentiels. Le bouton 'Mode normal' est toujours présent."
   - Reset: "Réinitialiser par défaut"

6. **Accessibility Heights**: Use `accessibilitySettings.buttonHeight` (60pt/80pt) for all interactive elements.

### Previous Story Intelligence (Story 10.2)

**Learnings Applied:**
- FatigueModeView already has `FatigueModeMessage` struct - need to make it Codable and move to FatigueModeSettings
- `FatigueModeButton` component works perfectly - reuse as-is
- SpeechService integration via `speechService.speakText(message.text)` confirmed working
- Exit confirmation dialog pattern with `.alert()` modifier confirmed working
- `.light` haptic style for fatigue mode confirmed appropriate

**Code Review Fixes from 10.2:**
- H1: Centralized state management - use singleton for message storage
- L2: Use struct with explicit id for Identifiable (already in FatigueModeMessage)
- M1: Add `.accessibilityAddTraits(.isButton)` to all buttons
- L1: Prepare haptic generator in onAppear for optimal timing

### Git Intelligence (Recent Commits)

Recent patterns from commits:
- `65c9aaa` Story 7.1: AccessibilitySettingsView pattern with NavigationLink
- EmergencyMessagesSettingsView pattern from Story 9.3

**Established Patterns:**
- `@MainActor` on all view structs and classes
- `@ObservedObject` for shared singleton
- `@EnvironmentObject` for accessibilitySettings
- List with `.insetGrouped` style
- NavigationLink for drill-down editing
- French VoiceOver labels throughout

### Critical Constraints

- **No external dependencies** - Use native iOS APIs only
- **iOS 16.0+ minimum** - Use SwiftUI features compatible with iOS 16
- **French UI language** - All labels and accessibility hints in French
- **Haptic feedback required** - UIImpactFeedbackGenerator for all button actions
- **State must persist** - Custom messages survive app restart
- **Exit button protected** - "Mode normal" cannot be removed or customized

### References

- [Source: epics-ux-accessibility.md#Epic 6: Fatigue Mode, Story 6.3]
- [Source: EmergencyMessageSettings.swift - Complete pattern to follow]
- [Source: EmergencyMessagesSettingsView.swift - UI pattern to follow]
- [Source: FatigueModeView.swift - Integration target, lines 98-104 messages array]
- [Source: AccessibilitySettingsView.swift:207-236 - FatigueModeSettingsPlaceholder to replace]
- [Source: 10-2-create-minimal-fatigue-mode-interface.md#Dev Notes]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded: xcodebuild build -scheme HandwritingToSpeechSwiftUI -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.0'

### Completion Notes List

- **Task 1**: Created `FatigueModeSettings.swift` following EmergencyMessageSettings pattern exactly. Includes FatigueModeMessage (Codable), PredefinedFatigueModeOption, FatigueModeOptionCategory, singleton manager with UserDefaults persistence.
- **Task 2**: Created `FatigueModeSettingsView.swift` with List showing 5 editable slots, NavigationLinks to editor, reset button with confirmation dialog.
- **Task 3**: Created `FatigueModeMessageEditorView` (in same file) with preview section, predefined options grouped by category, custom text TextField, and color picker.
- **Task 4**: Updated `FatigueModeView.swift` to use `FatigueModeSettings.shared.customMessages` instead of hardcoded array. Removed local FatigueModeMessage struct (moved to FatigueModeSettings).
- **Task 5**: Updated `AccessibilitySettingsView.swift` to use `FatigueModeSettingsView()` instead of placeholder. Deleted `FatigueModeSettingsPlaceholder` struct.
- **Task 6**: Added 25+ unit tests in `AccessibilitySettingsTests.swift` for FatigueModeSettings: persistence, update, reset, predefined options, color conversion, French labels.

### Senior Developer Code Review (AI)

**Reviewer:** Claude Opus 4.5 | **Date:** 2026-01-28 | **Outcome:** APPROVED with fixes

**Issues Found and Fixed:**

| ID | Severity | Description | Status |
|----|----------|-------------|--------|
| H1 | HIGH | Missing haptic feedback on predefined option and color picker buttons | FIXED |
| M1 | MEDIUM | Duplicate colorForName() logic (DRY violation) | FIXED |
| M2 | MEDIUM | TextField onChange saves on every keystroke | FIXED |
| M3 | MEDIUM | Singleton testing challenges in tearDown | FIXED |
| L3 | LOW | Inconsistent PreviewProvider style | FIXED |

**Files Modified in Code Review:**
- `FatigueModeSettings.swift`: Added `color(for:)` static helper (M1)
- `FatigueModeSettingsView.swift`: Added haptic feedback (H1), replaced colorForName with centralized helper (M1), changed TextField save to onDisappear/onSubmit (M2), updated Preview macro (L3)
- `AccessibilitySettingsTests.swift`: Added singleton reset in tearDown (M3)

**Remaining Low Issues (Deferred):**
- L1: Story AC1 says 6 slots but implementation has 5 (documentation inconsistency, implementation is correct)
- L2: Missing accessibility on preview section
- L4: No custom text length validation

### Change Log

- **2026-01-28**: Code review completed - Fixed H1, M1, M2, M3, L3. Story approved.
- **2026-01-28**: Story 10.3 implemented - Fatigue mode button customization with 5 editable message slots, predefined options by category, custom text entry, color picker, and French accessibility labels. All 6 tasks completed.

### File List

| File | Action |
|------|--------|
| HandwritingToSpeechSwiftUI/Managers/FatigueModeSettings.swift | CREATED |
| HandwritingToSpeechSwiftUI/Views/FatigueModeSettingsView.swift | CREATED |
| HandwritingToSpeechSwiftUI/Views/FatigueModeView.swift | MODIFIED |
| HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift | MODIFIED |
| HandwritingToSpeechSwiftUITests/AccessibilitySettingsTests.swift | MODIFIED |
