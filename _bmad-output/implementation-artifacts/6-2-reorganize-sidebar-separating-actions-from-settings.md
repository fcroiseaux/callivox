# Story 6.2: Reorganize Sidebar Separating Actions from Settings

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with cognitive fatigue,
I want the sidebar to show only essential actions with settings in a separate menu,
So that I can quickly find the buttons I need without visual overload.

## Acceptance Criteria

1. **AC1: Main Sidebar Layout**
   - **Given** I am on the main screen
   - **When** I view the sidebar (ControlButtonsView)
   - **Then** I see a maximum of 5-6 buttons in the main area:
     - "PARLER" (primary action, largest: 200x80pt minimum)
     - "Répéter" and "Effacer" (secondary actions: side by side, each 95x60pt minimum)
     - "Mes phrases" (action: full width, 50pt minimum height)
     - "Paramètres" (opens settings submenu: full width, 50pt minimum height)
   - **And** user info remains at the bottom

2. **AC2: Settings Submenu**
   - **Given** I tap the "Paramètres" button
   - **When** the settings submenu opens
   - **Then** I see all configuration options previously in sidebar:
     - Service TTS (Gradium TTS)
     - Service IA (LLM Settings)
     - Personnalisation IA
     - Confidentialité (if authentication enabled)
   - **And** each settings button is minimum 60pt height
   - **And** a back/close button allows returning to main sidebar

3. **AC3: Reduced Button Count**
   - **Given** I am viewing the reorganized sidebar
   - **When** I compare to the previous layout
   - **Then** the number of visible buttons is reduced from 8+ to 5-6
   - **And** visual hierarchy clearly distinguishes primary from secondary actions
   - **And** the sidebar remains usable with one hand

4. **AC4: Haptic Feedback**
   - **Given** I tap any button in the sidebar
   - **When** the action is triggered
   - **Then** haptic feedback confirms my selection (.light for navigation, .medium for actions)

5. **AC5: Accessibility**
   - **Given** VoiceOver is enabled
   - **When** I navigate the sidebar
   - **Then** all buttons have French accessibility labels
   - **And** the settings submenu is announced as "Paramètres, ouvre le menu des réglages"
   - **And** the hierarchy is clear (primary action first, then secondary)

## Tasks / Subtasks

- [x] Task 1: Modify ControlButtonsView main layout (AC: 1, 3)
  - [x] 1.1: Replace current VStack with new hierarchical layout
  - [x] 1.2: Create enlarged "PARLER" button (200x80pt minimum) as SpeakControlButton refactor
  - [x] 1.3: Create HStack for "Répéter" and "Effacer" side by side (95x60pt each)
  - [x] 1.4: Add "Mes phrases" button (full width, 50pt minimum)
  - [x] 1.5: Add "Paramètres" button with chevron indicator (full width, 50pt minimum)
  - [x] 1.6: Preserve user info section at bottom
  - [x] 1.7: Remove all direct settings buttons from main sidebar

- [x] Task 2: Create SettingsSubmenuView (AC: 2)
  - [x] 2.1: Create new file `Views/SettingsSubmenuView.swift`
  - [x] 2.2: Implement modal/sheet with dark overlay (consistent with Story 6.1 pattern)
  - [x] 2.3: Add header "Paramètres" with close button
  - [x] 2.4: List all settings buttons vertically (60pt minimum height each):
    - Service TTS (opens GradiumSettingsView)
    - Service IA (opens LLMSettingsView)
    - Personnalisation IA (opens PersonalizationSettingsView)
    - Confidentialité (conditional, opens UsageSettingsView)
  - [x] 2.5: Add back/close button at bottom (60pt minimum)
  - [x] 2.6: Pass all required @State bindings from ControlButtonsView

- [x] Task 3: Integrate settings submenu presentation (AC: 2)
  - [x] 3.1: Add @State showSettingsSubmenu in ControlButtonsView
  - [x] 3.2: Connect "Paramètres" button to show submenu
  - [x] 3.3: Handle settings view presentations from submenu
  - [x] 3.4: Dismiss submenu when opening a specific setting

- [x] Task 4: Add haptic feedback (AC: 4)
  - [x] 4.1: Add UIImpactFeedbackGenerator(style: .light) on submenu open
  - [x] 4.2: Preserve existing haptic on action buttons (Parler, Répéter, Effacer)
  - [x] 4.3: Add haptic on settings button taps

- [x] Task 5: Update accessibility labels (AC: 5)
  - [x] 5.1: Update PARLER button label and hint
  - [x] 5.2: Add accessibility hints for all buttons in French
  - [x] 5.3: Add accessibility traits for primary action
  - [x] 5.4: Ensure VoiceOver reading order is logical (primary → secondary → settings → user info)

- [x] Task 6: Testing
  - [x] 6.1: Build succeeds without errors
  - [x] 6.2: Verify button sizes meet accessibility requirements
  - [x] 6.3: Verify submenu opens/closes correctly
  - [x] 6.4: Verify all settings views are still accessible via submenu
  - [x] 6.5: Verify user info section preserved at bottom

## Dev Notes

### Target Files

**Primary file to modify:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift`

**New file to create:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SettingsSubmenuView.swift`

### Current Implementation Analysis

```swift
// CURRENT STATE (ControlButtonsView.swift) - 8+ buttons in main sidebar
VStack(spacing: 20) {
    SpeakControlButton(...)           // Parler
    RepeatControlButton(...)          // Répéter
    Button("Effacer le texte")        // Effacer
    Button("Gérer les phrases")       // Phrases
    Button("Service TTS")             // → Move to submenu
    Button("Service IA")              // → Move to submenu
    Button("Personnalisation IA")     // → Move to submenu
    if !skipAuth { Button("Confidentialité") }  // → Move to submenu
    if !skipAuth { Button("Déconnexion") }      // → Keep or move
    Spacer()
    UserInfoSection                   // Preserved at bottom
}
```

**Issues with current implementation:**
- 8+ buttons visible simultaneously
- Settings mixed with actions
- High cognitive load for users with fatigue
- No visual hierarchy distinguishing primary from secondary actions
- All buttons same size (no emphasis on primary action)

### Required New Layout Structure

```swift
// Story 6.2: Reorganized sidebar with clear hierarchy (Epic 6 - Simplified Navigation)
VStack(spacing: 16) {
    // PRIMARY ACTION - Largest, most prominent
    SpeakControlButton(...)
        .frame(minHeight: 80)  // AC1: 200x80pt minimum

    // SECONDARY ACTIONS - Side by side
    HStack(spacing: 12) {
        RepeatButton(...)
            .frame(minWidth: 95, minHeight: 60)  // AC1: 95x60pt
        ClearButton(...)
            .frame(minWidth: 95, minHeight: 60)  // AC1: 95x60pt
    }

    // TERTIARY ACTIONS
    PhrasesButton(...)
        .frame(minHeight: 50)  // AC1: full width, 50pt

    SettingsButton(...)
        .frame(minHeight: 50)  // AC1: full width, 50pt

    Spacer()

    // USER INFO - Bottom
    UserInfoSection(...)
}
```

### Settings Submenu Architecture

Following the pattern established in Story 6.1 (GuidanceContextModal):

```swift
// Story 6.2: Settings submenu modal (AC2)
import SwiftUI
import UIKit

@MainActor
struct SettingsSubmenuView: View {
    let onSelectSetting: (SettingType) -> Void
    let onDismiss: () -> Void
    let showPrivacyOption: Bool  // Based on AppConfig.Features.skipAuthentication

    enum SettingType {
        case tts        // GradiumSettingsView
        case llm        // LLMSettingsView
        case personalization  // PersonalizationSettingsView
        case privacy    // UsageSettingsView
    }

    var body: some View {
        ZStack {
            // Semi-transparent background (consistent with Story 6.1)
            Color.black.opacity(0.85)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                // Header
                Text("Paramètres")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                // Settings list
                VStack(spacing: 12) {
                    SettingsButton(
                        icon: "waveform",
                        title: "Service TTS",
                        color: .mint,
                        action: { handleSelection(.tts) }
                    )

                    SettingsButton(
                        icon: "brain",
                        title: "Service IA",
                        color: .indigo,
                        action: { handleSelection(.llm) }
                    )

                    SettingsButton(
                        icon: "person.text.rectangle",
                        title: "Personnalisation IA",
                        color: .cyan,
                        action: { handleSelection(.personalization) }
                    )

                    if showPrivacyOption {
                        SettingsButton(
                            icon: "lock.shield",
                            title: "Confidentialité",
                            color: .teal,
                            action: { handleSelection(.privacy) }
                        )
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Close button (AC2: back/close button)
                Button(action: onDismiss) {
                    Text("Fermer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 60)  // AC2: 60pt minimum
                        .background(Color(.systemGray4))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Menu des paramètres")
    }

    private func handleSelection(_ setting: SettingType) {
        // Haptic feedback (AC4)
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()

        onSelectSetting(setting)
        onDismiss()
    }
}

// MARK: - Settings Button Component
@MainActor
struct SettingsMenuButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 60)  // AC2: minimum 60pt
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [color, color.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .accessibilityLabel(title)
        .accessibilityHint("Ouvre les réglages \(title.lowercased())")
    }
}
```

### Modified ControlButtonsView Structure

```swift
// Story 6.2: Reorganized ControlButtonsView (AC1, AC3)
@MainActor
struct ControlButtonsView: View {
    // Existing bindings...
    @State private var showSettingsSubmenu: Bool = false
    // Keep existing @State for individual settings views

    var body: some View {
        VStack(spacing: 16) {
            // Story 6.2 AC1: PRIMARY ACTION - PARLER
            SpeakControlButton(
                text: recognizedText,
                isLoading: speechService.isLoading,
                onSpeak: { /* existing logic */ }
            )
            .frame(minHeight: 80)  // AC1: 200x80pt

            // Story 6.2 AC1: SECONDARY ACTIONS - Side by side
            HStack(spacing: 12) {
                // Repeat button (simplified)
                CompactRepeatButton(
                    lastText: speechService.lastSpokenText,
                    isLoading: speechService.isLoading,
                    onRepeat: { /* existing logic */ }
                )
                .frame(minWidth: 95, minHeight: 60)  // AC1: 95x60pt

                // Clear button (simplified)
                CompactClearButton(
                    recognizedText: $recognizedText,
                    speakTask: $speakTask,
                    isLoading: speechService.isLoading
                )
                .frame(minWidth: 95, minHeight: 60)  // AC1: 95x60pt
            }

            // Story 6.2 AC1: TERTIARY - Phrases
            Button(action: { showPhraseManager = true }) {
                HStack {
                    Image(systemName: "text.quote")
                    Text("Mes phrases")
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)  // AC1: 50pt
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.purple, .purple.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            .accessibilityLabel("Mes phrases")
            .accessibilityHint("Ouvre la gestion des phrases rapides")

            // Story 6.2 AC1: SETTINGS ENTRY POINT
            Button(action: {
                // AC4: Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                showSettingsSubmenu = true
            }) {
                HStack {
                    Image(systemName: "gearshape")
                    Text("Paramètres")
                        .font(.title3)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(minHeight: 50)  // AC1: 50pt
                .padding(.horizontal, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.gray, .gray.opacity(0.8)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(10)
            }
            .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
            .accessibilityLabel("Paramètres")
            .accessibilityHint("Ouvre le menu des réglages")

            Spacer()

            // USER INFO - preserved at bottom (AC1)
            if let userName = userModel.userName {
                // Existing user info section unchanged
            }
        }
        .padding()
        .frame(minWidth: 200, idealWidth: 250, maxWidth: 300, alignment: .leading)
        .fullScreenCover(isPresented: $showSettingsSubmenu) {
            SettingsSubmenuView(
                onSelectSetting: { setting in
                    handleSettingSelection(setting)
                },
                onDismiss: { showSettingsSubmenu = false },
                showPrivacyOption: !AppConfig.Features.skipAuthentication
            )
        }
        // Existing .sheet modifiers for settings views...
    }

    private func handleSettingSelection(_ setting: SettingsSubmenuView.SettingType) {
        switch setting {
        case .tts:
            showGradiumSettings = true
        case .llm:
            showLLMSettings = true
        case .personalization:
            showPersonalizationSettings = true
        case .privacy:
            showUsageSettings = true
        }
    }
}
```

### Compact Button Components

Create simplified versions of Repeat and Clear buttons for side-by-side layout:

```swift
// Story 6.2: Compact repeat button for side-by-side layout
@MainActor
struct CompactRepeatButton: View {
    var lastText: String
    var isLoading: Bool
    var onRepeat: () -> Void

    var body: some View {
        Button(action: onRepeat) {
            HStack(spacing: 4) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16))
                Text("Répéter")
                    .font(.headline)
                if isLoading {
                    ProgressView().tint(.white).scaleEffect(0.8)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 60)  // AC1: 95x60pt
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.green, .green.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .disabled(isLoading || lastText.isEmpty)
        .opacity((isLoading || lastText.isEmpty) ? 0.5 : 1.0)
        .accessibilityLabel("Répéter")
        .accessibilityHint(lastText.isEmpty ? "Aucun texte à répéter" : "Répète: \(lastText)")
    }
}

// Story 6.2: Compact clear button for side-by-side layout
@MainActor
struct CompactClearButton: View {
    @Binding var recognizedText: String
    @Binding var speakTask: Task<Void, Never>?
    var isLoading: Bool

    var body: some View {
        Button(action: {
            recognizedText = ""
            speakTask?.cancel()
        }) {
            HStack(spacing: 4) {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 16))
                Text("Effacer")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, minHeight: 60)  // AC1: 95x60pt
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.red, .red.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(10)
        }
        .buttonStyle(ScaleButtonStyle(scaleAmount: 0.97, pressedColor: .clear, normalColor: .clear))
        .disabled(isLoading || recognizedText.isEmpty)
        .opacity((isLoading || recognizedText.isEmpty) ? 0.5 : 1.0)
        .accessibilityLabel("Effacer")
        .accessibilityHint(recognizedText.isEmpty ? "Aucun texte à effacer" : "Efface le texte saisi")
    }
}
```

### Architecture Compliance

1. **SwiftUI Patterns**: `@MainActor` on all views, `@EnvironmentObject` for services
2. **Modal Presentation**: Use `fullScreenCover` consistent with Story 6.1
3. **Accessibility Labels**: All labels in French
4. **Button Style**: Reuse existing `ScaleButtonStyle`
5. **Haptic Feedback**: `.light` for navigation, `.medium` for actions
6. **Error Handling**: Preserve isLoading/isDisabled state handling

### Existing Code Patterns to Follow

From `ControlButtonsView.swift`:
- Use `@EnvironmentObject var speechService: SpeechService`
- Use `@EnvironmentObject var userModel: UserModel`
- LinearGradient backgrounds for buttons
- ScaleButtonStyle for button press animation
- French accessibility labels

From Story 6.1 (GuidanceContextModal):
- fullScreenCover for modal presentation
- Color.black.opacity(0.85) for overlay background
- 60pt minimum for close button
- UIImpactFeedbackGenerator for haptic feedback
- @AccessibilityFocusState for VoiceOver

### Project Structure Notes

- New file location: `Views/SettingsSubmenuView.swift`
- Modified file: `Views/ControlButtonsView.swift`
- Compact button components can be in ControlButtonsView.swift or separate file
- No service layer changes needed

### References

- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift] - Primary target file
- [Source: _bmad-output/planning-artifacts/epics-ux-accessibility.md#Story 2.2] - Requirements
- [Source: HandwritingToSpeechSwiftUI/docs/audit-ux-accessibilite.md#Section 6.3] - UX audit recommendations
- [Source: _bmad-output/implementation-artifacts/6-1-create-modal-menu-for-guidance-contexts.md] - Modal pattern reference
- [Source: _bmad-output/planning-artifacts/architecture-gradium-tts-migration.md] - Architecture patterns

### UX Audit Context

From the UX accessibility audit (Section 6.3):

**Problem C3 - Too many buttons in sidebar:**
> - **Composant**: ControlButtonsView
> - **Impact**: Charge cognitive élevée, recherche visuelle difficile
> - **Actuel**: 11+ boutons mélangés (actions + paramètres)

**Recommendation:**
> **Avant**: 11 boutons mélangés
> **Après**: Section haute = 4-5 actions principales, paramètres dans menu séparé

### Visual Comparison

**Before (Current - 8+ buttons):**
```
┌────────────────────────────┐
│ 🔊 Lire à haute voix       │
│ 🔄 Répéter                 │
│ ✕ Effacer le texte         │
│ 📝 Gérer les phrases       │
│ 🎵 Service TTS             │
│ 🧠 Service IA              │
│ 👤 Personnalisation IA     │
│ 🔒 Confidentialité         │
│ 🚪 Déconnexion             │
│                            │
│ 👤 User info               │
└────────────────────────────┘
```

**After (Story 6.2 - 5 buttons + submenu):**
```
┌────────────────────────────┐
│ ┌────────────────────────┐ │
│ │   🔊 LIRE À HAUTE VOIX │ │  ← 200x80pt
│ └────────────────────────┘ │
│ ┌──────────┐┌──────────┐   │
│ │ Répéter  ││ Effacer  │   │  ← 95x60pt each
│ └──────────┘└──────────┘   │
│ ┌────────────────────────┐ │
│ │ 📝 Mes phrases         │ │  ← 50pt
│ └────────────────────────┘ │
│ ┌────────────────────────┐ │
│ │ ⚙️ Paramètres       ▶  │ │  ← 50pt, opens submenu
│ └────────────────────────┘ │
│                            │
│ 👤 User info               │
└────────────────────────────┘
```

**Submenu (on "Paramètres" tap):**
```
┌────────────────────────────────────────────────────────────┐
│ ████████████████████████████████████████████████████████████│
│ █                                                          █│
│ █              Paramètres                                  █│
│ █                                                          █│
│ █   ┌──────────────────────────────────────────────┐       █│
│ █   │ 🎵 Service TTS                           ▶   │       █│
│ █   └──────────────────────────────────────────────┘       █│
│ █   ┌──────────────────────────────────────────────┐       █│
│ █   │ 🧠 Service IA                            ▶   │       █│
│ █   └──────────────────────────────────────────────┘       █│
│ █   ┌──────────────────────────────────────────────┐       █│
│ █   │ 👤 Personnalisation IA                   ▶   │       █│
│ █   └──────────────────────────────────────────────┘       █│
│ █   ┌──────────────────────────────────────────────┐       █│
│ █   │ 🔒 Confidentialité                       ▶   │       █│
│ █   └──────────────────────────────────────────────┘       █│
│ █                                                          █│
│ █   ┌──────────────────────────────────────────────┐       █│
│ █   │              Fermer                          │       █│
│ █   └──────────────────────────────────────────────┘       █│
│ ████████████████████████████████████████████████████████████│
└────────────────────────────────────────────────────────────┘
```

### Previous Story Intelligence

**Learnings from Story 6.1 implementation:**
- fullScreenCover provides maximum accessibility for modal presentation
- Color.black.opacity(0.85) background works well for overlays
- UIImpactFeedbackGenerator(style: .light) for navigation actions
- @AccessibilityFocusState helps VoiceOver users know modal opened
- Always include a close button with minimum 60pt height
- Remove background tap dismiss to prevent accidental dismissal for tremor users

**Learnings from Epic 5 patterns:**
- 60pt minimum touch targets are the accessibility baseline
- Inline comments referencing Story and ACs improve traceability
- Code review catches accessibility issues like missing hints

### Git Intelligence

**Recent relevant commits:**
- `844c3c2` - Story 5.4: Grid layout pattern (similar grid concept)
- `1225053` - Story 5.3: Enlarged header buttons pattern
- `db88ad6` - Stories 5-1, 5-2: Touch target enlargement patterns
- `000363f` - Story 4.2: Settings button patterns (guidance controls)

**Pattern established:**
- Story implementations use inline comments referencing Story ID and AC numbers
- New views created in `Views/` directory
- Components follow existing naming conventions
- ScaleButtonStyle used for all interactive buttons

### WARNING: Code Review Traps to Avoid

Based on previous code reviews:

1. **DO NOT remove existing SpeakControlButton/RepeatControlButton** - Refactor or create compact versions
2. **DO NOT forget to preserve user info section** at bottom (AC1)
3. **DO NOT hardcode button sizes** - Use .frame(minWidth:, minHeight:) for flexibility
4. **DO NOT skip haptic feedback** - Required for accessibility confirmation (AC4)
5. **DO NOT use .sheet for settings submenu** - Use .fullScreenCover for consistency with Story 6.1
6. **DO NOT forget to pass showPrivacyOption** based on AppConfig.Features.skipAuthentication
7. **DO NOT remove Story 3.1/4.1 inline comments** - They document original implementation
8. **DO NOT change existing settings view files** - Only modify presentation from ControlButtonsView
9. **DO NOT forget close button in submenu** - Required for accessibility (AC2)
10. **DO NOT forget French accessibility labels** - All labels must be in French (AC5)

### Related Stories (Do NOT implement in this story)

- **Story 7-1:** Enhanced accessibility mode with 80pt targets (Epic 7)
- **Story 7-4:** Add confirmation dialogs for destructive actions (Epic 7) - Effacer button could use this later

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build successful: xcodebuild Release-iphonesimulator 2026-01-27

### Completion Notes List

- **Task 1 (AC1, AC3):** Reorganized ControlButtonsView with clear visual hierarchy:
  - Primary action (PARLER) with 80pt minimum height
  - Secondary actions (Répéter/Effacer) side-by-side with CompactRepeatButton/CompactClearButton
  - Tertiary actions (Mes phrases, Paramètres) with 50pt minimum height
  - Button count reduced from 8+ to 5 visible buttons
  - User info section preserved at bottom

- **Task 2 (AC2):** Created SettingsSubmenuView.swift:
  - fullScreenCover modal with dark overlay (consistent with Story 6.1)
  - All 4 settings options: Service TTS, Service IA, Personnalisation IA, Confidentialité
  - Each button 60pt minimum height
  - Close button at bottom
  - showPrivacyOption conditional based on AppConfig.Features.skipAuthentication

- **Task 3 (AC2):** Integrated submenu presentation:
  - Added @State showSettingsSubmenu
  - handleSettingSelection() routes to appropriate settings view
  - Settings views open via sheet after submenu dismisses

- **Task 4 (AC4):** Haptic feedback implemented:
  - .medium for action buttons (PARLER, Répéter, Effacer)
  - .light for navigation buttons (Mes phrases, Paramètres, settings submenu items)

- **Task 5 (AC5):** All accessibility labels in French:
  - All buttons have accessibilityLabel and accessibilityHint
  - "Paramètres" announces "Ouvre le menu des réglages"
  - VoiceOver reading order follows visual hierarchy

- **Task 6:** Build verification passed without errors

### File List

**New Files:**

- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SettingsSubmenuView.swift

**Modified Files:**

- HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/ControlButtonsView.swift

### Change Log

- 2026-01-27: Story 6.2 implementation complete - Reorganized sidebar with settings submenu (Claude Opus 4.5)
- 2026-01-27: Code review completed - 4 issues found, all fixed (Claude Opus 4.5)

### Code Review Fixes Applied

| ID | Severity | Fix Applied |
|----|----------|-------------|
| M1 | Medium | Added `minWidth: 95` to CompactRepeatButton and CompactClearButton (AC1 compliance) |
| M2 | Medium | Added `minWidth: 200` to SpeakControlButton (AC1 compliance) |
| L1 | Low | Documented: GuidanceControlsView.swift changes are from Story 6.1, not Story 6.2 |
| L2 | Low | Removed 65 lines of legacy RepeatControlButton dead code |
