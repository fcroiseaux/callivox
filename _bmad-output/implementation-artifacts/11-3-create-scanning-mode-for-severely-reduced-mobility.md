# Story 11.3: Create Scanning Mode for Severely Reduced Mobility

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with severely reduced mobility,
I want a scanning mode where buttons highlight sequentially,
So that I can select options with a single tap or switch input.

## Acceptance Criteria

1. **AC1 - Settings Toggle**
   - Given I am in the accessibility settings
   - When I view advanced options
   - Then I see a "Mode Scanning" toggle with description:
     "Les boutons s'illuminent tour à tour. Tapez pour sélectionner."

2. **AC2 - Sequential Highlighting**
   - Given scanning mode is enabled
   - When I view any button group (keywords, phrases, suggestions)
   - Then buttons are highlighted one by one in sequence
   - And the highlight is a clear visual indicator (bright border, scale effect)
   - And each button is highlighted for a configurable duration (default: 2 seconds)

3. **AC3 - Selection Mechanism**
   - Given scanning mode is active and a button is highlighted
   - When I tap anywhere on the screen
   - Then the currently highlighted button is activated
   - And the action is performed (TTS, navigation, etc.)
   - And scanning pauses briefly then resumes from the next button

4. **AC4 - Pause/Resume Behavior**
   - Given scanning mode is active
   - When I do not tap during a full scan cycle
   - Then scanning pauses after completing the cycle
   - And tapping anywhere restarts the scan

5. **AC5 - Works in Emergency/Fatigue Modes**
   - Given scanning mode is enabled
   - When I view the emergency panel or fatigue mode
   - Then scanning also works in these modes
   - And buttons are scanned in logical order (top to bottom, left to right)

## Tasks / Subtasks

- [x] Task 1: Create ScanningModeSettings Manager (AC: 1, 2)
  - [x] 1.1: Create `ScanningModeSettings.swift` in `Managers/` folder
  - [x] 1.2: Add `@MainActor class ScanningModeSettings: ObservableObject` with singleton `static let shared`
  - [x] 1.3: Add `@Published var isEnabled: Bool` with UserDefaults persistence key `com.callivox.scanning_mode_enabled`
  - [x] 1.4: Add `@Published var scanSpeed: ScanSpeed` enum (.slow = 3s, .medium = 2s, .fast = 1s)
  - [x] 1.5: Add `@Published var autoRestart: Bool` (default: true)
  - [x] 1.6: Add `@Published var soundFeedbackEnabled: Bool` (default: false) - for Story 11.4
  - [x] 1.7: Create `ScanSpeed` enum with `rawValue: TimeInterval` and French display names
  - [x] 1.8: Implement persistence with JSONEncoder/Decoder for complex types
  - [x] 1.9: Add `resetToDefaults()` method

- [x] Task 2: Create ScanningModeController (AC: 2, 3, 4)
  - [x] 2.1: Create `ScanningModeController.swift` in `Managers/` folder
  - [x] 2.2: Add `@MainActor class ScanningModeController: ObservableObject` with singleton `static let shared`
  - [x] 2.3: Add `@Published var currentHighlightedIndex: Int?` - nil when paused
  - [x] 2.4: Add `@Published var isScanning: Bool` - tracks active scanning state
  - [x] 2.5: Add `@Published var isPaused: Bool` - tracks post-cycle pause
  - [x] 2.6: Add `private var scanTimer: Timer?` for cycle management
  - [x] 2.7: Add `private var itemCount: Int` - total scannable items in current group
  - [x] 2.8: Implement `startScanning(itemCount: Int)` - begins scan cycle
  - [x] 2.9: Implement `stopScanning()` - stops timer, resets state
  - [x] 2.10: Implement `selectCurrentItem() -> Int?` - returns selected index, pauses, resumes
  - [x] 2.11: Implement `resumeScanning()` - restart after pause
  - [x] 2.12: Implement timer-based `advanceHighlight()` with wrap-around logic
  - [x] 2.13: Add AC4 logic: pause after full cycle if no selection

- [x] Task 3: Create ScanningHighlightModifier (AC: 2)
  - [x] 3.1: Create `ScanningHighlightModifier.swift` in `Views/` folder
  - [x] 3.2: Create `struct ScanningHighlightModifier: ViewModifier`
  - [x] 3.3: Add parameters: `index: Int`, `isHighlighted: Bool`
  - [x] 3.4: Implement highlight effect: bright border (4pt, Color.yellow), scale(1.05)
  - [x] 3.5: Add animation: `.easeInOut(duration: 0.2)` for smooth transitions
  - [x] 3.6: Create extension `View.scanningHighlight(index:isHighlighted:)`
  - [x] 3.7: Apply `accessibilityFocused` when highlighted for VoiceOver support

- [x] Task 4: Create ScannableContainer View (AC: 2, 3)
  - [x] 4.1: Create `ScannableContainer.swift` in `Views/` folder
  - [x] 4.2: Create `struct ScannableContainer<Content: View>: View` generic wrapper
  - [x] 4.3: Accept `items: [Any]` count and `content: () -> Content` builder
  - [x] 4.4: Add tap gesture covering entire container for AC3 selection
  - [x] 4.5: Connect to `ScanningModeController.shared` for state
  - [x] 4.6: Start/stop scanning on appear/disappear based on `ScanningModeSettings.shared.isEnabled`
  - [x] 4.7: Propagate `currentHighlightedIndex` via environment or binding

- [x] Task 5: Integrate into AccessibilitySettingsView (AC: 1)
  - [x] 5.1: Add new Section "Mode Scanning" after existing sections
  - [x] 5.2: Add Toggle for `ScanningModeSettings.shared.isEnabled`
  - [x] 5.3: Add description text: "Les boutons s'illuminent tour à tour. Tapez pour sélectionner."
  - [x] 5.4: Add NavigationLink to ScanningModeSettingsView (for Story 11.4 configuration)
  - [x] 5.5: Apply `accessibilitySettings.buttonHeight` for minimum heights
  - [x] 5.6: Add French VoiceOver labels and hints

- [x] Task 6: Integrate Scanning into KeywordChipsView (AC: 2, 3)
  - [x] 6.1: Wrap keyword grid in `ScannableContainer`
  - [x] 6.2: Apply `scanningHighlight(index:isHighlighted:)` to each chip
  - [x] 6.3: Handle selection: activate TTS for highlighted keyword
  - [x] 6.4: Maintain existing non-scanning tap behavior when disabled

- [x] Task 7: Integrate Scanning into FatigueModeView (AC: 5)
  - [x] 7.1: Wrap message buttons in `ScannableContainer`
  - [x] 7.2: Apply `scanningHighlight` to each `FatigueModeButton`
  - [x] 7.3: Handle selection: speak highlighted message
  - [x] 7.4: Include "Mode normal" exit button in scan cycle

- [x] Task 8: Integrate Scanning into EmergencyPanelView (AC: 5)
  - [x] 8.1: Wrap emergency buttons in `ScannableContainer`
  - [x] 8.2: Apply `scanningHighlight` to each emergency button
  - [x] 8.3: Handle selection: speak highlighted emergency message
  - [x] 8.4: Include close button in scan cycle

- [x] Task 9: Unit Tests
  - [x] 9.1: Test ScanningModeSettings persistence to UserDefaults
  - [x] 9.2: Test ScanSpeed enum rawValue conversions
  - [x] 9.3: Test ScanningModeController startScanning/stopScanning
  - [x] 9.4: Test advanceHighlight wraps around correctly
  - [x] 9.5: Test selectCurrentItem returns correct index
  - [x] 9.6: Test pause after full cycle behavior (AC4)
  - [x] 9.7: Test resumeScanning after pause

## Dev Notes

### Critical Architecture Decision: Centralized Scanning Controller

Unlike previous accessibility features (fatigue mode, time-based phrases), scanning mode requires **coordinated state across multiple views**. The architecture uses:

1. **ScanningModeSettings** - Persistent configuration (like other settings managers)
2. **ScanningModeController** - Runtime state machine managing the active scan cycle

This separation ensures:
- Settings persist across sessions
- Controller resets on each scannable container appear
- Multiple containers don't interfere (only one active at a time)

### Timer-Based Scanning Implementation

```swift
// MARK: - ScanningModeController Core Logic

@MainActor
class ScanningModeController: ObservableObject {
    static let shared = ScanningModeController()

    @Published var currentHighlightedIndex: Int?
    @Published var isScanning: Bool = false
    @Published var isPaused: Bool = false

    private var scanTimer: Timer?
    private var itemCount: Int = 0
    private var cycleCompleted: Bool = false

    private var settings: ScanningModeSettings { ScanningModeSettings.shared }

    func startScanning(itemCount: Int) {
        guard settings.isEnabled, itemCount > 0 else { return }

        self.itemCount = itemCount
        currentHighlightedIndex = 0
        isScanning = true
        isPaused = false
        cycleCompleted = false

        startTimer()
    }

    func stopScanning() {
        scanTimer?.invalidate()
        scanTimer = nil
        currentHighlightedIndex = nil
        isScanning = false
        isPaused = false
    }

    private func startTimer() {
        scanTimer?.invalidate()
        scanTimer = Timer.scheduledTimer(
            withTimeInterval: settings.scanSpeed.interval,
            repeats: true
        ) { [weak self] _ in
            Task { @MainActor in
                self?.advanceHighlight()
            }
        }
    }

    private func advanceHighlight() {
        guard isScanning, !isPaused, let current = currentHighlightedIndex else { return }

        let next = current + 1
        if next >= itemCount {
            // AC4: Full cycle completed
            if settings.autoRestart {
                currentHighlightedIndex = 0
            } else {
                cycleCompleted = true
                isPaused = true
                scanTimer?.invalidate()
            }
        } else {
            currentHighlightedIndex = next
        }
    }

    /// AC3: Returns selected index and manages pause/resume
    func selectCurrentItem() -> Int? {
        guard let index = currentHighlightedIndex else { return nil }

        // Brief pause before resuming
        scanTimer?.invalidate()

        // Resume after 0.5s delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self, self.isScanning else { return }
            let nextIndex = (index + 1) % self.itemCount
            self.currentHighlightedIndex = nextIndex
            self.startTimer()
        }

        return index
    }

    /// AC4: Resume after pause
    func resumeScanning() {
        guard isPaused else { return }
        isPaused = false
        currentHighlightedIndex = 0
        startTimer()
    }
}
```

### ScanningHighlightModifier Pattern

```swift
// MARK: - Visual Highlight Modifier

struct ScanningHighlightModifier: ViewModifier {
    let index: Int
    let isHighlighted: Bool

    func body(content: Content) -> some View {
        content
            // AC2: Bright border highlight
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHighlighted ? Color.yellow : Color.clear, lineWidth: 4)
            )
            // AC2: Scale effect for visibility
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            // VoiceOver focus when highlighted
            .accessibilityAddTraits(isHighlighted ? .isSelected : [])
    }
}

extension View {
    func scanningHighlight(index: Int, highlightedIndex: Int?) -> some View {
        modifier(ScanningHighlightModifier(
            index: index,
            isHighlighted: index == highlightedIndex
        ))
    }
}
```

### ScannableContainer Generic Wrapper

```swift
// MARK: - Scannable Container

struct ScannableContainer<Content: View>: View {
    let itemCount: Int
    let onSelect: (Int) -> Void
    @ViewBuilder let content: (Int?) -> Content  // Receives highlighted index

    @ObservedObject private var controller = ScanningModeController.shared
    @ObservedObject private var settings = ScanningModeSettings.shared

    var body: some View {
        content(controller.currentHighlightedIndex)
            .contentShape(Rectangle())  // Entire area tappable
            .onTapGesture {
                if settings.isEnabled {
                    if controller.isPaused {
                        // AC4: Resume from pause
                        controller.resumeScanning()
                    } else if let selectedIndex = controller.selectCurrentItem() {
                        // AC3: Activate selected item
                        onSelect(selectedIndex)
                    }
                }
            }
            .onAppear {
                if settings.isEnabled {
                    controller.startScanning(itemCount: itemCount)
                }
            }
            .onDisappear {
                controller.stopScanning()
            }
            .onChange(of: settings.isEnabled) { _, newValue in
                if newValue {
                    controller.startScanning(itemCount: itemCount)
                } else {
                    controller.stopScanning()
                }
            }
    }
}
```

### ScanSpeed Enum

```swift
// MARK: - ScanSpeed Configuration

enum ScanSpeed: String, CaseIterable, Codable {
    case slow = "slow"
    case medium = "medium"
    case fast = "fast"

    var interval: TimeInterval {
        switch self {
        case .slow: return 3.0
        case .medium: return 2.0
        case .fast: return 1.0
        }
    }

    var displayName: String {
        switch self {
        case .slow: return "Lent (3s)"
        case .medium: return "Moyen (2s)"
        case .fast: return "Rapide (1s)"
        }
    }
}
```

### File Locations

| File | Directory | Purpose |
|------|-----------|---------|
| `ScanningModeSettings.swift` | `Managers/` | NEW - Persistent settings |
| `ScanningModeController.swift` | `Managers/` | NEW - Runtime scan state |
| `ScanningHighlightModifier.swift` | `Views/` | NEW - Visual highlight effect |
| `ScannableContainer.swift` | `Views/` | NEW - Generic wrapper |
| `AccessibilitySettingsView.swift` | `Views/` | MODIFY - Add toggle |
| `KeywordChipsView.swift` | `Views/` | MODIFY - Add scanning |
| `FatigueModeView.swift` | `Views/` | MODIFY - Add scanning |
| `EmergencyPanelView.swift` | `Views/` | MODIFY - Add scanning |
| `ScanningModeSettingsTests.swift` | `Tests/` | NEW - Combined unit tests (settings + controller) |

### UI Text (French)

| Context | Text |
|---------|------|
| Settings section header | "Mode Scanning" |
| Toggle label | "Activer le mode scanning" |
| Toggle description | "Les boutons s'illuminent tour à tour. Tapez pour sélectionner." |
| Configure link | "Configurer le scanning" |
| VoiceOver highlight | "Sélectionné" |
| VoiceOver scanning active | "Mode scanning actif. Tapez n'importe où pour sélectionner." |
| VoiceOver paused | "Scanning en pause. Tapez pour reprendre." |

### Accessibility Requirements

- VoiceOver must announce when scanning starts: "Mode scanning actif"
- VoiceOver must announce current item when highlighted
- VoiceOver must announce when paused: "Scanning en pause"
- All interactive elements maintain minimum heights (60pt/80pt)
- Haptic feedback: `.light` on highlight change, `.medium` on selection
- High contrast highlight border (yellow on any background)

### Project Structure Notes

- Alignment with unified project structure: New files follow existing patterns
- Pattern consistency: Settings manager follows FatigueModeSettings exactly
- Controller pattern: New concept for coordinated multi-view state
- No conflicts detected with existing code
- Minimal modification to existing views (wrap in ScannableContainer)

### References

- [Source: epics-ux-accessibility.md#Story-7.3-Create-Scanning-Mode-for-Severely-Reduced-Mobility]
- [Source: project-context.md#SwiftUI-Patterns]
- [Pattern: FatigueModeSettings.swift - Settings manager structure]
- [Pattern: FatigueModeView.swift - Full-screen mode integration point]
- [Pattern: AccessibilitySettings.swift - Published property pattern]
- [Pattern: EmergencyPanelView.swift - Button group to integrate]

### Testing Considerations

- Test Timer scheduling and invalidation (memory leaks)
- Test state transitions: idle → scanning → paused → resumed
- Test wrap-around at end of item list
- Test selection returns correct index
- Test pause after full cycle when autoRestart = false
- Test immediate resume when autoRestart = true
- Test container appear/disappear lifecycle
- Mock Timer in tests using protocol abstraction if needed

### Edge Cases to Handle

1. **Empty item list**: Don't start scanning if itemCount = 0
2. **Single item**: Highlight stays on single item, selection works
3. **Container disappears during scan**: Stop timer, reset state
4. **Settings change during scan**: Respond to isEnabled toggle
5. **Rapid taps**: Debounce selection to prevent double-activation
6. **Switch input devices**: External switches trigger same tap gesture
7. **Background/foreground**: Pause scanning when app backgrounds

### Previous Story (11.2) Learnings Applied

From Story 11.2 code review:
- **M1**: Match actual behavior in display strings
- **M2**: Use iOS 17+ onChange syntax (zero-parameter closure)
- **M3**: Correct comments about didSet/init behavior
- **M4**: Test edge cases (invalid inputs, boundaries)
- **L1**: Add DispatchQueue.main.asyncAfter delay for VoiceOver announcements
- **L2**: Avoid redundant saves (immediate save pattern)
- **L3**: Accessibility values for state description
- **L4**: Explicit 44pt frame constraints on interactive elements

### Implementation Order Recommendation

1. **Phase 1**: Core infrastructure (Tasks 1-4)
   - ScanningModeSettings
   - ScanningModeController
   - ScanningHighlightModifier
   - ScannableContainer

2. **Phase 2**: Settings integration (Task 5)
   - AccessibilitySettingsView toggle

3. **Phase 3**: View integrations (Tasks 6-8)
   - KeywordChipsView (primary test target)
   - FatigueModeView
   - EmergencyPanelView

4. **Phase 4**: Testing (Task 9)
   - Unit tests for settings and controller
   - Integration testing with actual UI

### Story 11.4 Preparation

This story creates the foundation for **Story 11.4: Configure Scanning Mode Settings**. The `ScanningModeSettings` manager already includes placeholders for:
- `scanSpeed` (configurable in 11.4)
- `soundFeedbackEnabled` (configurable in 11.4)
- `autoRestart` (configurable in 11.4)

Story 11.4 will add `ScanningModeSettingsView` for user configuration of these parameters.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

None - Implementation completed without blocking issues.

### Completion Notes List

- **Architecture Decision**: Implemented two-component architecture (ScanningModeSettings + ScanningModeController) for coordinated multi-view state management
- **Learning Applied**: Used iOS 17+ onChange syntax, VoiceOver announcement delays (L1), prepared haptic generators
- **Edge Cases Handled**: Empty item list, single item, rapid taps (debounce), container disappear during scan
- **Story 11.4 Preparation**: Settings manager includes placeholders for scanSpeed, autoRestart, soundFeedbackEnabled

### Code Review 2026-01-28 (Adversarial Review)

**Reviewer**: Claude Opus 4.5 (Adversarial Senior Developer)
**Build Status**: SUCCEEDED

Issues found and fixed:

| ID | Severity | File | Issue | Status |
|----|----------|------|-------|--------|
| M1 | MEDIUM | ScannableContainer.swift | iOS 14 onChange syntax with `{ _, newValue in }` instead of iOS 17+ zero-parameter | FIXED |
| M2 | MEDIUM | ScanningModeController.swift | Redundant `Task { @MainActor in }` wrapper in Timer callback (class already @MainActor) | FIXED |
| M3 | MEDIUM | ScanningModeSettingsTests.swift | Tests use shared singletons causing state pollution between tests | NOT FIXED (requires major refactoring for DI) |
| M4 | MEDIUM | ScanningModeController.swift | SystemSoundID 1103 (Tock) too subtle, easily missed | FIXED - Changed to 1057 (Tink) |
| L1 | LOW | ScanningHighlightModifier.swift, KeywordChipsView.swift | cornerRadius hardcoded to 12, but KeywordChip uses 24 | FIXED - Made configurable with default 16 |

**Changes Applied**:
- `ScannableContainer.swift`: Updated `.onChange(of: settings.isEnabled) { _, newValue in` to zero-parameter iOS 17+ syntax
- `ScanningModeController.swift:startTimer()`: Removed `Task { @MainActor in }` wrapper, callback runs directly since class is @MainActor
- `ScanningModeController.swift:playHighlightSound()`: Changed `AudioServicesPlaySystemSound(1103)` to `1057`
- `ScanningHighlightModifier.swift`: Added `cornerRadius: CGFloat` parameter with default value of 16
- `KeywordChipsView.swift`: Updated `.scanningHighlight()` call to pass `cornerRadius: 24`

### File List

**New Files Created:**
- `HandwritingToSpeechSwiftUI/Managers/ScanningModeSettings.swift` - Persistent settings manager
- `HandwritingToSpeechSwiftUI/Managers/ScanningModeController.swift` - Runtime scan cycle controller
- `HandwritingToSpeechSwiftUI/Views/ScanningHighlightModifier.swift` - Visual highlight effect
- `HandwritingToSpeechSwiftUI/Views/ScannableContainer.swift` - Generic scannable wrapper
- `HandwritingToSpeechSwiftUITests/ScanningModeSettingsTests.swift` - Combined unit tests

**Modified Files:**
- `HandwritingToSpeechSwiftUI/Views/AccessibilitySettingsView.swift` - Added Mode Scanning section
- `HandwritingToSpeechSwiftUI/Views/KeywordChipsView.swift` - Wrapped grid in ScannableContainer
- `HandwritingToSpeechSwiftUI/Views/FatigueModeView.swift` - Wrapped buttons in ScannableContainer
- `HandwritingToSpeechSwiftUI/Views/EmergencyPanelView.swift` - Wrapped buttons in ScannableContainer
- `_bmad-output/implementation-artifacts/sprint-status.yaml` - Status updated to done

### Change Log

- 2026-01-28: Story 11.3 implemented - Scanning mode for severely reduced mobility
- 2026-01-28: Adversarial code review fixes applied (4/5 issues: M1, M2, M4, L1)

