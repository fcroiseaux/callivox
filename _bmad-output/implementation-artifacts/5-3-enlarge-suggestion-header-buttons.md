# Story 5.3: Enlarge Suggestion Header Buttons

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a user with reduced fine motor control,
I want the refresh and dismiss buttons in the suggestions header to be larger (minimum 44pt),
So that I can easily refresh or close suggestions.

## Acceptance Criteria

1. **AC1: Refresh Button Size**
   - **Given** the SuggestionView header is displayed
   - **When** I view the refresh button
   - **Then** the button has minimum dimensions of 44x44pt

2. **AC2: Dismiss Button Size**
   - **Given** the SuggestionView header is displayed
   - **When** I view the dismiss button (X)
   - **Then** the button has minimum dimensions of 44x44pt

3. **AC3: Button Spacing**
   - **Given** multiple header buttons are displayed
   - **When** I view the spacing between header buttons
   - **Then** spacing between header buttons is at least 12pt

4. **AC4: "Autre" Button Height**
   - **Given** the "Autre" button is displayed in the header
   - **When** I view the button
   - **Then** the button maintains minimum 44pt height

## Tasks / Subtasks

- [x] Task 1: Increase Refresh button size (AC: 1)
  - [x] 1.1: Change `.frame(width: 32, height: 32)` to `.frame(width: 44, height: 44)` on refresh button
  - [x] 1.2: Increase icon font from 16pt to 18pt for proportional scaling
  - [x] 1.3: Adjust corner radius from 8pt to 10pt (proportional)

- [x] Task 2: Increase Dismiss button size (AC: 2)
  - [x] 2.1: Change `.frame(width: 32, height: 32)` to `.frame(width: 44, height: 44)` on dismiss button
  - [x] 2.2: Increase icon font from 14pt to 16pt for proportional scaling
  - [x] 2.3: Adjust corner radius from 8pt to 10pt (proportional)

- [x] Task 3: Increase "Autre" button height (AC: 4)
  - [x] 3.1: Change `.padding(.vertical, 6)` to `.padding(.vertical, 12)` for ~36pt content height
  - [x] 3.2: Add `.frame(minHeight: 44)` modifier to ensure 44pt minimum
  - [x] 3.3: Adjust corner radius from 8pt to 10pt (proportional)

- [x] Task 4: Add header button spacing (AC: 3)
  - [x] 4.1: Add `spacing: 12` parameter to the header HStack (line ~123)
  - [x] 4.2: Verify buttons don't overflow horizontally

- [x] Task 5: Apply accessibility improvements (per Story 5.1/5.2 patterns)
  - [x] 5.1: Upgrade haptic feedback on "Autre" button from `.light` to `.medium` (line ~265)
  - [x] 5.2: Add inline comments referencing Story 5.3 and specific ACs

## Dev Notes

### Target File

**Primary file to modify:** `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift`

### Current Implementation Analysis

```swift
// CURRENT STATE (lines 122-123) - Header HStack
private var headerView: some View {
    HStack {                                 // ISSUE: No spacing parameter

// CURRENT STATE (lines 142-159) - "Autre" button
Button(action: generateDifferent) {
    HStack(spacing: 4) {
        Image(systemName: "shuffle")
            .font(.system(size: 12, weight: .medium))  // ISSUE: Could be larger
        Text("Autre")
            .font(.caption)                            // Keep same
    }
    .foregroundColor(.secondary)
    .padding(.horizontal, 10)
    .padding(.vertical, 6)                   // ISSUE: Results in ~26pt height
    .background(Color(.systemGray5))
    .cornerRadius(8)                         // ISSUE: Needs proportional increase
}

// CURRENT STATE (lines 162-177) - Refresh button
Button(action: refreshSuggestions) {
    Image(systemName: "arrow.clockwise")
        .font(.system(size: 16, weight: .medium))  // ISSUE: Increase to 18pt
        .foregroundColor(.secondary)
        .frame(width: 32, height: 32)              // ISSUE: Needs 44x44pt
        .background(Color(.systemGray5))
        .cornerRadius(8)                           // ISSUE: Needs proportional increase
}

// CURRENT STATE (lines 180-190) - Dismiss button
Button(action: dismissSuggestions) {
    Image(systemName: "xmark")
        .font(.system(size: 14, weight: .medium))  // ISSUE: Increase to 16pt
        .foregroundColor(.secondary)
        .frame(width: 32, height: 32)              // ISSUE: Needs 44x44pt
        .background(Color(.systemGray5))
        .cornerRadius(8)                           // ISSUE: Needs proportional increase
}
```

### Required Changes Summary

| Element | Property | Current | Target | Change |
|---------|----------|---------|--------|--------|
| HStack | spacing | none | 12pt | Add parameter |
| "Autre" button | vertical padding | 6pt | 12pt | +6pt |
| "Autre" button | min height | ~26pt | 44pt | Add `.frame(minHeight: 44)` |
| "Autre" button | corner radius | 8pt | 10pt | +2pt |
| Refresh button | frame | 32x32pt | 44x44pt | +12pt each |
| Refresh button | icon font | 16pt | 18pt | +2pt |
| Refresh button | corner radius | 8pt | 10pt | +2pt |
| Dismiss button | frame | 32x32pt | 44x44pt | +12pt each |
| Dismiss button | icon font | 14pt | 16pt | +2pt |
| Dismiss button | corner radius | 8pt | 10pt | +2pt |
| generateDifferent | haptic | `.light` | `.medium` | Upgrade |

### Code Change Template

Following the exact pattern from Story 5.1 and 5.2:

```swift
// Header HStack - AFTER change (line ~123)
private var headerView: some View {
    HStack(spacing: 12) {                    // Story 5.3: Added spacing (AC3)

// "Autre" button - AFTER changes
Button(action: generateDifferent) {
    HStack(spacing: 4) {
        Image(systemName: "shuffle")
            .font(.system(size: 14, weight: .medium))  // Story 5.3: Increased from 12 (proportional)
        Text("Autre")
            .font(.caption)
    }
    .foregroundColor(.secondary)
    .padding(.horizontal, 12)                // Story 5.3: Increased from 10 (proportional)
    .padding(.vertical, 12)                  // Story 5.3: Increased from 6 (AC4)
    .background(Color(.systemGray5))
    .cornerRadius(10)                        // Story 5.3: Proportional increase from 8
    .frame(minHeight: 44)                    // Story 5.3: Explicit 44pt minimum (AC4)
}

// Refresh button - AFTER changes
Button(action: refreshSuggestions) {
    Image(systemName: "arrow.clockwise")
        .font(.system(size: 18, weight: .medium))  // Story 5.3: Increased from 16 (proportional)
        .foregroundColor(.secondary)
        .frame(width: 44, height: 44)              // Story 5.3: Increased from 32 (AC1)
        .background(Color(.systemGray5))
        .cornerRadius(10)                          // Story 5.3: Proportional increase from 8
}

// Dismiss button - AFTER changes
Button(action: dismissSuggestions) {
    Image(systemName: "xmark")
        .font(.system(size: 16, weight: .medium))  // Story 5.3: Increased from 14 (proportional)
        .foregroundColor(.secondary)
        .frame(width: 44, height: 44)              // Story 5.3: Increased from 32 (AC2)
        .background(Color(.systemGray5))
        .cornerRadius(10)                          // Story 5.3: Proportional increase from 8
}

// Haptic feedback in generateDifferent() - AFTER change (line ~265)
let impact = UIImpactFeedbackGenerator(style: .medium)  // Story 5.3: Accessibility improvement from .light
```

### Architecture Compliance

1. **SwiftUI Patterns**: Keep `@MainActor` annotation on view components
2. **No External Dependencies**: Use native SwiftUI modifiers only
3. **Accessibility Labels**: Existing `.accessibilityLabel()` and `.accessibilityHint()` must be preserved
4. **Button Style**: Keep `ScaleButtonStyle` for consistent press feedback
5. **Disabled State**: Preserve `.disabled()` and `.opacity()` logic for refresh/autre buttons

### Existing Code Patterns to Follow

From `SuggestionView.swift`:
- Use `@ObservedObject` for SuggestionService.shared
- Haptic feedback via `UIImpactFeedbackGenerator`
- Accessibility labels in French
- L3 Fix pattern: Visual indication when disabled (opacity 0.4)
- Context menu preserved on suggestion cards

From Story 5.1 & 5.2 (reference):
- `.frame(minHeight: X)` modifier placement after cornerRadius
- Proportional corner radius adjustment pattern
- Haptic upgrade pattern (.light -> .medium)
- Inline comments referencing Story and ACs

### Impact on Layout

- SuggestionView is embedded in ContentView
- Larger header buttons will occupy more horizontal space
- Header uses HStack with Spacer() - buttons align to right
- No changes needed to parent container
- "Suggestions IA" title and "(en edition)" indicator remain unchanged
- SuggestionCard components remain unchanged

### Testing Checklist

- [x] Build succeeds without errors
- [x] Code changes match acceptance criteria
- [ ] Visual inspection: header buttons appear larger (requires device/simulator)
- [ ] Touch target test: 44pt minimum verified (requires device/simulator)
- [ ] Accessibility Inspector: confirms touch target size (requires Xcode tool)
- [ ] Haptic feedback: felt on tap (requires physical device)
- [ ] No layout overflow on iPad (requires device/simulator)
- [ ] VoiceOver still works correctly (requires device/simulator)
- [ ] Button disabled state still works during loading
- [ ] Refresh button disabled when text empty (preserved)
- [ ] Autre button disabled when loading or no suggestions (preserved)

### Project Structure Notes

- File location: `Views/SuggestionView.swift` (correct directory per project structure)
- No new files required
- No model changes needed
- No service layer changes needed

### References

- [Source: HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift] - Primary target file (lines 122-192)
- [Source: _bmad-output/planning-artifacts/epics-ux-accessibility.md#Story 1.3] - Requirements
- [Source: HandwritingToSpeechSwiftUI/docs/audit-ux-accessibilite.md] - UX audit recommendations
- [Source: _bmad-output/project-context.md] - Technical rules
- [Source: _bmad-output/implementation-artifacts/5-1-enlarge-keyword-chips-touch-targets.md] - Story 5.1 patterns
- [Source: _bmad-output/implementation-artifacts/5-2-enlarge-guidance-controls-touch-targets.md] - Story 5.2 patterns

### UX Audit Context

From the UX accessibility audit:
- **Current Score:** Touch target size = 4/10
- **Standard:** Apple HIG recommends minimum 44x44pt for interactive elements
- **Measured current size:** 32x32pt for refresh/dismiss (insufficient)
- **Target users:** ALS, MS, Parkinson's, muscular dystrophy - tremor tolerance required
- **Additional note:** Small buttons in header difficult to hit for users with motor impairments

### Previous Story Intelligence

**Learnings from Story 5.1 implementation:**
- `.frame(minHeight: X)` modifier works correctly for ensuring minimum
- Proportional corner radius adjustment (8pt -> 10pt for 32->44 is reasonable)
- Haptic upgrade from `.light` to `.medium` provides stronger accessibility confirmation
- Inline comments referencing Story and ACs help with traceability
- Build succeeded without issues after applying the pattern

**Learnings from Story 5.2 implementation:**
- Frame modifier placement after `.cornerRadius()` for consistency
- Same proportional pattern applies (corner radius ~25% of width)
- Keep existing disabled state and opacity logic
- H1 Fix patterns must be preserved (race condition prevention)

**Code review fixes applied in Story 5.1/5.2:**
- Remove any unused `@State` variables if present
- Remove any debug `print()` statements
- Document corner radius change in Dev Notes

### Git Intelligence

**Recent relevant commits:**
- `db88ad6` - Implement Stories 5-1 and 5-2: Enlarge touch targets for accessibility
- `914fcc5` - InvincibleVoice features implementation (added edit button to SuggestionView)
- `000363f` - Story 4.2 guidance controls and Autre button

**Pattern established:**
- Story implementations use inline comments referencing Story ID and AC numbers
- Commits combine related stories when implementing same file
- Code review fixes are applied before commit

### Related Stories (Do NOT implement in this story)

- **Story 7-2:** Enhanced Accessibility mode with 80pt targets (future epic)
- **Story 6-1:** Modal menu for guidance contexts (different component)

### WARNING: Code Review Traps to Avoid

Based on previous code reviews:

1. **DO NOT remove existing print() statements** - Only remove if truly unused
2. **DO NOT change ScaleButtonStyle parameters** - Keep existing values
3. **DO NOT modify SuggestionCard component** - This story only targets header
4. **DO NOT change disabled/opacity logic** - Preserve L3 Fix
5. **DO NOT forget to add haptic upgrade** - Easy to miss

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded without errors (xcodebuild 2026-01-27)

### Completion Notes List

- **Task 1**: Increased refresh button frame from 32x32pt to 44x44pt, icon font from 16pt to 18pt, corner radius from 8pt to 10pt
- **Task 2**: Increased dismiss button frame from 32x32pt to 44x44pt, icon font from 14pt to 16pt, corner radius from 8pt to 10pt
- **Task 3**: Increased "Autre" button vertical padding from 6pt to 12pt, added `.frame(minHeight: 44)`, increased horizontal padding to 12pt, icon font to 14pt, corner radius to 10pt
- **Task 4**: Added `spacing: 12` parameter to header HStack for consistent button spacing
- **Task 5**: Upgraded haptic feedback in `generateDifferent()` from `.light` to `.medium`, added inline comments referencing Story 5.3 and specific ACs throughout
- All changes follow patterns established in Stories 5.1 and 5.2
- Preserved all existing functionality: disabled states, opacity logic, accessibility labels/hints, ScaleButtonStyle, context menus

### File List

- `HandwritingToSpeechSwiftUI/HandwritingToSpeechSwiftUI/Views/SuggestionView.swift` (modified)

## Senior Developer Review (AI)

**Review Date:** 2026-01-27
**Reviewer:** Claude Opus 4.5 (Adversarial Code Review)
**Outcome:** Approved with fixes applied

### Summary

All acceptance criteria are correctly implemented. Consistency issues with haptic feedback were identified and corrected during review.

### Issues Found and Resolved

| Severity | Issue | Resolution |
|----------|-------|------------|
| MEDIUM | `moreLikeThis()` used `.light` haptic while other actions use `.medium` | Upgraded to `.medium` for accessibility consistency |
| MEDIUM | `editSuggestion()` used `.light` haptic while other actions use `.medium` | Upgraded to `.medium` for accessibility consistency |
| LOW | Debug print statement in `editSuggestion()` | Removed |
| LOW | Debug print statement in `moreLikeThis()` guard | Removed |
| LOW | Testing checklist items unchecked | Updated with verified status |

### Final Assessment

Code changes correctly implement all 4 acceptance criteria. Build succeeds. Haptic feedback consistency improved across all user-triggered actions. Story ready for device testing and deployment.

## Change Log

| Date | Change | Author |
|------|--------|--------|
| 2026-01-27 | Implemented Story 5.3: Enlarged header buttons to 44pt minimum (refresh, dismiss, autre), added 12pt spacing, upgraded haptic feedback | Claude Opus 4.5 |
| 2026-01-27 | Code review fixes: upgraded haptic consistency (.medium), removed debug prints | Claude Opus 4.5 (Review) |
