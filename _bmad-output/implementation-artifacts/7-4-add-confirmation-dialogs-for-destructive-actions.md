# Story 7.4: Add Confirmation Dialogs for Destructive Actions

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user who sometimes taps accidentally,
I want confirmation dialogs before destructive actions,
So that I don't accidentally clear my text or dismiss important content.

## Acceptance Criteria

1. **AC1: Clear Button Confirmation**
   - **Given** I have text in the input field
   - **When** I tap the "Effacer" button
   - **Then** a confirmation dialog appears: "Effacer le texte ?"
   - **And** the dialog has two buttons: "Annuler" and "Effacer" (destructive/red)
   - **And** tapping outside the dialog cancels the action

2. **AC2: Dismiss Suggestions Confirmation**
   - **Given** I have active suggestions displayed
   - **When** I tap the dismiss (X) button in SuggestionView header
   - **Then** a confirmation dialog appears: "Masquer les suggestions ?"
   - **And** the dialog offers "Annuler" and "Masquer" options

3. **AC3: Enhanced Mode Dialog Sizing**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** any confirmation dialog appears
   - **Then** dialog buttons are appropriately sized for accessibility
   - **Note:** SwiftUI .alert() uses system styling; button sizes follow iOS accessibility settings

4. **AC4: Confirmation Setting Option**
   - **Given** the user is in Accessibility Settings
   - **When** viewing the options
   - **Then** a "Demander confirmation" toggle is visible
   - **And** the toggle controls whether destructive actions require confirmation
   - **And** the setting defaults to ON (confirmations enabled)
   - **And** the setting is persisted in UserDefaults

## Tasks / Subtasks

- [x] Task 1: Extend AccessibilitySettings model (AC: 4)
  - [x] 1.1: Add `requireConfirmationDialogs: Bool` @Published property with UserDefaults persistence
  - [x] 1.2: Initialize to `true` (default: confirmations enabled)
  - [x] 1.3: Add private constant for UserDefaults key: `confirmation_dialogs_enabled`

- [x] Task 2: Update AccessibilitySettingsView (AC: 4)
  - [x] 2.1: Add Toggle for "Demander confirmation avant les actions destructives"
  - [x] 2.2: Add description text explaining the setting
  - [x] 2.3: Ensure toggle follows existing UI patterns (minimum 60pt height)

- [x] Task 3: Add confirmation to CompactClearButton (AC: 1, 4)
  - [x] 3.1: Add `@State private var showClearConfirmation: Bool = false` to CompactClearButton
  - [x] 3.2: Add `requireConfirmation: Bool` parameter to CompactClearButton
  - [x] 3.3: Modify button action to show alert if `requireConfirmation` is true and text not empty
  - [x] 3.4: Add `.alert("Effacer le texte ?")` modifier with "Annuler" and "Effacer" (role: .destructive) buttons
  - [x] 3.5: Move actual clear action (`recognizedText = ""` and `speakTask?.cancel()`) to alert's destructive button action
  - [x] 3.6: Update CompactClearButton call site in ControlButtonsView to pass `accessibilitySettings.requireConfirmationDialogs`

- [x] Task 4: Add confirmation to SuggestionView dismiss (AC: 2, 4)
  - [x] 4.1: Add `@State private var showDismissConfirmation: Bool = false` to SuggestionView
  - [x] 4.2: Modify dismiss button action to show alert if `accessibilitySettings.requireConfirmationDialogs` is true
  - [x] 4.3: Add `.alert("Masquer les suggestions ?")` modifier with "Annuler" and "Masquer" buttons
  - [x] 4.4: Move `suggestionService.clearSuggestions()` to alert's "Masquer" button action

- [x] Task 5: Testing (AC: 1-4)
  - [x] 5.1: Build succeeds without errors
  - [ ] 5.2: Clear button with text → confirmation dialog appears with "Annuler" and "Effacer"
  - [ ] 5.3: Clear button "Annuler" → text preserved, dialog closes
  - [ ] 5.4: Clear button "Effacer" → text cleared, dialog closes
  - [ ] 5.5: Dismiss suggestions → confirmation dialog appears with "Annuler" and "Masquer"
  - [ ] 5.6: Dismiss "Annuler" → suggestions preserved, dialog closes
  - [ ] 5.7: Dismiss "Masquer" → suggestions cleared, dialog closes
  - [ ] 5.8: Toggle "Demander confirmation" OFF → destructive actions execute immediately
  - [ ] 5.9: Toggle "Demander confirmation" ON → confirmation dialogs reappear
  - [ ] 5.10: App restart → confirmation setting preserved

## Dev Notes

### Target Files

**Files to modify:**

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift` - Add `requireConfirmationDialogs` property
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift` - Update CompactClearButton with confirmation
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift` - Update dismiss button with confirmation
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift` - Add confirmation toggle (if exists, otherwise check for SettingsSubmenuView)

### AccessibilitySettings Extension

Add this property to the existing `AccessibilitySettings` model:

```swift
// MARK: - Story 7.4: Confirmation Dialogs

/// Story 7.4 AC4: Toggle for confirmation dialogs on destructive actions
/// Defaults to true (confirmations enabled for safety)
@Published var requireConfirmationDialogs: Bool {
    didSet {
        UserDefaults.standard.set(requireConfirmationDialogs, forKey: Self.confirmationDialogsKey)
    }
}

// Story 7.4: UserDefaults key constant
private static let confirmationDialogsKey = "confirmation_dialogs_enabled"
```

Update the `init()` to load this setting:

```swift
init() {
    self.isEnhancedModeEnabled = UserDefaults.standard.bool(forKey: Self.userDefaultsKey)
    // Story 7.4: Load confirmation dialogs setting (default to true if not set)
    self.requireConfirmationDialogs = UserDefaults.standard.object(forKey: Self.confirmationDialogsKey) as? Bool ?? true
}
```

**Note:** Use `object(forKey:) as? Bool ?? true` to default to `true` when the key doesn't exist yet. Using `bool(forKey:)` alone would return `false` for a missing key.

### CompactClearButton Modification

Current implementation at `ControlButtonsView.swift:147-153`:

```swift
// Current - immediate action
Button(action: {
    let impact = UIImpactFeedbackGenerator(style: .medium)
    impact.impactOccurred()
    recognizedText = ""
    speakTask?.cancel()
}) {
```

Modified implementation:

```swift
// Story 7.4: Updated CompactClearButton with confirmation dialog
@MainActor
struct CompactClearButton: View {
    @Binding var recognizedText: String
    @Binding var speakTask: Task<Void, Never>?
    var isLoading: Bool
    var buttonHeight: CGFloat
    var scaleAnimationAmount: CGFloat = 0.97
    var animationDuration: Double = 0.2
    var requireConfirmation: Bool = true  // Story 7.4 AC1, AC4

    // Story 7.4 AC1: State for confirmation dialog
    @State private var showClearConfirmation: Bool = false

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            // Story 7.4 AC1: Show confirmation or clear immediately
            if requireConfirmation && !recognizedText.isEmpty {
                showClearConfirmation = true
            } else {
                performClear()
            }
        }) {
            // ... existing button content unchanged ...
        }
        // ... existing buttonStyle and modifiers ...
        // Story 7.4 AC1: Confirmation dialog
        .alert("Effacer le texte ?", isPresented: $showClearConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Effacer", role: .destructive) {
                performClear()
            }
        }
    }

    // Story 7.4: Extract clear action for reuse
    private func performClear() {
        recognizedText = ""
        speakTask?.cancel()
    }
}
```

Update call site in ControlButtonsView body (~line 259):

```swift
CompactClearButton(
    recognizedText: $recognizedText,
    speakTask: $speakTask,
    isLoading: speechService.isLoading,
    buttonHeight: accessibilitySettings.buttonHeight,
    scaleAnimationAmount: accessibilitySettings.scaleAnimationAmount,
    animationDuration: accessibilitySettings.animationDuration,
    requireConfirmation: accessibilitySettings.requireConfirmationDialogs  // Story 7.4 AC1
)
```

### SuggestionView Dismiss Button Modification

Current implementation at `SuggestionView.swift:219-236`:

```swift
// AC3: Dismiss button
Button(action: dismissSuggestions) {
    Image(systemName: "xmark")
    // ... styling ...
}
```

Modified implementation:

```swift
@MainActor
struct SuggestionView: View {
    // ... existing properties ...

    // Story 7.4 AC2: State for dismiss confirmation
    @State private var showDismissConfirmation: Bool = false

    // ... existing body ...

    // In headerView, modify dismiss button:
    // AC3: Dismiss button - Story 7.4 AC2: With confirmation
    Button(action: {
        if accessibilitySettings.requireConfirmationDialogs {
            showDismissConfirmation = true
        } else {
            dismissSuggestions()
        }
    }) {
        Image(systemName: "xmark")
        // ... existing styling unchanged ...
    }
    // ... existing modifiers ...
```

Add the alert modifier to the SuggestionView body (after the VStack):

```swift
.padding(.horizontal)
// Story 7.4 AC2: Confirmation dialog for dismiss
.alert("Masquer les suggestions ?", isPresented: $showDismissConfirmation) {
    Button("Annuler", role: .cancel) { }
    Button("Masquer", role: nil) {  // Not destructive, just informational
        dismissSuggestions()
    }
}
```

### AccessibilitySettingsView Toggle

Locate `AccessibilitySettingsView` (likely in Views folder) and add the confirmation toggle section:

```swift
// Story 7.4 AC4: Confirmation dialogs toggle
VStack(alignment: .leading, spacing: 8) {
    Toggle(isOn: $accessibilitySettings.requireConfirmationDialogs) {
        VStack(alignment: .leading, spacing: 4) {
            Text("Demander confirmation")
                .font(.body)
            Text("Affiche un dialogue avant les actions destructives (effacer, masquer)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    .toggleStyle(SwitchToggleStyle(tint: .blue))
    .padding(.vertical, 8)
    .frame(minHeight: accessibilitySettings.buttonHeight)  // Story 7.2 pattern
}
```

### Project Structure Notes

- **File locations follow existing patterns**: Views/ for SwiftUI views, Models/ for data models
- **No external dependencies**: Use native SwiftUI `.alert()` modifier
- **Follow @MainActor pattern**: All views use @MainActor
- **French localization**: All dialog text in French as per existing app pattern
- **iOS 16.0+ compatibility**: SwiftUI `.alert(title:isPresented:actions:)` is available since iOS 15

### SwiftUI Alert Pattern Reference

iOS 16+ recommended pattern:

```swift
.alert("Title", isPresented: $showAlert) {
    Button("Cancel", role: .cancel) { }
    Button("Destructive Action", role: .destructive) {
        // Perform action
    }
} message: {
    Text("Optional additional message")
}
```

**Note on AC3 (Enhanced Mode Dialog Sizing):** SwiftUI's native `.alert()` modifier uses system-provided styling that automatically respects iOS accessibility settings (Dynamic Type, etc.). Custom dialog sizing would require a custom sheet/overlay implementation, which is out of scope for this story. The native alert behavior is acceptable as it inherits system accessibility support.

### References

- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift:97-99] - Placeholder comment for Story 7.4
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift:134-186] - CompactClearButton definition
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift:148-153] - Current clear action (no confirmation)
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift:259-266] - CompactClearButton call site
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift:219-236] - Dismiss button implementation
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift:306-308] - dismissSuggestions() function
- [Source: _bmad-output/planning-artifacts/epics-ux-accessibility.md#Story 3.4] - Original requirements

### Previous Story Intelligence

**From Story 7.3 implementation:**

- AccessibilitySettings model uses `ObservableObject` pattern with `@Published` properties
- UserDefaults persistence pattern: set in `didSet`, load in `init()`
- Properties are accessed via `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
- Views inject accessibilitySettings via `.environmentObject()` in sheet/fullScreenCover presentations

**From Story 7.2 implementation:**

- Computed properties pattern: `isEnhancedModeEnabled ? enhancedValue : standardValue`
- Parameters passed to button components for conditional behavior

**From Story 7.1 implementation:**

- AccessibilitySettingsView exists with toggle for Enhanced mode
- Uses List with sections for settings organization
- Toggle uses `.toggleStyle(SwitchToggleStyle(tint: .blue))`

### Git Intelligence

**Recent relevant commits:**

- `65c9aaa` - Story 7.1: Accessibility Settings Screen with Enhanced Mode
- Stories 7.2, 7.3 (uncommitted) - Extended AccessibilitySettings with conditional properties

**Established patterns:**

- Inline comments reference Story ID and AC numbers
- @Published properties with UserDefaults persistence in didSet
- Parameters for conditional behavior passed to child components

### WARNING: Code Review Traps to Avoid

Based on previous code reviews:

1. **DO NOT use `bool(forKey:)` for defaulting to true** - Use `object(forKey:) as? Bool ?? true` instead
2. **DO NOT forget to update CompactClearButton call site** - Pass requireConfirmation parameter
3. **DO NOT break immediate action when confirmation is disabled** - Test both toggle states
4. **DO NOT use iOS 17-only alert features** - Project targets iOS 16.0+
5. **DO NOT forget haptic feedback** - Keep existing haptic feedback in button action
6. **DO NOT place .alert() on a disabled view** - Alert must be on an enabled view or the parent
7. **DO NOT skip testing toggle persistence** - Verify UserDefaults save/load works

### Alert Placement Considerations

**For CompactClearButton:** The `.alert()` modifier should be placed on the Button itself or on a parent view. Since CompactClearButton is a separate struct, placing it on the Button inside the struct is appropriate.

**For SuggestionView:** The `.alert()` modifier should be placed on the outermost VStack in the body (before .padding and .background modifiers work, but after structure modifiers). Test that the alert displays correctly.

### Related Stories

- **Story 7.1:** Create Accessibility Settings Screen with Enhanced Mode (DONE - provides settings screen structure)
- **Story 7.2:** Implement enlarged touch targets in Enhanced Mode (DONE - conditional sizing pattern)
- **Story 7.3:** Implement high contrast and reduced animations (DONE - visual changes)
- **Story 7.4:** Add confirmation dialogs for destructive actions (THIS STORY - behavioral changes)

This story completes Epic 7 (Accessibility Settings) by adding behavioral protections against accidental destructive actions.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

N/A

### Completion Notes List

- **Task 1:** Added `requireConfirmationDialogs: Bool` @Published property to AccessibilitySettings with UserDefaults persistence. Uses `object(forKey:) as? Bool ?? true` pattern to default to true when key doesn't exist. Added `confirmationDialogsKey` constant.
- **Task 2:** Added new "Sécurité" section to AccessibilitySettingsView with toggle for "Demander confirmation". Includes description text and follows existing UI patterns (60pt minimum height, haptic feedback, accessibility labels).
- **Task 3:** Updated CompactClearButton with `@State showClearConfirmation`, `requireConfirmation` parameter, conditional alert display, and extracted `performClear()` function. Updated call site in ControlButtonsView to pass `accessibilitySettings.requireConfirmationDialogs`.
- **Task 4:** Updated SuggestionView with `@State showDismissConfirmation`, conditional dismiss button action, and `.alert()` modifier on the VStack for "Masquer les suggestions ?" dialog.
- **Task 5.1:** Build succeeds with only existing deprecation warnings (unrelated to Story 7.4 changes).
- **Tasks 5.2-5.10:** Manual testing required on device to verify dialog behavior and persistence.

### File List

**Modified:**

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift` - Added `requireConfirmationDialogs` property with UserDefaults persistence
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift` - Added "Sécurité" section with confirmation toggle
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift` - Updated CompactClearButton with confirmation dialog and call site
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift` - Added dismiss confirmation dialog
