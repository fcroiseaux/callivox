# Story 10.2: Create Minimal Fatigue Mode Interface

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with very limited energy,
I want an extremely simplified interface with only essential buttons,
So that I can communicate basic needs with minimal effort.

## Acceptance Criteria

1. **AC1 - Full-Screen Simplified Interface Activation**
   **Given** I activate fatigue mode (via sidebar button or accessibility setting)
   **When** the mode activates
   **Then** a full-screen simplified interface replaces the main view
   **And** the background is a calm, low-contrast color (dark/black with ~0.9 opacity)
   **And** maximum 6 buttons are displayed

2. **AC2 - Button Layout and Sizing**
   **Given** fatigue mode is active
   **When** I view the interface
   **Then** buttons are displayed in a single vertical column
   **And** each button is full-width with 100pt minimum height
   **And** text is large (.title or .largeTitle font)
   **And** only essential messages are shown:
   - "OUI"
   - "NON"
   - "APPELER"
   - "DOULEUR"
   - "SOIF / FAIM"
   - "Mode normal" (to exit)

3. **AC3 - Message Button TTS Action**
   **Given** fatigue mode is active
   **When** I tap a message button (OUI, NON, APPELER, DOULEUR, SOIF/FAIM)
   **Then** the message is spoken via TTS (SpeechService)
   **And** gentle haptic feedback confirms the action (.light style)
   **And** the interface remains in fatigue mode (no auto-dismiss)

4. **AC4 - Exit Confirmation**
   **Given** fatigue mode is active
   **When** I tap "Mode normal"
   **Then** a confirmation dialog appears: "Quitter le mode fatigue ?"
   **And** confirming returns to the standard interface
   **And** canceling keeps fatigue mode active

5. **AC5 - State Persistence Across Sessions**
   **Given** fatigue mode is active
   **When** the app is closed and reopened
   **Then** fatigue mode remains active (persisted via UserDefaults)
   **And** user returns directly to simplified interface

## Tasks / Subtasks

- [x] Task 1: Create FatigueModeView.swift (AC: #1, #2)
  - [x] 1.1 Create new file `FatigueModeView.swift` in Views/ directory
  - [x] 1.2 Implement full-screen ZStack with calm dark background (Color.black.opacity(0.9))
  - [x] 1.3 Create VStack with 6 message buttons in single vertical column
  - [x] 1.4 Apply full-width layout with 100pt minimum height per button
  - [x] 1.5 Use .largeTitle font for button text
  - [x] 1.6 Add horizontal padding (32pt) and vertical spacing (16pt)

- [x] Task 2: Implement message buttons with TTS (AC: #2, #3)
  - [x] 2.1 Create FatigueModeButton component with standard styling
  - [x] 2.2 Define 5 message constants: "OUI", "NON", "APPELER", "DOULEUR", "SOIF / FAIM"
  - [x] 2.3 Connect button actions to `speechService.speakText(message)`
  - [x] 2.4 Add UIImpactFeedbackGenerator (.light) on button tap
  - [x] 2.5 Add French accessibility labels for each button

- [x] Task 3: Implement exit button with confirmation (AC: #4)
  - [x] 3.1 Create "Mode normal" button with distinct styling (different color - gray)
  - [x] 3.2 Add @State for confirmation dialog: `showExitConfirmation: Bool`
  - [x] 3.3 Implement .alert() modifier with "Quitter le mode fatigue ?" title
  - [x] 3.4 Confirmation action: set `accessibilitySettings.isFatigueModeEnabled = false` and dismiss
  - [x] 3.5 Cancel action: close dialog, stay in fatigue mode

- [x] Task 4: Update ContentView for fatigue mode persistence (AC: #5)
  - [x] 4.1 Add @State for FatigueModeView presentation: `showFatigueModeFromPersistence: Bool`
  - [x] 4.2 Initialize from `accessibilitySettings.isFatigueModeEnabled` in onAppear
  - [x] 4.3 Add .fullScreenCover presentation for FatigueModeView
  - [x] 4.4 Inject environmentObjects: speechService, accessibilitySettings

- [x] Task 5: Replace FatigueModeViewPlaceholder in ControlButtonsView (AC: #1)
  - [x] 5.1 Update .fullScreenCover to present FatigueModeView instead of placeholder
  - [x] 5.2 Remove FatigueModeViewPlaceholder struct (dead code cleanup)
  - [x] 5.3 Update onDismiss handler to sync with accessibilitySettings state

- [x] Task 6: Add unit tests for fatigue mode (AC: #1-#5)
  - [x] 6.1 Test FatigueModeView renders 6 buttons
  - [x] 6.2 Test button accessibility labels are in French
  - [x] 6.3 Test state persistence toggle behavior

## Dev Notes

### Architecture Patterns to Follow

- **ObservableObject pattern**: Use existing `AccessibilitySettings` class with `@MainActor` annotation
- **UserDefaults persistence**: `isFatigueModeEnabled` already persisted in AccessibilitySettings (Story 10.1)
- **EnvironmentObject injection**: SpeechService and AccessibilitySettings via `.environmentObject()`
- **French UI language**: All labels, hints, and messages in French

### Button Styling Pattern (from existing codebase)

```swift
// FatigueModeButton - Large, full-width message button
@MainActor
struct FatigueModeButton: View {
    let message: String
    let backgroundColor: Color
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            Text(message)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 100)
                .background(backgroundColor)
                .cornerRadius(16)
        }
        .accessibilityLabel(message)
    }
}
```

### FatigueModeView Structure

```swift
@MainActor
struct FatigueModeView: View {
    @EnvironmentObject var speechService: SpeechService
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    let onDismiss: () -> Void

    @State private var showExitConfirmation: Bool = false

    // Message definitions (French)
    private let messages = [
        ("OUI", Color.green),
        ("NON", Color.red),
        ("APPELER", Color.blue),
        ("DOULEUR", Color.purple),
        ("SOIF / FAIM", Color.orange.opacity(0.9))
    ]

    var body: some View {
        ZStack {
            // AC1: Calm dark background
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Spacer()

                // AC2: Message buttons in single vertical column
                ForEach(messages, id: \.0) { message, color in
                    FatigueModeButton(
                        message: message,
                        backgroundColor: color,
                        onTap: { speakMessage(message) }
                    )
                }

                // AC4: Exit button with distinct styling
                FatigueModeButton(
                    message: "Mode normal",
                    backgroundColor: Color.gray,
                    onTap: { showExitConfirmation = true }
                )
                .accessibilityHint("Retourne à l'interface normale")

                Spacer()
            }
            .padding(.horizontal, 32)
        }
        // AC4: Exit confirmation dialog
        .alert("Quitter le mode fatigue ?", isPresented: $showExitConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Quitter", role: .destructive) {
                accessibilitySettings.isFatigueModeEnabled = false
                onDismiss()
            }
        }
    }

    // AC3: TTS action
    private func speakMessage(_ message: String) {
        speechService.speakText(message)
    }
}
```

### ContentView Integration Pattern

```swift
// In ContentView.swift - Add fatigue mode persistence check

@StateObject private var accessibilitySettings = AccessibilitySettings()
@State private var showFatigueModeFromPersistence: Bool = false

var body: some View {
    // ... existing content
    .onAppear {
        // AC5: Check persisted fatigue mode state on app launch
        showFatigueModeFromPersistence = accessibilitySettings.isFatigueModeEnabled
    }
    .fullScreenCover(isPresented: $showFatigueModeFromPersistence) {
        FatigueModeView(onDismiss: {
            showFatigueModeFromPersistence = false
        })
        .environmentObject(accessibilitySettings)
        .environmentObject(speechService)
    }
}
```

### Project Structure Notes

| File | Action | Location |
|------|--------|----------|
| FatigueModeView.swift | CREATE | HandwritingToSpeechSwiftUI/Views/ |
| ContentView.swift | MODIFY | HandwritingToSpeechSwiftUI/ |
| ControlButtonsView.swift | MODIFY | HandwritingToSpeechSwiftUI/Views/ |
| AccessibilitySettingsTests.swift | MODIFY | HandwritingToSpeechSwiftUITests/ |

### Critical Implementation Details

1. **State Persistence (AC5)**: `isFatigueModeEnabled` is already persisted via UserDefaults in AccessibilitySettings (Story 10.1). ContentView must check this state on `onAppear` to restore fatigue mode after app restart.

2. **TTS Integration (AC3)**: Use existing `SpeechService.speakText(_:)` method. SpeechService is already an ObservableObject with proper error handling.

3. **Button Height (AC2)**: Use fixed 100pt minimum height (not conditional on Enhanced Mode). Fatigue mode buttons are always extra-large.

4. **Color Scheme (AC1, AC2)**:
   - Background: `Color.black.opacity(0.9)` - calm, low-contrast
   - OUI: Green (positive action)
   - NON: Red (negative action)
   - APPELER: Blue (communication)
   - DOULEUR: Purple (health/medical)
   - SOIF / FAIM: Orange (needs)
   - Mode normal: Gray (navigation/exit)

5. **Haptic Feedback (AC3)**: Use `.light` style for gentle confirmation - fatigue mode should not be jarring.

6. **No ScaleButtonStyle**: For fatigue mode, avoid scale animations that might be distracting. Use simple pressed state or disable animations entirely.

### Previous Story Intelligence (Story 10.1)

**Learnings Applied:**
- `isFatigueModeEnabled` property already exists in AccessibilitySettings with proper persistence
- `fatigueModeButtonHeight` computed property exists for sidebar button (60pt/80pt conditional)
- `FatigueModeViewPlaceholder` exists and must be replaced/removed
- SpeechService and AccessibilitySettings injection pattern via `.environmentObject()` is established
- French accessibility labels pattern: `.accessibilityLabel()` and `.accessibilityHint()`

**Code Review Fixes from 10.1 to Apply:**
- H1: Height requirements are critical - use 100pt for fatigue mode buttons
- L1: Use `.light` haptic style for navigation actions
- M1: Add `.accessibilityValue()` for stateful elements if applicable

### Git Intelligence (Recent Commits)

Recent accessibility work patterns from commits:
- `65c9aaa` Story 7.1: Accessibility Settings Screen pattern
- `844c3c2` Story 5.4: Grid layout for keywords
- `db88ad6` Stories 5-1, 5-2: Touch target enlargement patterns

**Established Patterns:**
- `@MainActor` on all view structs
- `@EnvironmentObject` for shared state
- ScaleButtonStyle for animated buttons (but consider disabling for fatigue mode)
- French accessibility labels throughout

### Critical Constraints

- **No external dependencies** - Use native iOS APIs only
- **iOS 16.0+ minimum** - Use SwiftUI features compatible with iOS 16
- **French UI language** - All labels and accessibility hints in French
- **Haptic feedback required** - UIImpactFeedbackGenerator for all button actions
- **State must persist** - Fatigue mode survives app restart

### References

- [Source: epics-ux-accessibility.md#Epic 6: Fatigue Mode, Story 6.2]
- [Source: project-context.md#SwiftUI Patterns]
- [Source: 10-1-add-fatigue-mode-trigger.md#Dev Notes]
- [Source: ControlButtonsView.swift:519-585 - FatigueModeViewPlaceholder to replace]
- [Source: AccessibilitySettings.swift:35-38 - isFatigueModeEnabled property]
- [Source: architecture-gradium-tts-migration.md#Implementation Patterns]

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

N/A - No debug issues encountered.

### Completion Notes List

- **Task 1 COMPLETE**: Created `FatigueModeView.swift` with full-screen dark background (0.9 opacity), 6 buttons in vertical column, 100pt minimum height, .largeTitle font, 32pt horizontal padding and 16pt spacing.
- **Task 2 COMPLETE**: Implemented `FatigueModeButton` component with French messages (OUI, NON, APPELER, DOULEUR, SOIF/FAIM), TTS integration via `speechService.speakText()`, .light haptic feedback, and French accessibility labels.
- **Task 3 COMPLETE**: Added "Mode normal" exit button with gray color distinction, confirmation dialog "Quitter le mode fatigue ?", proper state management for exit confirmation.
- **Task 4 COMPLETE**: Updated ContentView with `showFatigueModeFromPersistence` state, onAppear check for persisted fatigue mode, and fullScreenCover presentation with environment objects.
- **Task 5 COMPLETE**: Replaced FatigueModeViewPlaceholder with real FatigueModeView in ControlButtonsView, removed 65+ lines of placeholder dead code.
- **Task 6 COMPLETE**: Added 4 new unit tests for fatigue mode: message count validation, French language verification, state transitions, and cross-session persistence.
- **Build Verification**: `xcodebuild build` passed successfully - all code compiles without errors.

### File List

| File | Action | Path |
|------|--------|------|
| FatigueModeView.swift | CREATE | HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/FatigueModeView.swift |
| ContentView.swift | MODIFY | HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/ContentView.swift |
| ControlButtonsView.swift | MODIFY | HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift |
| AccessibilitySettingsTests.swift | MODIFY | HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUITests/AccessibilitySettingsTests.swift |

## Change Log

- **2026-01-28**: Story 10.2 implemented - Created minimal fatigue mode interface with 6 essential message buttons, TTS integration, exit confirmation dialog, and state persistence across app sessions.
- **2026-01-28**: Code Review Fixes Applied (8 issues):
  - **H1 Fix**: Centralized fatigue mode presentation in ContentView via onChange handler, eliminated dual state management risk
  - **H2 Fix**: Added VoiceOver announcement "Mode normal activé" when exiting fatigue mode
  - **M1 Fix**: Added explicit `.accessibilityAddTraits(.isButton)` to FatigueModeButton
  - **M2 Fix**: Added "arrow.backward.circle" icon to exit button for visual indicator
  - **L1 Fix**: Added UIImpactFeedbackGenerator with prepare() for optimal haptic timing
  - **L2 Fix**: Created FatigueModeMessage struct for type-safe message handling
  - **L3 Fix**: Preview uses new SpeechService instance instead of shared singleton

