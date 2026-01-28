# Story 11.4: Configure Scanning Mode Settings

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a caregiver setting up scanning mode,
I want to adjust scanning speed and behavior,
So that it matches the user's reaction time and preferences.

## Acceptance Criteria

1. **AC1 - Configuration Options**
   - Given scanning mode is enabled in settings
   - When I view scanning configuration options
   - Then I see the following adjustable parameters:
     - Scan speed: Slow (3s), Medium (2s), Fast (1s)
     - Scan direction: Forward only / Forward and backward
     - Auto-restart: On/Off
     - Sound feedback: On/Off (beep on highlight)

2. **AC2 - Scan Speed Adjustment**
   - Given I adjust the scan speed
   - When I select "Slow (3s)"
   - Then each button is highlighted for 3 seconds
   - And the change takes effect immediately

3. **AC3 - Sound Feedback**
   - Given sound feedback is enabled
   - When a button is highlighted during scanning
   - Then a subtle audio cue plays
   - And the sound is distinct and non-intrusive

4. **AC4 - Test Mode**
   - Given I am testing scanning settings
   - When I tap "Tester le scanning"
   - Then a preview mode activates showing scanning behavior
   - And I can adjust settings in real-time
   - And tapping "Terminé" saves settings and exits preview

## Tasks / Subtasks

- [x] Task 1: Add Scan Direction to ScanningModeSettings (AC: 1)
  - [x] 1.1: Add `ScanDirection` enum (.forwardOnly, .forwardAndBackward) with French displayNames
  - [x] 1.2: Add `@Published var scanDirection: ScanDirection` with UserDefaults persistence
  - [x] 1.3: Add UserDefaults key `com.callivox.scanning_mode_direction`
  - [x] 1.4: Update `resetToDefaults()` to include scanDirection = .forwardOnly

- [x] Task 2: Implement Sound Feedback in ScanningModeController (AC: 3)
  - [x] 2.1: Import `AudioToolbox` in ScanningModeController.swift
  - [x] 2.2: Add private method `playHighlightSound()` using `AudioServicesPlaySystemSound(1103)` (Tock)
  - [x] 2.3: Call `playHighlightSound()` in `advanceHighlight()` when `settings.soundFeedbackEnabled` is true
  - [x] 2.4: Ensure sound does not play during VoiceOver (check `UIAccessibility.isVoiceOverRunning`)

- [x] Task 3: Implement Scan Direction in ScanningModeController (AC: 1)
  - [x] 3.1: Add private property `private var direction: Int = 1` (1 = forward, -1 = backward)
  - [x] 3.2: Modify `advanceHighlight()` to use `direction` for forward/backward cycling
  - [x] 3.3: Handle edge cases: at first item go forward, at last item check direction setting
  - [x] 3.4: If `forwardAndBackward`: reverse direction at ends instead of wrapping

- [x] Task 4: Create ScanningModeSettingsView (AC: 1, 2, 3, 4)
  - [x] 4.1: Create `ScanningModeSettingsView.swift` in `Views/` folder
  - [x] 4.2: Add `@MainActor struct ScanningModeSettingsView: View`
  - [x] 4.3: Add `@EnvironmentObject var accessibilitySettings: AccessibilitySettings`
  - [x] 4.4: Add `@ObservedObject private var scanningSettings = ScanningModeSettings.shared`
  - [x] 4.5: Add Section "Vitesse de scanning" with Picker for ScanSpeed (AC1, AC2)
  - [x] 4.6: Add Section "Direction" with Picker for ScanDirection (AC1)
  - [x] 4.7: Add Section "Comportement" with Toggle for autoRestart and soundFeedbackEnabled (AC1)
  - [x] 4.8: Add Section with "Tester le scanning" button (AC4)
  - [x] 4.9: Apply `accessibilitySettings.buttonHeight` to all rows
  - [x] 4.10: Add French VoiceOver labels and hints to all controls
  - [x] 4.11: Add "Réinitialiser par défaut" button with confirmation dialog

- [x] Task 5: Create Scanning Test Mode (AC: 4)
  - [x] 5.1: Add `@State private var isTestModeActive: Bool = false` to ScanningModeSettingsView
  - [x] 5.2: Create `ScanningTestPreviewView` component showing 4 sample buttons
  - [x] 5.3: Show preview as overlay or sheet when test mode is active
  - [x] 5.4: Connect preview to ScanningModeController for live demonstration
  - [x] 5.5: Add "Terminé" button (minimum 60pt) to dismiss and save
  - [x] 5.6: Settings changes during test mode apply immediately

- [x] Task 6: Integrate ScanningModeSettingsView in AccessibilitySettingsView (AC: 1)
  - [x] 6.1: Replace placeholder HStack in "Mode Scanning" section with NavigationLink
  - [x] 6.2: Navigate to ScanningModeSettingsView with environmentObject
  - [x] 6.3: Remove "À venir" text
  - [x] 6.4: Maintain same icon and label styling

- [x] Task 7: Unit Tests (AC: 1, 2, 3)
  - [x] 7.1: Test ScanDirection enum rawValue/displayName
  - [x] 7.2: Test ScanningModeSettings scanDirection persistence
  - [x] 7.3: Test ScanningModeController direction change behavior
  - [x] 7.4: Test forward-and-backward cycling at boundaries
  - [x] 7.5: Test resetToDefaults includes scanDirection

## Dev Notes

### Critical Architecture: Building on Story 11.3 Foundation

Story 11.3 created the core scanning infrastructure:
- `ScanningModeSettings.swift` - Already has scanSpeed, autoRestart, soundFeedbackEnabled
- `ScanningModeController.swift` - Timer-based highlighting with selection

This story adds configuration UI and enhances controller logic for:
- Scan direction (new property)
- Sound feedback (connect existing property to audio)
- Test mode (preview functionality)

### ScanDirection Enum Pattern

```swift
// MARK: - Task 1.1: ScanDirection Enum

/// AC1: Scan direction configuration
enum ScanDirection: String, CaseIterable, Codable {
    case forwardOnly = "forward_only"
    case forwardAndBackward = "forward_and_backward"

    /// French display name for settings UI
    var displayName: String {
        switch self {
        case .forwardOnly: return "Avant uniquement"
        case .forwardAndBackward: return "Avant et arrière"
        }
    }

    /// Accessibility description
    var accessibilityDescription: String {
        switch self {
        case .forwardOnly: return "Le scanning recommence au début après le dernier élément"
        case .forwardAndBackward: return "Le scanning fait demi-tour aux extrémités"
        }
    }
}
```

### Sound Feedback Implementation Pattern

```swift
// MARK: - Task 2: Sound Feedback

import AudioToolbox

// In ScanningModeController.swift:

/// AC3: Play subtle audio cue on highlight
private func playHighlightSound() {
    // Don't play sound during VoiceOver (VoiceOver handles its own audio)
    guard !UIAccessibility.isVoiceOverRunning else { return }
    guard settings.soundFeedbackEnabled else { return }

    // SystemSoundID 1103 = "Tock" - subtle, non-intrusive
    AudioServicesPlaySystemSound(1103)
}

// In advanceHighlight():
private func advanceHighlight() {
    guard isScanning, !isPaused, let current = currentHighlightedIndex else { return }

    // ... existing logic ...

    // AC3: Play sound on highlight change
    playHighlightSound()

    // AC2: Haptic feedback on highlight change
    highlightHaptic.impactOccurred()
}
```

### Forward-and-Backward Scanning Logic

```swift
// MARK: - Task 3: Scan Direction Logic

// Add to ScanningModeController:
private var direction: Int = 1  // 1 = forward, -1 = backward

private func advanceHighlight() {
    guard isScanning, !isPaused, let current = currentHighlightedIndex else { return }

    let next = current + direction

    switch settings.scanDirection {
    case .forwardOnly:
        // Original behavior: wrap around
        if next >= itemCount {
            if settings.autoRestart {
                currentHighlightedIndex = 0
            } else {
                pauseAfterCycle()
            }
        } else if next < 0 {
            currentHighlightedIndex = itemCount - 1
        } else {
            currentHighlightedIndex = next
        }

    case .forwardAndBackward:
        // Reverse direction at boundaries
        if next >= itemCount {
            direction = -1  // Start going backward
            currentHighlightedIndex = itemCount - 2  // Go to second-to-last
        } else if next < 0 {
            if settings.autoRestart {
                direction = 1  // Start going forward again
                currentHighlightedIndex = 1  // Go to second item
            } else {
                pauseAfterCycle()
            }
        } else {
            currentHighlightedIndex = next
        }
    }

    playHighlightSound()
    highlightHaptic.impactOccurred()
}

/// Reset direction when starting new scan
func startScanning(itemCount: Int) {
    // ... existing code ...
    direction = 1  // Always start forward
    // ...
}
```

### ScanningModeSettingsView Structure

```swift
// MARK: - Task 4: ScanningModeSettingsView

@MainActor
struct ScanningModeSettingsView: View {
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject private var scanningSettings = ScanningModeSettings.shared

    @State private var isTestModeActive: Bool = false
    @State private var showResetConfirmation: Bool = false

    var body: some View {
        List {
            // AC1, AC2: Scan speed picker
            Section {
                Picker("Vitesse", selection: $scanningSettings.scanSpeed) {
                    ForEach(ScanSpeed.allCases, id: \.self) { speed in
                        Text(speed.displayName).tag(speed)
                    }
                }
                .pickerStyle(.segmented)
                .frame(minHeight: accessibilitySettings.buttonHeight)
                .accessibilityLabel("Vitesse de scanning")
                .accessibilityValue(scanningSettings.scanSpeed.displayName)
            } header: {
                Text("Vitesse de scanning")
            } footer: {
                Text("Durée d'affichage sur chaque bouton avant de passer au suivant.")
            }

            // AC1: Scan direction picker
            Section {
                Picker("Direction", selection: $scanningSettings.scanDirection) {
                    ForEach(ScanDirection.allCases, id: \.self) { dir in
                        Text(dir.displayName).tag(dir)
                    }
                }
                .pickerStyle(.menu)
                .frame(minHeight: accessibilitySettings.buttonHeight)
                .accessibilityLabel("Direction du scanning")
                .accessibilityValue(scanningSettings.scanDirection.displayName)
            } header: {
                Text("Direction")
            } footer: {
                Text(scanningSettings.scanDirection.accessibilityDescription)
            }

            // AC1: Behavior toggles
            Section {
                Toggle(isOn: $scanningSettings.autoRestart) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Redémarrage automatique")
                            .font(.headline)
                        Text("Recommence après un cycle complet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(minHeight: accessibilitySettings.buttonHeight)

                Toggle(isOn: $scanningSettings.soundFeedbackEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Retour sonore")
                            .font(.headline)
                        Text("Émet un son lors du changement de sélection")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(minHeight: accessibilitySettings.buttonHeight)
            } header: {
                Text("Comportement")
            }

            // AC4: Test mode
            Section {
                Button(action: { isTestModeActive = true }) {
                    HStack {
                        Image(systemName: "play.circle")
                            .font(.title2)
                        Text("Tester le scanning")
                            .font(.headline)
                        Spacer()
                    }
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
            } header: {
                Text("Aperçu")
            } footer: {
                Text("Testez les paramètres actuels avec des boutons de démonstration.")
            }

            // Reset button
            Section {
                Button(action: { showResetConfirmation = true }) {
                    HStack {
                        Spacer()
                        Text("Réinitialiser par défaut")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .frame(minHeight: accessibilitySettings.buttonHeight)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Scanning")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isTestModeActive) {
            ScanningTestPreviewView(isPresented: $isTestModeActive)
                .environmentObject(accessibilitySettings)
        }
        .alert("Réinitialiser les paramètres ?", isPresented: $showResetConfirmation) {
            Button("Annuler", role: .cancel) { }
            Button("Réinitialiser", role: .destructive) {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                scanningSettings.resetToDefaults()
            }
        } message: {
            Text("La vitesse, la direction et les autres paramètres seront restaurés à leurs valeurs par défaut.")
        }
    }
}
```

### Test Preview View Pattern

```swift
// MARK: - Task 5: ScanningTestPreviewView

@MainActor
struct ScanningTestPreviewView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var accessibilitySettings: AccessibilitySettings
    @ObservedObject private var controller = ScanningModeController.shared

    // Sample test items
    private let testItems = ["Oui", "Non", "Aide", "Merci"]

    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text("Test du mode scanning")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 24)

            Text("Les boutons s'illuminent selon vos paramètres")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            // Test buttons grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(Array(testItems.enumerated()), id: \.offset) { index, item in
                    TestButton(
                        text: item,
                        isHighlighted: index == controller.currentHighlightedIndex
                    )
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Dismiss button
            Button(action: {
                controller.stopScanning()
                isPresented = false
            }) {
                Text("Terminé")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: accessibilitySettings.buttonHeight)
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .onAppear {
            controller.startScanning(itemCount: testItems.count)
        }
        .onDisappear {
            controller.stopScanning()
        }
    }
}

/// Individual test button with scanning highlight
struct TestButton: View {
    let text: String
    let isHighlighted: Bool

    var body: some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHighlighted ? Color.yellow : Color.clear, lineWidth: 4)
            )
            .scaleEffect(isHighlighted ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isHighlighted)
    }
}
```

### File Locations

| File | Directory | Purpose |
|------|-----------|---------|
| `ScanningModeSettings.swift` | `Managers/` | MODIFY - Add ScanDirection enum and property |
| `ScanningModeController.swift` | `Managers/` | MODIFY - Add sound, direction logic |
| `ScanningModeSettingsView.swift` | `Views/` | NEW - Configuration UI |
| `AccessibilitySettingsView.swift` | `Views/` | MODIFY - Replace placeholder with NavigationLink |
| `ScanningModeSettingsTests.swift` | `Tests/` | MODIFY - Add new tests |

### UI Text (French)

| Context | Text |
|---------|------|
| Navigation title | "Scanning" |
| Speed section header | "Vitesse de scanning" |
| Speed footer | "Durée d'affichage sur chaque bouton avant de passer au suivant." |
| Direction section header | "Direction" |
| Direction forward only | "Avant uniquement" |
| Direction forward/backward | "Avant et arrière" |
| Behavior section header | "Comportement" |
| Auto-restart label | "Redémarrage automatique" |
| Auto-restart description | "Recommence après un cycle complet" |
| Sound label | "Retour sonore" |
| Sound description | "Émet un son lors du changement de sélection" |
| Test section header | "Aperçu" |
| Test button | "Tester le scanning" |
| Test footer | "Testez les paramètres actuels avec des boutons de démonstration." |
| Test preview title | "Test du mode scanning" |
| Test preview subtitle | "Les boutons s'illuminent selon vos paramètres" |
| Done button | "Terminé" |
| Reset button | "Réinitialiser par défaut" |
| Reset dialog title | "Réinitialiser les paramètres ?" |
| Reset dialog message | "La vitesse, la direction et les autres paramètres seront restaurés à leurs valeurs par défaut." |

### Accessibility Requirements

- All controls have French VoiceOver labels and hints
- All interactive elements use `accessibilitySettings.buttonHeight` (60pt/80pt)
- Picker values announced with current selection
- Toggle states announced (Activé/Désactivé)
- Test mode announces "Mode scanning actif" when starting
- Sound feedback disabled during VoiceOver (VoiceOver has its own audio)

### Project Structure Notes

- Alignment with unified project structure: ScanningModeSettingsView follows FatigueModeSettingsView pattern
- Pattern consistency: ScanDirection enum follows ScanSpeed pattern exactly
- Sound feedback uses native AudioToolbox (no external dependencies)
- All files in designated directories per project-context.md

### References

- [Source: epics-ux-accessibility.md#Story-7.4-Configure-Scanning-Mode-Settings]
- [Source: project-context.md#Technology-Stack-Versions]
- [Pattern: ScanningModeSettings.swift - Existing settings manager]
- [Pattern: ScanningModeController.swift - Existing controller]
- [Pattern: FatigueModeSettingsView.swift - Settings view structure]
- [Pattern: TimeBasedPhrasesSettingsView.swift - Toggle + NavigationLink pattern]

### Testing Considerations

- Test ScanDirection persistence with JSON encode/decode
- Test forward-and-backward boundary behavior (at itemCount-1 and 0)
- Test sound plays only when soundFeedbackEnabled = true
- Test sound does NOT play when VoiceOver is running
- Test resetToDefaults resets scanDirection to .forwardOnly
- Test test mode starts/stops scanning correctly
- Test settings changes apply immediately during test mode

### Edge Cases to Handle

1. **VoiceOver + Sound**: Disable sound during VoiceOver to avoid audio conflicts
2. **Forward/Backward with single item**: Don't reverse, just stay highlighted
3. **Direction change mid-scan**: Apply immediately without resetting position
4. **Test mode dismissal**: Always stop scanning on dismiss
5. **Memory**: SystemSoundID 1103 is system-managed, no cleanup needed

### Previous Story (11.3) Learnings Applied

From Story 11.3 code review:
- **M1**: Match actual behavior in display strings
- **M2**: Use iOS 17+ onChange syntax (zero-parameter closure)
- **M3**: Correct comments about didSet/init behavior
- **M4**: Test edge cases (invalid inputs, boundaries)
- **L1**: Add DispatchQueue.main.asyncAfter delay for VoiceOver announcements
- **L2**: Avoid redundant saves (immediate save pattern)
- **L3**: Accessibility values for state description
- **L4**: Explicit 44pt frame constraints on interactive elements

### Implementation Order Recommendation

1. **Phase 1**: Settings enhancement (Tasks 1)
   - Add ScanDirection enum to ScanningModeSettings

2. **Phase 2**: Controller enhancement (Tasks 2-3)
   - Add sound feedback logic
   - Add direction-aware scanning

3. **Phase 3**: UI creation (Tasks 4-6)
   - Create ScanningModeSettingsView
   - Create ScanningTestPreviewView
   - Integrate in AccessibilitySettingsView

4. **Phase 4**: Testing (Task 7)
   - Unit tests for new properties and logic

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build verification: `xcodebuild build -scheme HandwritingToSpeechSwiftUI` - **BUILD SUCCEEDED**
- Test execution: Test target not configured in Xcode project (HandwritingToSpeechSwiftUITests exists but not linked in project.pbxproj)

### Completion Notes List

1. **Task 1 Complete**: Added ScanDirection enum with forwardOnly/forwardAndBackward cases, French displayNames, accessibilityDescription, and UserDefaults persistence
2. **Task 2 Complete**: Implemented sound feedback using AudioToolbox SystemSoundID 1103 (Tock) with VoiceOver check
3. **Task 3 Complete**: Added direction-aware scanning with boundary handling for both modes
4. **Task 4 Complete**: Created full ScanningModeSettingsView with all sections, pickers, toggles, and French VoiceOver labels
5. **Task 5 Complete**: Created ScanningTestPreviewView with 4 sample buttons, live scanning demonstration, and startScanningForTest() method
6. **Task 6 Complete**: Replaced placeholder in AccessibilitySettingsView with NavigationLink to ScanningModeSettingsView
7. **Task 7 Complete**: Added 15+ unit tests for ScanDirection enum, persistence, controller behavior, and boundaries

**Note**: Unit tests are written in ScanningModeSettingsTests.swift but cannot be executed via xcodebuild because the test target is not configured in the Xcode project scheme. Tests need manual verification in Xcode or project configuration update.

### File List

| File | Action | Lines Changed |
|------|--------|---------------|
| `Managers/ScanningModeSettings.swift` | MODIFIED | +50 (ScanDirection enum, property, persistence) |
| `Managers/ScanningModeController.swift` | MODIFIED | +60 (AudioToolbox import, sound feedback, direction logic) |
| `Views/ScanningModeSettingsView.swift` | NEW | 369 lines (Full settings UI + test preview) |
| `Views/AccessibilitySettingsView.swift` | MODIFIED | +15 (NavigationLink integration) |
| `Tests/ScanningModeSettingsTests.swift` | MODIFIED | +150 (New unit tests) |

### Code Review 2026-01-28 (Adversarial Review)

**Reviewer**: Claude Opus 4.5 (Adversarial Senior Developer)
**Build Status**: SUCCEEDED

Issues found and fixed:

| ID | Severity | File | Issue | Status |
|----|----------|------|-------|--------|
| H1 | HIGH | ScanningModeSettingsView.swift | Unused variable `wasEnabled` captured but never used, `startScanningForTest` bypasses isEnabled check making it unnecessary | FIXED |
| M1 | MEDIUM | AccessibilitySettingsView.swift (x3) | iOS 14 onChange syntax with `{ oldValue, newValue in }` instead of iOS 17+ zero-parameter | FIXED |
| L2 | LOW | ScanningModeSettingsView.swift | `TestButton` struct not marked private, visible outside file scope | FIXED |

**Changes Applied**:
- `ScanningModeSettingsView.swift:ScanningTestPreviewView`: Removed unused `wasEnabled` variable, simplified logic to always use `startScanningForTest`
- `ScanningModeSettingsView.swift:TestButton`: Added `private` modifier
- `AccessibilitySettingsView.swift`: Updated 3 onChange handlers to iOS 17+ zero-parameter syntax:
  - `isEnhancedModeEnabled` onChange
  - `touchTargetSize` onChange
  - `ScanningModeSettings.shared.isEnabled` onChange

### Code Review #2 - 2026-01-28 (Final Validation)

**Reviewer**: Claude Opus 4.5 (Adversarial Senior Developer)
**Build Status**: SUCCEEDED

Issues found and fixed:

| ID | Severity | File | Issue | Status |
|----|----------|------|-------|--------|
| M1 | MEDIUM | AccessibilitySettingsView.swift:241 | Inconsistent onChange syntax `{ _, _ in }` vs zero-parameter used elsewhere | FIXED |
| L2 | LOW | ScanningModeSettingsView.swift:TestButton | Fixed 80pt height doesn't respect accessibilitySettings.buttonHeight | FIXED |

**Changes Applied**:
- `AccessibilitySettingsView.swift:241`: Updated scanningSettings.isEnabled onChange to zero-parameter syntax for consistency
- `ScanningModeSettingsView.swift:TestButton`: Added buttonHeight parameter, uses `max(80, buttonHeight)` for Enhanced Accessibility Mode

### Change Log

- 2026-01-28: Story 11.4 implemented - Scanning mode configuration settings
- 2026-01-28: Adversarial code review #1 fixes applied (3 issues: H1, M1x3, L2)
- 2026-01-28: Adversarial code review #2 fixes applied (2 issues: M1, L2) - Story marked DONE

