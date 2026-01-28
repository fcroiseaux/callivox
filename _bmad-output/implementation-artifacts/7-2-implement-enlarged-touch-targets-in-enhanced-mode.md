# Story 7.2: Implement Enlarged Touch Targets in Enhanced Mode

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with severe tremors,
I want all touch targets to be 80pt minimum when Enhanced Accessibility is enabled,
So that I can interact with the app more reliably during difficult periods.

## Acceptance Criteria

1. **AC1: KeywordChipsView Enlarged**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** I view KeywordChipsView
   - **Then** all keyword chips have minimum 80pt height (instead of 60pt)

2. **AC2: GuidanceControlsView Enlarged**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** I view GuidanceControlsView or its modal
   - **Then** all buttons have minimum 80pt height
   - **And** the close button in modal has minimum 80pt height

3. **AC3: SuggestionView Header Enlarged**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** I view SuggestionView
   - **Then** suggestion cards have increased padding
   - **And** header buttons (refresh, dismiss, "Autre") are minimum 60pt (instead of 44pt)

4. **AC4: Sidebar Buttons Enlarged**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** I view the sidebar (ControlButtonsView)
   - **Then** the primary "PARLER" button is 200x100pt (instead of 200x80pt)
   - **And** secondary buttons (Répéter, Effacer) are minimum 80pt height (instead of 60pt)
   - **And** tertiary buttons (Mes phrases, Paramètres) are minimum 60pt height (instead of 50pt)

5. **AC5: Standard Mode Sizes Preserved**
   - **Given** Enhanced Accessibility mode is disabled
   - **When** I view any component
   - **Then** standard accessibility sizes apply (44-60pt as per Stories 5.1-5.4)

## Tasks / Subtasks

- [x] Task 1: Extend AccessibilitySettings model (AC: 1-5)
  - [x] 1.1: Add computed properties for conditional sizing
  - [x] 1.2: Add `chipHeight: CGFloat` property (80 vs 60)
  - [x] 1.3: Add `buttonHeight: CGFloat` property (80 vs 60)
  - [x] 1.4: Add `headerButtonSize: CGFloat` property (60 vs 44)
  - [x] 1.5: Add `primaryButtonHeight: CGFloat` property (100 vs 80)
  - [x] 1.6: Add `tertiaryButtonHeight: CGFloat` property (60 vs 50)

- [x] Task 2: Update KeywordChipsView (AC: 1, 5)
  - [x] 2.1: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 2.2: Replace hardcoded `minHeight: 60` with `accessibilitySettings.chipHeight`
  - [x] 2.3: Verify standard mode still uses 60pt

- [x] Task 3: Update GuidanceControlsView (AC: 2, 5)
  - [x] 3.1: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 3.2: Replace hardcoded `minHeight: 60` with `accessibilitySettings.buttonHeight`
  - [x] 3.3: Verify standard mode still uses 60pt

- [x] Task 4: Update GuidanceContextModal (AC: 2, 5)
  - [x] 4.1: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 4.2: Replace hardcoded `minHeight: 100` with conditional sizing (120 vs 100)
  - [x] 4.3: Replace close button `minHeight: 60` with `accessibilitySettings.buttonHeight`
  - [x] 4.4: Ensure AccessibilitySettings is injected in fullScreenCover presentation

- [x] Task 5: Update SuggestionView (AC: 3, 5)
  - [x] 5.1: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 5.2: Replace refresh button frame `width: 44, height: 44` with conditional sizing
  - [x] 5.3: Replace dismiss button frame `width: 44, height: 44` with conditional sizing
  - [x] 5.4: Replace "Autre" button `minHeight: 44` with conditional sizing
  - [x] 5.5: Add increased padding to SuggestionCard when Enhanced Mode enabled

- [x] Task 6: Update ControlButtonsView sidebar (AC: 4, 5)
  - [x] 6.1: Already has `@EnvironmentObject var accessibilitySettings`
  - [x] 6.2: Update SpeakControlButton to use `accessibilitySettings.primaryButtonHeight` (100 vs 80)
  - [x] 6.3: Update CompactRepeatButton to use `accessibilitySettings.buttonHeight` (80 vs 60)
  - [x] 6.4: Update CompactClearButton to use `accessibilitySettings.buttonHeight` (80 vs 60)
  - [x] 6.5: Update "Mes phrases" button to use `accessibilitySettings.tertiaryButtonHeight` (60 vs 50)
  - [x] 6.6: Update "Paramètres" button to use `accessibilitySettings.tertiaryButtonHeight` (60 vs 50)

- [x] Task 7: Update button components with AccessibilitySettings (AC: 4)
  - [x] 7.1: Add `accessibilitySettings` parameter to SpeakControlButton
  - [x] 7.2: Add `accessibilitySettings` parameter to CompactRepeatButton
  - [x] 7.3: Add `accessibilitySettings` parameter to CompactClearButton
  - [x] 7.4: Pass AccessibilitySettings from ControlButtonsView to child components

- [x] Task 8: Testing
  - [x] 8.1: Build succeeds without errors
  - [x] 8.2: Toggle Enhanced Mode ON and verify all buttons are 80pt
  - [x] 8.3: Toggle Enhanced Mode OFF and verify standard sizes apply
  - [x] 8.4: Verify GuidanceContextModal receives AccessibilitySettings via environmentObject
  - [x] 8.5: Verify no runtime crashes when navigating all screens
  - [x] 8.6: Verify immediate reactivity - changes apply without restart

## Dev Notes

### Target Files

**File to modify:**

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift` - Add computed properties
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/KeywordChipsView.swift` - Add EnvironmentObject + conditional sizing
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift` - Add conditional sizing
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceContextModal.swift` - Add EnvironmentObject + conditional sizing
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift` - Add EnvironmentObject + conditional sizing
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift` - Update button components + pass AccessibilitySettings

### AccessibilitySettings Extension

Add these computed properties to the existing `AccessibilitySettings` model:

```swift
// MARK: - Story 7.2: Conditional Touch Target Sizes

/// Story 7.2 AC1: Keyword chip height (80pt enhanced, 60pt standard)
var chipHeight: CGFloat {
    isEnhancedModeEnabled ? 80 : 60
}

/// Story 7.2 AC2, AC4: Standard button height (80pt enhanced, 60pt standard)
var buttonHeight: CGFloat {
    isEnhancedModeEnabled ? 80 : 60
}

/// Story 7.2 AC3: Header button size (60pt enhanced, 44pt standard)
var headerButtonSize: CGFloat {
    isEnhancedModeEnabled ? 60 : 44
}

/// Story 7.2 AC4: Primary PARLER button height (100pt enhanced, 80pt standard)
var primaryButtonHeight: CGFloat {
    isEnhancedModeEnabled ? 100 : 80
}

/// Story 7.2 AC4: Tertiary button height (60pt enhanced, 50pt standard)
var tertiaryButtonHeight: CGFloat {
    isEnhancedModeEnabled ? 60 : 50
}

/// Story 7.2 AC2: Modal button height (120pt enhanced, 100pt standard)
var modalButtonHeight: CGFloat {
    isEnhancedModeEnabled ? 120 : 100
}
```

### KeywordChipsView Modification

```swift
@MainActor
struct KeywordChipsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared
    @EnvironmentObject var speechService: SpeechService
    // Story 7.2: Add accessibility settings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // ... existing code ...
}

// In KeywordChip body:
.frame(minHeight: accessibilitySettings.chipHeight)  // Story 7.2 AC1
```

### GuidanceControlsView Modification

```swift
@MainActor
struct GuidanceControlsView: View {
    @ObservedObject private var suggestionService = SuggestionService.shared
    // Story 7.2: Add accessibility settings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // ... in dropdown button:
    .frame(minHeight: accessibilitySettings.buttonHeight)  // Story 7.2 AC2

    // ... in fullScreenCover:
    .fullScreenCover(isPresented: $showContextModal) {
        GuidanceContextModal(...)
            .environmentObject(accessibilitySettings)  // Story 7.2: Inject settings
    }
}
```

### GuidanceContextModal Modification

```swift
@MainActor
struct GuidanceContextModal: View {
    // Story 7.2: Add accessibility settings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // ... in close button:
    .frame(minHeight: accessibilitySettings.buttonHeight)  // Story 7.2 AC2
}

@MainActor
struct GuidanceContextButton: View {
    // Story 7.2: Add accessibility settings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // ... in body:
    .frame(minWidth: 150, minHeight: accessibilitySettings.modalButtonHeight)  // Story 7.2 AC2
}
```

### SuggestionView Modification

```swift
@MainActor
struct SuggestionView: View {
    // ... existing properties ...
    // Story 7.2: Add accessibility settings for conditional sizing
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    // In headerView refresh button:
    .frame(width: accessibilitySettings.headerButtonSize,
           height: accessibilitySettings.headerButtonSize)  // Story 7.2 AC3

    // In headerView dismiss button:
    .frame(width: accessibilitySettings.headerButtonSize,
           height: accessibilitySettings.headerButtonSize)  // Story 7.2 AC3

    // In "Autre" button:
    .frame(minHeight: accessibilitySettings.headerButtonSize)  // Story 7.2 AC3
}
```

### ControlButtonsView Button Components

Since button components are separate structs, they need AccessibilitySettings passed as parameter:

```swift
// Story 7.2: Add accessibilitySettings parameter to button components
@MainActor
struct SpeakControlButton: View {
    var text: String
    var isLoading: Bool
    var onSpeak: () -> Void
    var primaryButtonHeight: CGFloat  // Story 7.2: From AccessibilitySettings

    // In body:
    .frame(minWidth: 200, minHeight: primaryButtonHeight)  // Story 7.2 AC4
}

@MainActor
struct CompactRepeatButton: View {
    var lastText: String
    var isLoading: Bool
    var onRepeat: () -> Void
    var buttonHeight: CGFloat  // Story 7.2: From AccessibilitySettings

    // In body:
    .frame(minWidth: 95, minHeight: buttonHeight)  // Story 7.2 AC4
}

@MainActor
struct CompactClearButton: View {
    @Binding var recognizedText: String
    @Binding var speakTask: Task<Void, Never>?
    var isLoading: Bool
    var buttonHeight: CGFloat  // Story 7.2: From AccessibilitySettings

    // In body:
    .frame(minWidth: 95, minHeight: buttonHeight)  // Story 7.2 AC4
}
```

In ControlButtonsView, pass the values:

```swift
SpeakControlButton(
    text: recognizedText,
    isLoading: speechService.isLoading,
    onSpeak: { ... },
    primaryButtonHeight: accessibilitySettings.primaryButtonHeight  // Story 7.2
)

CompactRepeatButton(
    lastText: speechService.lastSpokenText,
    isLoading: speechService.isLoading,
    onRepeat: { ... },
    buttonHeight: accessibilitySettings.buttonHeight  // Story 7.2
)

CompactClearButton(
    recognizedText: $recognizedText,
    speakTask: $speakTask,
    isLoading: speechService.isLoading,
    buttonHeight: accessibilitySettings.buttonHeight  // Story 7.2
)
```

### Project Structure Notes

- **File locations follow existing patterns**: Views/ for SwiftUI views, Models/ for data models
- **No external dependencies**: Use native SwiftUI
- **Follow @MainActor pattern**: All views use @MainActor
- **French localization**: All user-facing text remains in French (no changes needed)
- **EnvironmentObject injection**: AccessibilitySettings already injected from App entry point

### References

- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift] - Model to extend
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/KeywordChipsView.swift:109] - Current minHeight: 60
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift:58] - Current minHeight: 60
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceContextModal.swift:79,138] - Modal button sizes
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift:156,170,189] - Header button sizes
- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift:51,99,143] - Sidebar button sizes
- [Source: _bmad-output/planning-artifacts/epics-ux-accessibility.md#Story 3.2] - Original requirements

### Previous Story Intelligence

**From Story 7.1 implementation:**

- AccessibilitySettings model uses `ObservableObject` pattern (iOS 16+ compatible)
- `isEnhancedModeEnabled` property with UserDefaults persistence
- Already injected as `@EnvironmentObject` from App entry point
- ControlButtonsView already has `@EnvironmentObject var accessibilitySettings`
- Pattern: Add `@EnvironmentObject` to views, use computed properties for sizing

**From Stories 5.1-5.4 implementation:**

- Standard touch targets: 60pt for chips/buttons, 44pt for header buttons
- ScaleButtonStyle used for all interactive buttons
- Haptic feedback: `.medium` for actions, `.light` for navigation
- French accessibility labels required on all interactive elements

### Git Intelligence

**Recent relevant commits:**

- `65c9aaa` - Story 7.1: Accessibility Settings Screen with Enhanced Mode
- `844c3c2` - Story 5.4: Grid layout pattern
- `1225053` - Story 5.3: Enlarged header buttons (44pt)
- `db88ad6` - Stories 5-1, 5-2: Touch target accessibility (60pt)

**Established patterns:**

- Inline comments reference Story ID and AC numbers
- Computed properties for conditional values
- @EnvironmentObject for shared state

### WARNING: Code Review Traps to Avoid

Based on previous code reviews:

1. **DO NOT forget to inject AccessibilitySettings** via `.environmentObject()` in fullScreenCover/sheet presentations
2. **DO NOT use hardcoded values** - Use computed properties from AccessibilitySettings
3. **DO NOT break existing functionality** - Standard mode must still work with original sizes
4. **DO NOT forget @EnvironmentObject declaration** in views that use accessibilitySettings
5. **DO NOT modify button components** without updating all call sites with new parameters
6. **DO NOT use iOS 17-only features** - Project targets iOS 16.0+
7. **DO NOT change behavior** - Only sizes change, all interactions remain the same
8. **DO NOT forget to test both modes** - Enhanced ON and OFF

### Current Component Size Reference

| Component | Standard Mode | Enhanced Mode | AC |
|-----------|--------------|---------------|-----|
| KeywordChip | 60pt | 80pt | AC1 |
| GuidanceControlsView dropdown | 60pt | 80pt | AC2 |
| GuidanceContextButton (modal) | 100pt | 120pt | AC2 |
| Modal close button | 60pt | 80pt | AC2 |
| SuggestionView refresh | 44pt | 60pt | AC3 |
| SuggestionView dismiss | 44pt | 60pt | AC3 |
| SuggestionView "Autre" | 44pt | 60pt | AC3 |
| PARLER button | 80pt | 100pt | AC4 |
| Répéter/Effacer | 60pt | 80pt | AC4 |
| Mes phrases/Paramètres | 50pt | 60pt | AC4 |

### Related Stories

- **Story 7.1:** Create Accessibility Settings Screen with Enhanced Mode (DONE - provides isEnhancedModeEnabled)
- **Story 7.3:** Implement high contrast and reduced animations (NEXT - visual changes)
- **Story 7.4:** Add confirmation dialogs for destructive actions (behavioral changes)

This story only implements size changes when Enhanced Mode is enabled. Visual and behavioral changes are in subsequent stories.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build verification: `xcodebuild` completed with BUILD SUCCEEDED

### Completion Notes List

- All 6 computed properties added to AccessibilitySettings model (chipHeight, buttonHeight, headerButtonSize, primaryButtonHeight, tertiaryButtonHeight, modalButtonHeight)
- KeywordChipsView, GuidanceControlsView, GuidanceContextModal, SuggestionView updated with @EnvironmentObject
- Button components (SpeakControlButton, CompactRepeatButton, CompactClearButton) modified to accept height parameters instead of EnvironmentObject (cleaner pattern for separate structs)
- AccessibilitySettings properly injected via .environmentObject() in fullScreenCover presentations
- SuggestionCard uses computed padding based on headerButtonSize for conditional padding
- All acceptance criteria met: Enhanced mode (80pt+) and standard mode (60pt) sizes work correctly

### Code Review Fixes Applied

**M1 Fix (Process):** Note - GuidanceContextModal.swift was created in Story 6.1 but uncommitted. This story modified it further. All changes (6.1 + 7.2) remain uncommitted together.

**M2 Fix (Documentation):** Added sprint-status.yaml to File List (was modified but not documented).

**M3 Fix (Testing):** Created AccessibilitySettingsTests.swift with comprehensive unit tests for all computed properties and mode transitions.

**L1 Fix (Code Quality):** Extracted magic numbers from SuggestionCard padding calculation to `cardPadding` computed property in AccessibilitySettings.

**L2 Fix (Code Quality):** Added #Preview blocks to GuidanceControlsView.swift and GuidanceContextModal.swift for Xcode Canvas testing.

### File List

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift` - Added 7 computed properties for conditional sizing (including cardPadding from L1 Fix)
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/KeywordChipsView.swift` - Added @EnvironmentObject, conditional chipHeight
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift` - Added @EnvironmentObject, conditional buttonHeight, environmentObject injection, #Preview (L2 Fix)
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceContextModal.swift` - Added @EnvironmentObject, modalButtonHeight parameter, conditional close button, #Preview (L2 Fix)
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift` - Added @EnvironmentObject, headerButtonSize + cardPadding for all header buttons and suggestion cards (L1 Fix)
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift` - Added height parameters to button components, updated all call sites
- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUITests/AccessibilitySettingsTests.swift` - NEW: Unit tests for AccessibilitySettings (M3 Fix)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` - Status tracking (M2 Fix: was modified but not documented)
