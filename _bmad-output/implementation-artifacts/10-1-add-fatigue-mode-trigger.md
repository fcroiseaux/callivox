# Story 10.1: Add Fatigue Mode Trigger

Status: done

## Story

As a user experiencing high fatigue,
I want an easy way to switch to a simplified interface mode,
So that I can still communicate when I have very limited energy.

## Acceptance Criteria

1. **AC1 - Sidebar Button Visibility**
   **Given** I am on the main screen
   **When** I view the sidebar (ControlButtonsView)
   **Then** a "Mode Fatigue" button is visible in the actions section
   **And** the button shows a clear icon (moon.zzz symbol) with label "Mode Fatigue"
   **And** the button is minimum 60pt height in standard mode

2. **AC2 - Accessibility Settings Section**
   **Given** I am in the accessibility settings (AccessibilitySettingsView)
   **When** I view the options
   **Then** I see a "Mode Fatigue" section with:
   - Toggle to enable/disable fatigue mode directly
   - NavigationLink to configure which messages appear in fatigue mode
   **And** each control is minimum 60pt height

3. **AC3 - Enhanced Mode Sizing**
   **Given** Enhanced Accessibility mode is enabled
   **When** I view the fatigue mode button in the sidebar
   **Then** the button is minimum 80pt height

## Tasks / Subtasks

- [x] Task 1: Extend AccessibilitySettings model (AC: #2)
  - [x] 1.1 Add `isFatigueModeEnabled` @Published property with UserDefaults persistence
  - [x] 1.2 Add UserDefaults key constant `fatigue_mode_enabled`
  - [x] 1.3 Load persisted state in init() (default: false)

- [x] Task 2: Add fatigue mode button to ControlButtonsView (AC: #1, #3)
  - [x] 2.1 Add @State property `showFatigueModeView: Bool = false`
  - [x] 2.2 Create button below "Mes phrases" with moon.zzz icon and "Mode Fatigue" label
  - [x] 2.3 Apply conditional height: `accessibilitySettings.fatigueModeButtonHeight` (60pt standard, 80pt enhanced - created new computed property per AC requirements)
  - [x] 2.4 Style with orange/amber gradient background to indicate "rest" mode
  - [x] 2.5 Add haptic feedback (.light for navigation)
  - [x] 2.6 Add French accessibility labels: label="Mode Fatigue", hint="Active l'interface simplifiée pour la fatigue"

- [x] Task 3: Add fatigue mode section to AccessibilitySettingsView (AC: #2)
  - [x] 3.1 Create new Section with header "Mode Fatigue"
  - [x] 3.2 Add Toggle for `accessibilitySettings.isFatigueModeEnabled` with descriptive label
  - [x] 3.3 Add NavigationLink to future FatigueModeSettingsView (placeholder destination for Story 10.3)
  - [x] 3.4 Apply minimum 60pt height to all controls
  - [x] 3.5 Add French accessibility labels
  - [x] 3.6 Add haptic feedback on toggle change

- [x] Task 4: Wire sidebar button to toggle fatigue mode (AC: #1)
  - [x] 4.1 Button action sets `accessibilitySettings.isFatigueModeEnabled = true`
  - [x] 4.2 Present FatigueModeView fullScreenCover (placeholder for Story 10.2)
  - [x] 4.3 Store state for fullScreenCover presentation

## Dev Notes

### Architecture Patterns to Follow

- **ObservableObject pattern**: All state in `AccessibilitySettings` class with `@MainActor` annotation
- **UserDefaults persistence**: Use `didSet` on @Published properties (see existing `isEnhancedModeEnabled` pattern)
- **EnvironmentObject injection**: AccessibilitySettings injected via `.environmentObject(accessibilitySettings)`
- **Conditional sizing**: Use computed properties returning CGFloat based on `isEnhancedModeEnabled`

### Button Styling Pattern (from ControlButtonsView)

```swift
Button(action: {
    let impact = UIImpactFeedbackGenerator(style: .light)
    impact.impactOccurred()
    // action here
}) {
    HStack {
        Image(systemName: "moon.zzz")
            .font(.system(size: 18))
        Text("Mode Fatigue")
            .font(.title3)
            .fontWeight(.medium)
    }
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .frame(minHeight: accessibilitySettings.fatigueModeButtonHeight)
    .background(
        LinearGradient(
            gradient: Gradient(colors: [Color.orange, Color.orange.opacity(0.8)]),
            startPoint: .top,
            endPoint: .bottom
        )
    )
    .cornerRadius(10)
}
.buttonStyle(ScaleButtonStyle(
    scaleAmount: accessibilitySettings.scaleAnimationAmount,
    pressedColor: .clear,
    normalColor: .clear,
    animationDuration: accessibilitySettings.animationDuration
))
.accessibilityLabel("Mode Fatigue")
.accessibilityHint("Active l'interface simplifiée pour la fatigue")
```

### AccessibilitySettings Extension Pattern

```swift
// In AccessibilitySettings.swift

// Add constant
private static let fatigueModeKey = "fatigue_mode_enabled"

// Add property
@Published var isFatigueModeEnabled: Bool {
    didSet {
        UserDefaults.standard.set(isFatigueModeEnabled, forKey: Self.fatigueModeKey)
    }
}

// Update init()
self.isFatigueModeEnabled = UserDefaults.standard.bool(forKey: Self.fatigueModeKey)
```

### Project Structure Notes

| File | Action | Location |
|------|--------|----------|
| AccessibilitySettings.swift | MODIFY | HandwritingToSpeechSwiftUI/Models/ |
| ControlButtonsView.swift | MODIFY | HandwritingToSpeechSwiftUI/Views/ |
| AccessibilitySettingsView.swift | MODIFY | HandwritingToSpeechSwiftUI/Views/ |

### Button Placement in Sidebar

Insert "Mode Fatigue" button **after** "Mes phrases" and **before** "Paramètres" to maintain logical grouping:
1. PARLER (primary action)
2. Répéter / Effacer (secondary actions)
3. Mes phrases (content access)
4. **Mode Fatigue (NEW)** - mode switch
5. Paramètres (settings)
6. User info (at bottom)

### Critical Constraints

- **No external dependencies** - Use native iOS APIs only
- **iOS 16.0+ minimum** - Use SwiftUI features compatible with iOS 16
- **French UI language** - All labels and accessibility hints in French
- **Haptic feedback required** - UIImpactFeedbackGenerator for all button actions

### References

- [Source: epics-ux-accessibility.md#Epic 6: Fatigue Mode]
- [Source: project-context.md#SwiftUI Patterns]
- [Source: ControlButtonsView.swift - existing button patterns]
- [Source: AccessibilitySettings.swift - state management pattern]
- [Source: AccessibilitySettingsView.swift - settings section pattern]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with 5 deprecation warnings (onChange API - existing pattern in project)

### Completion Notes List

- Task 1: Added `isFatigueModeEnabled` @Published property to AccessibilitySettings with UserDefaults persistence (key: `fatigue_mode_enabled`, default: false)
- Task 2: Added "Mode Fatigue" button to ControlButtonsView between "Mes phrases" and "Paramètres", with orange gradient, moon.zzz icon, haptic feedback, and French accessibility labels. Button height uses `fatigueModeButtonHeight` (60pt standard, 80pt enhanced) per AC requirements
- Task 3: Added "Mode Fatigue" section to AccessibilitySettingsView with toggle and NavigationLink to placeholder settings view
- Task 4: Sidebar button enables fatigue mode and presents FatigueModeViewPlaceholder (fullScreenCover)
- Added 5 unit tests for fatigue mode in AccessibilitySettingsTests.swift
- Created FatigueModeViewPlaceholder and FatigueModeSettingsPlaceholder as temporary views for Stories 10.2 and 10.3

### File List

- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Models/AccessibilitySettings.swift (MODIFIED)
- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift (MODIFIED)
- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift (MODIFIED)
- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUITests/AccessibilitySettingsTests.swift (MODIFIED)

## Code Review Record

### Review Date

2026-01-27

### Issues Found & Fixed

| ID | Severity | Description | Fix Applied |
|----|----------|-------------|-------------|
| H1 | HIGH | AC height requirements not met (50/60pt instead of 60/80pt) | Created `fatigueModeButtonHeight` computed property returning 60pt standard / 80pt enhanced |
| M1 | MEDIUM | Missing VoiceOver accessibilityValue on sidebar button | Added `.accessibilityValue()` for state awareness |
| M2 | MEDIUM | Fatigue mode state persists after closing view | Noted as intentional UX decision - no fix required |
| M3 | MEDIUM | Incomplete test cleanup (missing confirmation_dialogs_enabled key) | Added key to setUp/tearDown |
| L1 | LOW | Inconsistent haptic feedback style (.medium vs .light for navigation) | Changed exit button to .light |
| L2 | LOW | Missing ScaleButtonStyle on placeholder exit button | Added ScaleButtonStyle for consistency |
| L3 | LOW | Placeholder text contains story reference | Changed to "bientôt disponible" |

### Additional Tests Added

- `testFatigueModeButtonHeightStandardMode()` - Validates 60pt in standard mode (AC1)
- `testFatigueModeButtonHeightEnhancedMode()` - Validates 80pt in enhanced mode (AC3)

### Build Verification

- Build succeeded after all fixes applied
- All ACs now fully compliant
