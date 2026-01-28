# Story 11.2: Allow Time-Based Phrase Customization

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a caregiver or user,
I want to customize which phrases appear for each time period,
So that suggestions match my specific daily routine.

## Acceptance Criteria

1. **AC1 - Access Configuration Screen**
   - Given I am in the accessibility settings
   - When I tap on "Phrases du moment"
   - Then a configuration screen opens showing the 4 time periods

2. **AC2 - View Period Phrases**
   - Given I am on the time-based phrases configuration
   - When I tap on a time period (e.g., "Matin 7h-9h")
   - Then I see the list of phrases for that period
   - And I can add, edit, or remove phrases
   - And each period supports 4-6 phrases

3. **AC3 - Save Custom Phrases**
   - Given I edit phrases for a time period
   - When I save my changes
   - Then the custom phrases are used for that time period
   - And changes take effect immediately

4. **AC4 - Disable Feature Toggle**
   - Given I want to disable time-based suggestions
   - When I toggle off "Suggestions du moment" in settings
   - Then the section no longer appears on the main screen

## Tasks / Subtasks

- [x] Task 1: Extend TimeBasedPhraseSettings Model (AC: 2, 3)
  - [x] 1.1: Add `customPhrases: [TimePeriod: [String]]` property with UserDefaults persistence
  - [x] 1.2: Create namespaced UserDefaults key: `com.callivox.time_based_custom_phrases`
  - [x] 1.3: Implement `updatePhrases(for period: TimePeriod, phrases: [String])` method
  - [x] 1.4: Implement `addPhrase(to period: TimePeriod, phrase: String)` method with 6-phrase limit
  - [x] 1.5: Implement `removePhrase(from period: TimePeriod, at index: Int)` method
  - [x] 1.6: Implement `resetToDefaults()` method that clears customPhrases
  - [x] 1.7: Modify `phrasesForCurrentPeriod()` to return customPhrases if set, else defaultPhrases
  - [x] 1.8: Implement `phrases(for period: TimePeriod)` to return custom or default

- [x] Task 2: Create TimeBasedPhrasesSettingsView (AC: 1, 4)
  - [x] 2.1: Create `TimeBasedPhrasesSettingsView.swift` in `Views/` folder
  - [x] 2.2: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 2.3: Add `@ObservedObject var timeSettings = TimeBasedPhraseSettings.shared`
  - [x] 2.4: Create Toggle for `timeSettings.isEnabled` with description "Affiche des suggestions basées sur l'heure"
  - [x] 2.5: Create Section with ForEach over `TimePeriod.allCases` (excluding .none)
  - [x] 2.6: Each period shows: icon, displayName, time range, phrase count
  - [x] 2.7: NavigationLink to `TimeBasedPeriodEditorView` for each period
  - [x] 2.8: Add "Réinitialiser par défaut" button with confirmation alert
  - [x] 2.9: Apply `accessibilitySettings.buttonHeight` for minimum heights
  - [x] 2.10: Add French VoiceOver labels and hints

- [x] Task 3: Create TimeBasedPeriodEditorView (AC: 2, 3)
  - [x] 3.1: Create `TimeBasedPeriodEditorView.swift` in `Views/` folder
  - [x] 3.2: Accept `period: TimePeriod` as parameter
  - [x] 3.3: Display header with period icon, name, and time range
  - [x] 3.4: Show current phrases in List with edit capability
  - [x] 3.5: Add "Ajouter une phrase" button (disabled if 6 phrases already)
  - [x] 3.6: Implement swipe-to-delete for phrases (minimum 1 phrase required)
  - [x] 3.7: Implement inline text editing via TextField
  - [x] 3.8: Save changes immediately on edit (like FatigueModeMessageEditorView pattern)
  - [x] 3.9: Apply accessibility heights and VoiceOver labels
  - [x] 3.10: Add haptic feedback for add/delete actions (.medium)

- [x] Task 4: Integrate into AccessibilitySettingsView (AC: 1)
  - [x] 4.1: Add new Section for "Suggestions contextuelles"
  - [x] 4.2: Add NavigationLink to TimeBasedPhrasesSettingsView
  - [x] 4.3: Use clock.badge.fill icon with blue color
  - [x] 4.4: Show label "Phrases du moment" with description
  - [x] 4.5: Apply minimum 60pt height and VoiceOver accessibility

- [x] Task 5: Unit Tests
  - [x] 5.1: Test customPhrases persistence to UserDefaults
  - [x] 5.2: Test addPhrase respects 6-phrase limit
  - [x] 5.3: Test removePhrase maintains minimum 1 phrase
  - [x] 5.4: Test resetToDefaults clears custom phrases
  - [x] 5.5: Test phrasesForCurrentPeriod returns custom over default

## Dev Notes

### Critical Pattern Reference: FatigueModeSettingsView

This story MUST follow the exact pattern established in `FatigueModeSettingsView.swift` and `FatigueModeMessageEditorView`. Key patterns:

```swift
// Settings list view pattern
@MainActor
struct TimeBasedPhrasesSettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var timeSettings = TimeBasedPhraseSettings.shared
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        List {
            // Toggle section
            Section {
                Toggle(isOn: $timeSettings.isEnabled) { ... }
                    .frame(minHeight: accessibilitySettings.buttonHeight)
            }

            // Period list section
            Section {
                ForEach(TimePeriod.allCases.filter { $0 != .none }, id: \.self) { period in
                    NavigationLink { ... } label: { ... }
                }
            }

            // Reset button section
            Section {
                Button("Réinitialiser par défaut") { showResetConfirmation = true }
            }
        }
        .alert("Réinitialiser ?", isPresented: $showResetConfirmation) { ... }
    }
}
```

### Model Extension Pattern

Extend `TimeBasedPhraseSettings.swift` following existing code structure:

```swift
// Add to TimeBasedPhraseSettings class

// MARK: - Story 11.2: Custom Phrases Storage

private static let customPhrasesKey = "com.callivox.time_based_custom_phrases"

/// Custom phrases per period, overrides defaults when set
@Published var customPhrases: [String: [String]] = [:] {
    didSet {
        saveCustomPhrases()
    }
}

private func saveCustomPhrases() {
    // Encode to JSON and save to UserDefaults
    if let data = try? JSONEncoder().encode(customPhrases) {
        UserDefaults.standard.set(data, forKey: Self.customPhrasesKey)
    }
}

private func loadCustomPhrases() {
    guard let data = UserDefaults.standard.data(forKey: Self.customPhrasesKey),
          let phrases = try? JSONDecoder().decode([String: [String]].self, from: data) else {
        return
    }
    customPhrases = phrases
}

/// Story 11.2 AC2: Update all phrases for a period
func updatePhrases(for period: TimePeriod, phrases: [String]) {
    guard period != .none else { return }
    customPhrases[period.rawValue] = phrases
}

/// Story 11.2 AC2: Add phrase to period (max 6)
func addPhrase(to period: TimePeriod, phrase: String) -> Bool {
    guard period != .none else { return false }
    var current = phrases(for: period) ?? []
    guard current.count < 6 else { return false }
    current.append(phrase)
    customPhrases[period.rawValue] = current
    return true
}

/// Story 11.2 AC2: Remove phrase from period (min 1)
func removePhrase(from period: TimePeriod, at index: Int) -> Bool {
    guard period != .none else { return false }
    var current = customPhrases[period.rawValue] ?? defaultPhrases[period] ?? []
    guard current.count > 1, index < current.count else { return false }
    current.remove(at: index)
    customPhrases[period.rawValue] = current
    return true
}

/// Story 11.2 AC3: Reset all custom phrases to defaults
func resetToDefaults() {
    customPhrases = [:]
    UserDefaults.standard.removeObject(forKey: Self.customPhrasesKey)
}

// MODIFY existing method:
func phrases(for period: TimePeriod) -> [String]? {
    guard period != .none else { return nil }
    // Return custom phrases if set, otherwise defaults
    if let custom = customPhrases[period.rawValue], !custom.isEmpty {
        return custom
    }
    return defaultPhrases[period]
}
```

### File Locations

| File | Directory | Purpose |
|------|-----------|---------|
| `TimeBasedPhraseSettings.swift` | `Managers/` | MODIFY - Add custom phrase storage |
| `TimeBasedPhrasesSettingsView.swift` | `Views/` | NEW - Settings list view |
| `TimeBasedPeriodEditorView.swift` | `Views/` | NEW - Period phrase editor |
| `AccessibilitySettingsView.swift` | `Views/` | MODIFY - Add navigation link |
| `TimeBasedPhraseSettingsTests.swift` | `Tests/` | MODIFY - Add custom phrase tests |

### UI Text (French)

| Context | Text |
|---------|------|
| Settings section header | "Suggestions contextuelles" |
| NavigationLink label | "Phrases du moment" |
| NavigationLink description | "Personnaliser les phrases suggérées selon l'heure" |
| Toggle label | "Activer les suggestions du moment" |
| Toggle description | "Affiche des phrases adaptées à chaque période de la journée" |
| Period section header | "Périodes de la journée" |
| Reset button | "Réinitialiser par défaut" |
| Reset alert title | "Réinitialiser les phrases ?" |
| Reset alert message | "Toutes les phrases personnalisées seront remplacées par les phrases par défaut." |
| Add phrase button | "Ajouter une phrase" |
| Delete hint | "Balayez pour supprimer" |
| Max phrases reached | "Maximum 6 phrases par période" |
| Min phrases warning | "Minimum 1 phrase requise" |

### Time Period Display Format

| Period | Display Name | Time Range | Icon |
|--------|-------------|------------|------|
| morning | Matin | 7h-9h | sunrise.fill |
| lunch | Midi | 12h-14h | sun.max.fill |
| evening | Soir | 18h-20h | sunset.fill |
| night | Nuit | 21h-23h | moon.stars.fill |

### Accessibility Requirements

- All list rows minimum `accessibilitySettings.buttonHeight` (60pt/80pt)
- VoiceOver labels in French for all interactive elements
- VoiceOver hints explaining actions ("Ouvrir la configuration", "Modifier cette phrase", etc.)
- Haptic feedback: `.medium` for add/delete, `.light` for navigation
- Announce list changes to VoiceOver users

### Project Structure Notes

- Alignment with unified project structure: New files in `Views/` directory
- Pattern consistency: Follows FatigueModeSettingsView exactly
- No conflicts detected with existing code
- Extension of existing TimeBasedPhraseSettings singleton

### References

- [Source: epics-ux-accessibility.md#Story-7.2-Allow-Time-Based-Phrase-Customization]
- [Source: project-context.md#SwiftUI-Patterns]
- [Pattern: FatigueModeSettingsView.swift - Complete UI pattern to follow]
- [Pattern: FatigueModeMessageEditorView - Editor pattern]
- [Pattern: TimeBasedPhraseSettings.swift - Model to extend]
- [Pattern: AccessibilitySettingsView.swift - Integration point]

### Testing Considerations

- Test UserDefaults persistence by saving/loading custom phrases
- Test phrase limits (min 1, max 6 per period)
- Test resetToDefaults clears all custom phrases
- Test that custom phrases take precedence over defaults
- Test that disabling feature hides section on main screen
- Verify accessibility sizing in both standard and enhanced modes

### Edge Cases to Handle

1. **Empty custom phrases array**: Fall back to default phrases
2. **Phrase limit reached**: Disable "Add" button, show info message
3. **Last phrase deletion**: Prevent deletion, show warning
4. **Very long phrases**: Truncate display with "..." but store full text
5. **Special characters**: Allow all Unicode characters in phrases
6. **Duplicate phrases**: Allow (user may want same phrase at different times)

### Previous Story (11.1) Learnings Applied

From Story 11.1 code review:
- **M2**: Use namespaced UserDefaults keys (`com.callivox.*`)
- **M3**: Announce UI changes to VoiceOver users
- **M4**: Validate input parameters
- Deterministic tests for time-based logic

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

N/A

### Completion Notes List

- **Task 1 Complete**: Extended TimeBasedPhraseSettings model with customPhrases dictionary, UserDefaults persistence (JSON encoding), and methods for add/remove/update/reset. Added timeRangeDisplay property to TimePeriod enum.
- **Task 2 Complete**: Created TimeBasedPhrasesSettingsView with toggle, period list, reset button. Follows FatigueModeSettingsView pattern exactly.
- **Task 3 Complete**: Created TimeBasedPeriodEditorView with inline editing, swipe-to-delete, add phrase, and immediate save functionality. VoiceOver announcements for list changes.
- **Task 4 Complete**: Integrated into AccessibilitySettingsView with new "Suggestions contextuelles" section and NavigationLink.
- **Task 5 Complete**: Added 15+ unit tests for custom phrases persistence, phrase limits (min 1, max 6), reset to defaults, and custom over default priority.

### Code Review Fixes Applied

- **M1**: Fixed timeRangeDisplay to match actual hourRange (7h-8h59 instead of 7h-9h)
- **M2**: Updated onChange modifier to iOS 17+ syntax (zero-parameter closure)
- **M3**: Corrected misleading comment in loadCustomPhrases about didSet behavior
- **M4**: Added missing unit test for updatePhrases with .none period
- **L1**: Added DispatchQueue.main.asyncAfter delay for VoiceOver announcements
- **L2**: Removed redundant onDisappear save (changes saved immediately in actions)
- **L3**: Added accessibility value to reset button showing customization state
- **L4**: Added explicit 44pt frame constraints to inline edit buttons

### Code Review 2026-01-28 (Adversarial Review)

**Reviewer**: Claude Opus 4.5 (Adversarial Senior Developer)
**Build Status**: SUCCEEDED

Issues found and fixed:

| ID | Severity | File | Issue | Status |
|----|----------|------|-------|--------|
| M5 | MEDIUM | TimeBasedPeriodEditorView.swift | ForEach using `\.offset` as id causes unstable identifiers during edits | FIXED - Changed to `\.element` |
| L3 | LOW | TimeBasedPeriodEditorView.swift, TimeBasedPhrasesSettingsView.swift | Duplicate `iconColor` function in multiple views | FIXED - Centralized in TimePeriod enum |

**Changes Applied**:
- `TimeBasedPeriodEditorView.swift:71`: Changed `ForEach(Array(editingPhrases.enumerated()), id: \.offset)` to `id: \.element`
- `TimeBasedPhraseSettings.swift`: Added `iconColor: Color` computed property to `TimePeriod` enum
- `TimeBasedPeriodEditorView.swift`: Removed local iconColor function, uses `period.iconColor`
- `TimeBasedPhrasesSettingsView.swift`: Removed local iconColor function, uses `period.iconColor`

### Change Log

- 2026-01-28: Story 11.2 implemented - Time-based phrase customization feature
- 2026-01-28: Code review fixes applied (8 issues: M1-M4, L1-L4)
- 2026-01-28: Adversarial code review fixes applied (2 issues: M5, L3)

### File List

**New Files:**

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/TimeBasedPhrasesSettingsView.swift`
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/TimeBasedPeriodEditorView.swift`

**Modified Files:**

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Managers/TimeBasedPhraseSettings.swift`
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift`
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUITests/TimeBasedPhraseSettingsTests.swift`

