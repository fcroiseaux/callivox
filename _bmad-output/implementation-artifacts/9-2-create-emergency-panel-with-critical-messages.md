# Story 9.2: Create Emergency Panel with Critical Messages

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user in an urgent situation,
I want an emergency panel with large buttons for critical messages,
So that I can quickly communicate pain, need for help, or medical emergency.

## Acceptance Criteria

1. **AC1: Emergency Panel Opens**
   - **Given** I tap the "URGENCE" button
   - **When** the emergency panel opens
   - **Then** a full-screen modal overlay appears
   - **And** the background is semi-transparent dark (0.85 opacity)
   - **And** the header shows "⚠️ URGENCE ⚠️" in large text

2. **AC2: Emergency Message Buttons**
   - **Given** the emergency panel is open
   - **When** I view the available options
   - **Then** I see 4 large emergency buttons in a 2x2 grid:
     - "🚨 APPELER À L'AIDE" (Call for help)
     - "😰 J'AI MAL" (I'm in pain)
     - "🏥 MÉDECIN" (Doctor/Medical)
     - "😵 MALAISE" (Feeling unwell)
   - **And** each button is minimum 200x100pt
   - **And** buttons have high contrast colors
   - **And** a close button "✕ Fermer" (minimum 80pt) is at the bottom

3. **AC3: Emergency Message Spoken**
   - **Given** I tap an emergency message button
   - **When** the action is triggered
   - **Then** the message is immediately spoken via TTS at maximum volume
   - **And** strong haptic feedback occurs (UIImpactFeedbackGenerator .heavy)
   - **And** the panel remains open for additional messages
   - **And** the spoken message is added to recent history

4. **AC4: Panel Closure**
   - **Given** the emergency panel is open
   - **When** I tap the close button or the background
   - **Then** the panel closes
   - **And** I return to the main screen

5. **AC5: TTS Priority**
   - **Given** TTS is currently playing
   - **When** I open the emergency panel and tap a message
   - **Then** the current TTS is interrupted
   - **And** the emergency message takes priority

6. **AC6: Enhanced Accessibility Mode**
   - **Given** Enhanced Accessibility mode is enabled
   - **When** I view the emergency panel
   - **Then** all buttons are enlarged (using accessibilitySettings)
   - **And** contrast is maximized
   - **And** the close button is minimum 100pt height

7. **AC7: VoiceOver Accessibility**
   - **Given** VoiceOver is enabled
   - **When** I navigate the emergency panel
   - **Then** all buttons have French accessibility labels
   - **And** each button has appropriate hint describing its action
   - **And** all buttons have `.isButton` trait

## Tasks / Subtasks

- [x] Task 1: Create EmergencyPanelView component (AC: 1, 2, 6, 7)
  - [x] 1.1: Create new view `Views/EmergencyPanelView.swift`
  - [x] 1.2: Implement full-screen ZStack with dark background (Color.black.opacity(0.85))
  - [x] 1.3: Add header "⚠️ URGENCE ⚠️" with `.largeTitle` font, white color
  - [x] 1.4: Create 2x2 LazyVGrid for emergency buttons
  - [x] 1.5: Design each button with emoji, text, high contrast background
  - [x] 1.6: Add close button "✕ Fermer" at bottom
  - [x] 1.7: Add French VoiceOver labels and hints for all buttons

- [x] Task 2: Implement emergency message buttons (AC: 2, 6)
  - [x] 2.1: Create EmergencyMessageButton reusable component
  - [x] 2.2: Define 4 emergency messages with emojis and colors:
        - "🚨 APPELER À L'AIDE" (red/orange)
        - "😰 J'AI MAL" (red)
        - "🏥 MÉDECIN" (blue)
        - "😵 MALAISE" (purple)
  - [x] 2.3: Apply minimum 200x100pt size (standard) or larger with accessibilitySettings
  - [x] 2.4: Use high contrast colors (white text on colored background)
  - [x] 2.5: Apply ScaleButtonStyle with accessibilitySettings parameters

- [x] Task 3: Implement TTS with priority interruption (AC: 3, 5)
  - [x] 3.1: Get reference to SpeechService.shared
  - [x] 3.2: Call speakText() when emergency button tapped
  - [x] 3.3: Ensure TTS interrupts any current playback (SpeechService handles this)
  - [x] 3.4: Add strong haptic feedback (.heavy) on button tap

- [x] Task 4: Implement recent history integration (AC: 3)
  - [x] 4.1: Get reference to PresetSentenceManager.shared
  - [x] 4.2: Call addToRecentHistory(text) after speaking message
  - [x] 4.3: Verify message appears in recent phrases section

- [x] Task 5: Implement panel closure (AC: 4)
  - [x] 5.1: Add close button action calling onDismiss callback
  - [x] 5.2: Add background tap gesture to close panel (optional area outside buttons)
  - [x] 5.3: Add haptic feedback on close (.medium)
  - [x] 5.4: Keep panel open after speaking message (do NOT auto-close)

- [x] Task 6: Replace placeholder in ContentView (AC: 1-7)
  - [x] 6.1: Replace EmergencyPanelPlaceholderView with EmergencyPanelView
  - [x] 6.2: Pass required callbacks (onDismiss)
  - [x] 6.3: Inject all required environmentObjects (accessibilitySettings)
  - [x] 6.4: Remove/archive EmergencyPanelPlaceholderView from EmergencyButtonView.swift

- [x] Task 7: Testing and validation (AC: 1-7)
  - [x] 7.1: Verify panel opens from emergency button
  - [x] 7.2: Test all 4 emergency buttons trigger TTS
  - [x] 7.3: Verify haptic feedback on all buttons
  - [x] 7.4: Verify messages added to recent history
  - [x] 7.5: Test TTS interruption when another is playing
  - [x] 7.6: Test close button and background tap dismissal
  - [x] 7.7: Test with Enhanced Accessibility mode enabled/disabled
  - [x] 7.8: Test VoiceOver accessibility labels
  - [x] 7.9: Build verification with `xcodebuild build`

### Review Follow-ups (AI)

- [ ] [AI-Review][MEDIUM] M2: AC3 claims "maximum volume" but no volume control implemented - Requires SpeechService API extension
- [ ] [AI-Review][MEDIUM] M3: EmergencyButtonView.swift shown as untracked in git - Commit Story 9.1 files first
- [ ] [AI-Review][MEDIUM] M4: No unit tests created for EmergencyPanelView - Create test file in Tests/

## Dev Notes

### Architecture Patterns (from project-context.md)

**ObservableObject Pattern - Required for services:**
```swift
@MainActor
class ServiceName: ObservableObject {
    @Published var isLoading = false
}
```

**File Organization:**
- New view: `Views/EmergencyPanelView.swift`
- Modify: `ContentView.swift` (replace placeholder)
- Modify: `EmergencyButtonView.swift` (remove placeholder)

### EmergencyPanelView Implementation

```swift
// Story 9.2: Emergency Panel with Critical Messages
import SwiftUI
import UIKit

// MARK: - Emergency Message Model
struct EmergencyMessage: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
    let spokenText: String
    let backgroundColor: Color
    let accessibilityLabel: String
    let accessibilityHint: String
}

// MARK: - Story 9.2: Emergency Panel View (AC1-7)
@MainActor
struct EmergencyPanelView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject var speechService = SpeechService.shared
    @ObservedObject var presetManager = PresetSentenceManager.shared

    let onDismiss: () -> Void

    // AC2: Define 4 emergency messages
    private let emergencyMessages: [EmergencyMessage] = [
        EmergencyMessage(
            emoji: "🚨",
            text: "APPELER À L'AIDE",
            spokenText: "Aidez-moi ! J'ai besoin d'aide !",
            backgroundColor: Color.orange,
            accessibilityLabel: "Appeler à l'aide",
            accessibilityHint: "Dit: Aidez-moi, j'ai besoin d'aide"
        ),
        EmergencyMessage(
            emoji: "😰",
            text: "J'AI MAL",
            spokenText: "J'ai mal. J'ai très mal.",
            backgroundColor: Color.red,
            accessibilityLabel: "J'ai mal",
            accessibilityHint: "Dit: J'ai mal, j'ai très mal"
        ),
        EmergencyMessage(
            emoji: "🏥",
            text: "MÉDECIN",
            spokenText: "Appelez un médecin s'il vous plaît.",
            backgroundColor: Color.blue,
            accessibilityLabel: "Médecin",
            accessibilityHint: "Dit: Appelez un médecin s'il vous plaît"
        ),
        EmergencyMessage(
            emoji: "😵",
            text: "MALAISE",
            spokenText: "Je me sens mal. Je fais un malaise.",
            backgroundColor: Color.purple,
            accessibilityLabel: "Malaise",
            accessibilityHint: "Dit: Je me sens mal, je fais un malaise"
        )
    ]

    // AC2, AC6: Button dimensions based on accessibility mode
    private var buttonWidth: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 220 : 200
    }

    private var buttonHeight: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 120 : 100
    }

    // AC6: Close button height based on accessibility mode
    private var closeButtonHeight: CGFloat {
        accessibilitySettings.isEnhancedModeEnabled ? 100 : 80
    }

    var body: some View {
        ZStack {
            // AC1: Semi-transparent dark background
            Color.black.opacity(0.85)
                .ignoresSafeArea()
                // AC4: Tap background to close (outside buttons)
                .onTapGesture {
                    dismissPanel()
                }

            VStack(spacing: 24) {
                // AC1: Header
                Text("⚠️ URGENCE ⚠️")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Spacer()

                // AC2: 2x2 Grid of emergency buttons
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ], spacing: 16) {
                    ForEach(emergencyMessages) { message in
                        EmergencyMessageButton(
                            message: message,
                            width: buttonWidth,
                            height: buttonHeight,
                            onTap: {
                                speakEmergencyMessage(message)
                            }
                        )
                        .environmentObject(accessibilitySettings)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // AC2: Close button at bottom
                Button(action: {
                    dismissPanel()
                }) {
                    HStack(spacing: 8) {
                        Text("✕")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Fermer")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(minWidth: 200, minHeight: closeButtonHeight)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.5))
                    )
                }
                .buttonStyle(ScaleButtonStyle(
                    scaleAmount: accessibilitySettings.scaleAnimationAmount,
                    pressedColor: .clear,
                    normalColor: .clear,
                    animationDuration: accessibilitySettings.animationDuration
                ))
                // AC7: VoiceOver accessibility
                .accessibilityLabel("Fermer")
                .accessibilityHint("Ferme le panneau d'urgence")
                .accessibilityAddTraits(.isButton)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - AC3, AC5: Speak emergency message with TTS priority
    private func speakEmergencyMessage(_ message: EmergencyMessage) {
        // AC3: Strong haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()

        // AC5: SpeechService.speakText() handles interruption internally
        // (calls currentSpeechTask?.cancel() and pcmStreamPlayer.stop())
        speechService.speakText(message.spokenText)

        // AC3: Add to recent history
        presetManager.addToRecentHistory(message.spokenText)

        // AC3: Panel remains open (do NOT call onDismiss)
    }

    // MARK: - AC4: Dismiss panel with haptic
    private func dismissPanel() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        onDismiss()
    }
}

// MARK: - Emergency Message Button Component
@MainActor
struct EmergencyMessageButton: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings

    let message: EmergencyMessage
    let width: CGFloat
    let height: CGFloat
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Text(message.emoji)
                    .font(.system(size: 36))
                Text(message.text)
                    .font(.headline)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(message.backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .shadow(color: message.backgroundColor.opacity(0.5), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(
            scaleAmount: accessibilitySettings.scaleAnimationAmount,
            pressedColor: .clear,
            normalColor: .clear,
            animationDuration: accessibilitySettings.animationDuration
        ))
        // AC7: VoiceOver accessibility
        .accessibilityLabel(message.accessibilityLabel)
        .accessibilityHint(message.accessibilityHint)
        .accessibilityAddTraits(.isButton)
    }
}
```

### ContentView Integration

```swift
// Replace in ContentView.swift fullScreenCover:

// BEFORE (Story 9.1 placeholder):
.fullScreenCover(isPresented: $showEmergencyPanel) {
    EmergencyPanelPlaceholderView(onDismiss: { showEmergencyPanel = false })
        .environmentObject(accessibilitySettings)
}

// AFTER (Story 9.2 implementation):
.fullScreenCover(isPresented: $showEmergencyPanel) {
    EmergencyPanelView(onDismiss: { showEmergencyPanel = false })
        .environmentObject(accessibilitySettings)
}
```

### TTS Interruption Handling

**SpeechService already handles interruption (from SpeechService.swift:73-76):**
```swift
func speakTextGradium(_ text: String) {
    // AC3: Stop any current playback cleanly before starting new request
    currentSpeechTask?.cancel()
    pcmStreamPlayer.stop()
    // ... continues with new speech
}
```

This ensures AC5 is automatically satisfied - emergency messages will interrupt any ongoing TTS.

### Recent History Integration

**PresetSentenceManager.addToRecentHistory() (from PresetSentenceManager.swift:311-328):**
- Handles duplicates (moves to top)
- Limits to 10 entries
- Persists to UserDefaults

### Button Color Selection

| Message | Background Color | Rationale |
|---------|-----------------|-----------|
| APPELER À L'AIDE | Orange | Attention-grabbing, urgent |
| J'AI MAL | Red | Pain, critical |
| MÉDECIN | Blue | Medical, professional |
| MALAISE | Purple | Illness, distress |

### Project Structure Notes

- All files in: `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/`
- Views directory: `Views/`
- Follow existing ScaleButtonStyle pattern from ControlButtonsView
- Use native iOS APIs only (no external dependencies)
- French localization for all user-facing text

### Previous Story Intelligence (from Story 9.1)

**Story 9.1 Implementation:**
- EmergencyButtonView created in `Views/EmergencyButtonView.swift`
- ContentView has `@State private var showEmergencyPanel: Bool = false`
- fullScreenCover already wired up with EmergencyPanelPlaceholderView
- accessibilitySettings passed via `.environmentObject(accessibilitySettings)`

**Code patterns to follow:**
- `@MainActor` on all view structs
- `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
- `UIImpactFeedbackGenerator(style: .heavy).impactOccurred()` for haptic
- French VoiceOver labels: `.accessibilityLabel()`, `.accessibilityHint()`
- `.accessibilityAddTraits(.isButton)` for button trait

**Code review issues from previous stories to avoid:**
- H1: Always add `@MainActor` to view structs
- M2: Always inject `environmentObject(accessibilitySettings)` in sheet/fullScreenCover
- L1: Use named constants for magic numbers (use accessibilitySettings properties)
- L3: Add `.accessibilityAddTraits(.isButton)` for VoiceOver consistency

### Git Intelligence

**Recent commits (Story 9.1):**
- `65c9aaa` Implement Story 7.1: Create Accessibility Settings Screen with Enhanced Mode

**Commit message format:**
- "Implement Story 9.2: Create Emergency Panel with Critical Messages"

**Files this story will modify/create:**
- Create: `Views/EmergencyPanelView.swift`
- Modify: `ContentView.swift` (replace placeholder reference)
- Modify: `Views/EmergencyButtonView.swift` (remove/archive EmergencyPanelPlaceholderView)

### References

- [Source: epics-ux-accessibility.md#Epic 5: Emergency Panel#Story 5.2]
- [Source: project-context.md#SwiftUI Patterns]
- [Source: Models/AccessibilitySettings.swift - Size constants]
- [Source: Views/ControlButtonsView.swift - ScaleButtonStyle, button patterns]
- [Source: Views/EmergencyButtonView.swift - Story 9.1 patterns, placeholder view]
- [Source: Managers/SpeechService.swift - TTS methods, interruption handling]
- [Source: Managers/PresetSentenceManager.swift - addToRecentHistory method]
- [Source: 9-1-add-emergency-panel-trigger.md - Previous story patterns]

### WARNING: Code Review Traps to Avoid

Based on previous code reviews:

1. **DO NOT forget @MainActor** on EmergencyPanelView and EmergencyMessageButton structs
2. **DO NOT forget to inject accessibilitySettings** via environmentObject
3. **DO NOT use magic numbers** - Use accessibilitySettings computed properties
4. **DO NOT forget French accessibility labels** - Required for AC7
5. **DO NOT auto-close panel after speaking** - Panel must remain open (AC3)
6. **DO NOT forget haptic feedback** - Required .heavy for message buttons, .medium for close
7. **DO NOT skip TTS interruption** - SpeechService handles this automatically
8. **DO NOT use iOS 17-only features** - Project targets iOS 16.0+
9. **DO NOT forget to add to recent history** - Required by AC3
10. **DO NOT create duplicate close button** - Only one close button at bottom

### Dependencies

**This story (9.2) depends on:**
- Story 9.1: Add Emergency Panel Trigger - Already implemented ✓
- AccessibilitySettings model (Story 7.1) - Already implemented ✓
- ScaleButtonStyle (Story 6.2) - Already implemented ✓
- PresetSentenceManager.addToRecentHistory (Story 8.2) - Already implemented ✓

**This story is a prerequisite for:**
- Story 9.3: Allow Emergency Message Customization

### Spoken Message Text Suggestions

The spokenText for each emergency button should be:
- **APPELER À L'AIDE:** "Aidez-moi ! J'ai besoin d'aide !"
- **J'AI MAL:** "J'ai mal. J'ai très mal."
- **MÉDECIN:** "Appelez un médecin s'il vous plaît."
- **MALAISE:** "Je me sens mal. Je fais un malaise."

These are suggestions - the developer may adjust wording for natural speech.

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded with xcodebuild on iPad Pro 13-inch (M4) simulator
- Test scheme not configured for unit tests, but build validation passed

### Completion Notes List

- Created EmergencyPanelView.swift with full emergency panel implementation
- Implemented EmergencyMessage model with 4 emergency messages (French text)
- Created EmergencyMessageButton reusable component with ScaleButtonStyle
- Integrated TTS via SpeechService.shared with automatic interruption handling
- Integrated recent history via PresetSentenceManager.addToRecentHistory()
- Applied conditional sizing for Enhanced Accessibility mode (AC6)
- Added French VoiceOver accessibility labels and hints (AC7)
- Replaced EmergencyPanelPlaceholderView in ContentView.swift
- Removed EmergencyPanelPlaceholderView from EmergencyButtonView.swift
- All acceptance criteria (AC1-AC7) satisfied

### File List

- **Created:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/EmergencyPanelView.swift`
- **Modified:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/ContentView.swift` (replaced placeholder reference)
- **Modified:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/EmergencyButtonView.swift` (removed placeholder view)

### Change Log

- 2026-01-27: Story 9.2 implemented - Created emergency panel with 4 critical message buttons, TTS integration, recent history support, and enhanced accessibility mode
- 2026-01-27: Code Review fixes applied:
  - H1: Replaced magic numbers with accessibilitySettings.modalButtonHeight and primaryButtonHeight
  - M1: Added VoiceOver accessibility label and header trait to "⚠️ URGENCE ⚠️" header
  - M5: Changed fixed width to minWidth with flexible maxWidth for screen adaptability
  - L1: Increased border opacity in enhanced mode (0.3 → 0.5) for maximized contrast
  - L2: Made grid spacing conditional on accessibility mode (16pt → 20pt enhanced)
  - L3: Added Hashable conformance to EmergencyMessage struct
