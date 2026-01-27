# Story 5.2: Enlarge Guidance Controls Touch Targets

Status: done

## Story

As a user with tremors,
I want guidance context buttons to have larger touch targets (minimum 60pt height),
So that I can select conversation contexts without difficulty.

## Acceptance Criteria

1. **AC1: Minimum Height**
   - **Given** the GuidanceControlsView is displayed
   - **When** I view any guidance button
   - **Then** the button has a minimum height of 60pt

2. **AC2: Horizontal Padding**
   - **Given** a guidance button is displayed
   - **When** I view the button
   - **Then** the button has horizontal padding of at least 20pt

3. **AC3: Font Size**
   - **Given** guidance buttons are displayed
   - **When** I view the text on any button
   - **Then** the font size is `.body` or larger

4. **AC4: Button Spacing**
   - **Given** multiple guidance buttons are displayed
   - **When** I view the spacing between buttons
   - **Then** the spacing between buttons is at least 12pt

## Tasks / Subtasks

- [x] Task 1: Increase GuidanceButton minimum height (AC: 1)
  - [x] 1.1: Add `.frame(minHeight: 60)` modifier to GuidanceButton
  - [x] 1.2: Increase vertical padding from 8pt to 16pt
  - [x] 1.3: Verify touch target meets 60pt minimum (code verified, device test pending)

- [x] Task 2: Increase horizontal padding (AC: 2)
  - [x] 2.1: Change `.padding(.horizontal, 14)` to `.padding(.horizontal, 20)`
  - [x] 2.2: Verify button width increases appropriately (code verified, device test pending)

- [x] Task 3: Increase font size (AC: 3)
  - [x] 3.1: Change `.font(.subheadline)` to `.font(.body)`
  - [x] 3.2: Change icon font from `.system(size: 14)` to `.system(size: 16)` for proportional scaling
  - [x] 3.3: Verify text remains readable and well-proportioned (code verified, device test pending)

- [x] Task 4: Adjust container spacing (AC: 4)
  - [x] 4.1: Update HStack spacing from 10pt to 12pt
  - [x] 4.2: Verify buttons don't overflow horizontally (code verified, device test pending)

- [x] Task 5: Apply Story 5.1 accessibility improvements
  - [x] 5.1: Upgrade haptic feedback from `.light` to `.medium` (per Story 5.1 pattern)
  - [x] 5.2: Adjust corner radius proportionally (20pt to 24pt, matching Story 5.1)

## Dev Notes

### Target File

**Primary file to modify:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift`

### Current Implementation Analysis

```swift
// CURRENT STATE (lines 82-104) - GuidanceButton component
Button(action: action) {
    HStack(spacing: 6) {
        Image(systemName: context.icon)
            .font(.system(size: 14))      // ISSUE: Too small
        Text(context.displayName)
            .font(.subheadline)           // ISSUE: Too small, needs .body
            .fontWeight(.medium)
    }
    .padding(.horizontal, 14)             // ISSUE: Needs 20pt
    .padding(.vertical, 8)                // ISSUE: Results in ~35pt height
    .background(isSelected ? Color.accentColor : Color(.systemGray5))
    .foregroundColor(isSelected ? .white : .primary)
    .cornerRadius(20)
}
.buttonStyle(ScaleButtonStyle(scaleAmount: 0.95, pressedColor: .clear, normalColor: .clear))
```

```swift
// CURRENT STATE (line 32) - HStack spacing
HStack(spacing: 10) {                     // ISSUE: Needs 12pt
    ForEach(GuidanceContext.allCases) { context in
```

```swift
// CURRENT STATE (line 54) - Haptic feedback
let impact = UIImpactFeedbackGenerator(style: .light)  // ISSUE: Too weak for accessibility
```

### Required Changes Summary

| Property | Current | Target | Change |
|----------|---------|--------|--------|
| Text Font | `.subheadline` | `.body` | Increase |
| Icon Font | `.system(size: 14)` | `.system(size: 16)` | +2pt |
| Horizontal padding | 14pt | 20pt | +6pt |
| Vertical padding | 8pt | 16pt | +8pt |
| Min height | ~35pt (calculated) | 60pt | Add `.frame(minHeight: 60)` |
| HStack spacing | 10pt | 12pt | +2pt |
| Haptic style | `.light` | `.medium` | Increase |
| Corner radius | 20pt | 24pt | +4pt (proportional) |

### Code Change Template

Following the exact pattern from Story 5.1 (KeywordChipsView):

```swift
// GuidanceButton - AFTER changes (frame after cornerRadius for consistency with Story 5.1)
Button(action: action) {
    HStack(spacing: 6) {
        Image(systemName: context.icon)
            .font(.system(size: 16))      // Story 5.2: Increased from 14 (AC3)
        Text(context.displayName)
            .font(.body)                  // Story 5.2: Increased from .subheadline (AC3)
            .fontWeight(.medium)
    }
    .padding(.horizontal, 20)             // Story 5.2: Increased from 14 (AC2)
    .padding(.vertical, 16)               // Story 5.2: Increased from 8 (AC1)
    .background(isSelected ? Color.accentColor : Color(.systemGray5))
    .foregroundColor(isSelected ? .white : .primary)
    .cornerRadius(24)                     // Story 5.2: Proportional increase from 20
    .frame(minHeight: 60)                 // Story 5.2: Explicit 60pt minimum (AC1) - after styling
}
```

```swift
// HStack spacing - AFTER change
HStack(spacing: 12) {                     // Story 5.2: Increased from 10 (AC4)
```

```swift
// Haptic feedback - AFTER change
let impact = UIImpactFeedbackGenerator(style: .medium)  // Story 5.2: Accessibility improvement
```

### Architecture Compliance

1. **SwiftUI Patterns**: Keep `@MainActor` annotation on view components
2. **No External Dependencies**: Use native SwiftUI modifiers only
3. **Accessibility Labels**: Existing `.accessibilityLabel()` and `.accessibilityHint()` must be preserved
4. **Button Style**: Keep `ScaleButtonStyle` for consistent press feedback
5. **Disabled State**: Preserve `.disabled(isDisabled)` and `.opacity(isDisabled ? 0.5 : 1.0)` logic (H1 Fix)

### Existing Code Patterns to Follow

From `GuidanceControlsView.swift`:
- Use `@ObservedObject` for SuggestionService.shared
- Haptic feedback via `UIImpactFeedbackGenerator`
- Accessibility labels in French
- H1 Fix pattern: isDisabled parameter to prevent race conditions during loading

From Story 5.1 `KeywordChipsView.swift` (reference):
- `.frame(minHeight: 60)` modifier placement (after cornerRadius, wrapping the styled content)
- Proportional corner radius adjustment (20pt → 24pt)
- Haptic upgrade pattern (.light → .medium)

### Impact on Layout

- GuidanceControlsView is embedded in ContentView at line 139
- Larger buttons will occupy more vertical space in the horizontal scroll
- Horizontal scroll still active (modal menu is Story 6-1)
- No changes needed to parent container
- Header "Guide rapide" remains unchanged

### Testing Checklist

- [x] Build succeeds without errors
- [x] Code changes match acceptance criteria
- [ ] Visual inspection: buttons appear larger (requires device/simulator)
- [ ] Touch target test: 60pt minimum verified (requires device/simulator)
- [ ] Accessibility Inspector: confirms touch target size (requires Xcode tool)
- [ ] Haptic feedback: felt on tap (requires physical device)
- [ ] No layout overflow on iPad (requires device/simulator)
- [ ] VoiceOver still works correctly (requires device/simulator)
- [ ] Button disabled state still works during loading (H1 Fix preserved)
- [ ] Selected state styling still works (color changes on selection)

### Project Structure Notes

- File location: `Views/GuidanceControlsView.swift` (correct directory per project structure)
- No new files required
- No model changes needed
- No service layer changes needed

### References

- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift] - Primary target file
- [Source: _bmad-output/planning-artifacts/epics-ux-accessibility.md#Story 1.2] - Requirements
- [Source: HandwritingToSpeechSwiftUI/docs/audit-ux-accessibilite.md#Section 6.2] - UX audit recommendations
- [Source: _bmad-output/project-context.md] - Technical rules
- [Source: _bmad-output/implementation-artifacts/5-1-enlarge-keyword-chips-touch-targets.md] - Previous story reference

### UX Audit Context

From `audit-ux-accessibilite.md`:
- **Current Score:** Touch target size = 4/10
- **Standard:** Apple HIG recommends minimum 44x44pt, ideally 60pt for accessibility
- **Measured current height:** ~30-35pt (padding 8v + font = insufficient)
- **Target users:** ALS, MS, Parkinson's, muscular dystrophy - tremor tolerance required
- **Additional note:** Scroll horizontal = geste difficile avec tremblements

### Previous Story Intelligence (Story 5.1)

**Learnings from Story 5.1 implementation:**
- `.frame(minHeight: 60)` modifier works correctly for ensuring 60pt minimum
- Proportional corner radius adjustment (20pt → 24pt) maintains visual harmony
- Haptic upgrade from `.light` to `.medium` provides stronger accessibility confirmation
- Inline comments referencing Story and ACs help with traceability
- Build succeeded without issues after applying the pattern

**Code review fixes applied in Story 5.1:**
- Remove any unused `@State` variables if present
- Remove any debug `print()` statements
- Document corner radius change in Dev Notes

### Git Intelligence

**Recent relevant commits:**
- `914fcc5` - InvincibleVoice features implementation
- `000363f` - Story 4.2 guidance controls initial implementation

**Pattern established:** Story implementations use inline comments referencing Story ID and AC numbers.

### Related Stories (Do NOT implement in this story)

- **Story 6-1:** Create Modal Menu for Guidance Contexts (replaces horizontal scroll - different story)
- **Story 7-2:** Enhanced Accessibility mode with 80pt targets (future epic)

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded: xcodebuild build completed without errors
- No compilation warnings related to GuidanceControlsView changes

### Completion Notes List

- **AC1 Satisfied**: Added `.frame(minHeight: 60)` and increased vertical padding from 8pt to 16pt ensuring 60pt minimum touch target
- **AC2 Satisfied**: Horizontal padding increased from 14pt to 20pt
- **AC3 Satisfied**: Text font changed from `.subheadline` to `.body`, icon font increased from 14pt to 16pt for proportional scaling
- **AC4 Satisfied**: HStack spacing increased from 10pt to 12pt for better button separation
- **Haptic improvement**: Feedback upgraded from `.light` to `.medium` for stronger accessibility confirmation (per Story 5.1 pattern)
- **Corner radius**: Adjusted from 20pt to 24pt to maintain proportional appearance with larger buttons
- All changes documented with inline comments referencing Story 5.2 and specific ACs
- H1 Fix preserved: isDisabled state and opacity logic maintained for race condition prevention

### Change Log

- 2026-01-27: Story 5.2 implementation complete - enlarged guidance controls touch targets for accessibility
- 2026-01-27: Code review fixes applied - corrected frame modifier placement for consistency with Story 5.1

### File List

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/GuidanceControlsView.swift` - Modified

## Senior Developer Review (AI)

**Review Date:** 2026-01-27
**Reviewer:** Claude Opus 4.5 (Adversarial Code Review)
**Outcome:** Approved with fixes applied

### Summary

All acceptance criteria are correctly implemented. One consistency issue was identified and corrected during review.

### Issues Found and Resolved

| Severity | Issue | Resolution |
|----------|-------|------------|
| MEDIUM | `.frame(minHeight: 60)` placement inconsistent with Story 5.1 pattern | Moved frame modifier after `.cornerRadius()` to match KeywordChipsView pattern |
| MEDIUM | Code changes not committed to git | Documented - ready for commit |
| LOW | Story file not tracked in git | Documented - ready for commit |

### Final Assessment

Code changes correctly implement all 4 acceptance criteria. Build succeeds. Frame placement corrected for cross-story consistency. Story ready for device testing and deployment.
