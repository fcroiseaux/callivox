---
stepsCompleted: ["step-01-validate-prerequisites", "step-02-design-epics", "step-03-create-stories", "step-04-final-validation"]
inputDocuments: ["docs/audit-ux-accessibilite.md"]
status: complete
---

# CalliVox - UX Accessibility Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for CalliVox UX Accessibility improvements, decomposing the requirements from the UX Accessibility Audit into implementable stories for users with degenerative diseases (ALS, MS, Parkinson's, etc.).

## Requirements Inventory

### Functional Requirements

FR1: Enlarge KeywordChipsView touch targets to minimum 60pt height
FR2: Enlarge GuidanceControlsView touch targets to minimum 60pt height
FR3: Enlarge SuggestionView header buttons (refresh/dismiss) to minimum 44pt
FR4: Replace horizontal scroll with grid layout in KeywordChipsView
FR5: Replace horizontal scroll with modal menu in GuidanceControlsView
FR6: Reorganize sidebar separating actions from settings
FR7: Create "Enhanced Accessibility" mode with 80pt targets, increased contrast, reduced animations
FR8: Categorize quick phrases by theme (Needs, Social, Health)
FR9: Add recent phrases history
FR10: Add confirmation dialogs for destructive actions
FR11: Create emergency panel with critical messages
FR12: Create reduced fatigue mode with minimal interface
FR13: Implement time-based predictive phrases
FR14: Add scanning mode for severely reduced mobility

### NonFunctional Requirements

NFR1: All touch targets must meet Apple HIG minimum of 44x44pt
NFR2: Enhanced accessibility mode targets must be 60-80pt minimum
NFR3: Application must be usable with one hand only
NFR4: Interface must minimize cognitive load (max 4-6 simultaneous options)
NFR5: Animations must be disableable
NFR6: Visual contrast must meet WCAG 2.1 AA standards
NFR7: Haptic feedback must confirm all important actions

### Additional Requirements

- Pathology compatibility: ALS, MS, Parkinson's, muscular dystrophy, stroke sequelae
- Support for seated/lying position with iPad on stand
- Short but frequent sessions
- Priority essential communications (needs, pain, calls)
- Configuration possible by caregiver
- Tremor-tolerant gesture recognition
- Fatigue-aware interaction patterns

### FR Coverage Map

| FR | Epic | Story | Description |
|----|------|-------|-------------|
| FR1 | Epic 1 | 1.1 | Enlarge KeywordChipsView touch targets |
| FR2 | Epic 1 | 1.2 | Enlarge GuidanceControlsView touch targets |
| FR3 | Epic 1 | 1.3 | Enlarge SuggestionView header buttons |
| FR4 | Epic 1 | 1.4 | Replace scroll with grid in KeywordChipsView |
| FR5 | Epic 2 | 2.1 | Modal menu for guidance contexts |
| FR6 | Epic 2 | 2.2 | Reorganize sidebar |
| FR7 | Epic 3 | 3.1, 3.2, 3.3 | Enhanced accessibility mode |
| FR8 | Epic 4 | 4.1 | Categorize quick phrases |
| FR9 | Epic 4 | 4.2 | Recent phrases history |
| FR10 | Epic 3 | 3.4 | Confirmation dialogs |
| FR11 | Epic 5 | 5.1, 5.2, 5.3 | Emergency panel |
| FR12 | Epic 6 | 6.1, 6.2, 6.3 | Fatigue mode |
| FR13 | Epic 7 | 7.1, 7.2 | Time-based predictive phrases |
| FR14 | Epic 7 | 7.3, 7.4 | Scanning mode |

## Epic List

### Epic 1: Essential Touch Accessibility
Users with motor impairments can reliably interact with all core UI elements. All buttons reach minimum accessibility size (44-60pt), keyword chips display in a grid layout without scrolling, and users with tremors can tap confidently.

**FRs covered:** FR1, FR2, FR3, FR4

### Epic 2: Simplified Navigation
Users can access all features with fewer, larger, and more accessible controls. Modal menu replaces horizontal scrolling for guidance contexts, and sidebar is reorganized to separate actions from settings, reducing cognitive load.

**FRs covered:** FR5, FR6

### Epic 3: Accessibility Settings
Users can customize the accessibility level to match their specific needs. Enhanced Accessibility mode provides 80pt targets and high contrast, with confirmation dialogs protecting against accidental destructive actions.

**FRs covered:** FR7, FR10

### Epic 4: Quick Phrase Organization
Users can find and reuse common phrases quickly. Phrases are categorized by theme (Needs, Social, Health) and recent phrases history provides fast access to frequently used messages.

**FRs covered:** FR8, FR9

### Epic 5: Emergency Panel
Users can quickly communicate urgent needs. Dedicated emergency panel provides immediate access to critical messages (Call for help, Pain, Feeling unwell) with extra-large, high-contrast buttons accessible from any screen.

**FRs covered:** FR11

### Epic 6: Fatigue Mode
Users experiencing high fatigue can still communicate essential messages. Minimal interface mode displays only 4-6 full-width buttons at 100pt height, enabling communication with minimal effort.

**FRs covered:** FR12

### Epic 7: Smart Assistance
Users benefit from intelligent contextual help and alternative input methods. Time-based predictive phrases suggest relevant messages based on time of day, and scanning mode enables input for users with severely reduced mobility.

**FRs covered:** FR13, FR14

---

## Epic 1: Essential Touch Accessibility

Users with motor impairments can reliably interact with all core UI elements. All buttons reach minimum accessibility size (44-60pt), keyword chips display in a grid layout without scrolling, and users with tremors can tap confidently.

### Story 1.1: Enlarge Keyword Chips Touch Targets

As a user with motor impairments,
I want keyword chips to have larger touch targets (minimum 60pt height),
So that I can reliably tap on quick response keywords without missing.

**Acceptance Criteria:**

**Given** the KeywordChipsView is displayed with keywords
**When** I view any keyword chip
**Then** the chip has a minimum height of 60pt
**And** the chip has horizontal padding of at least 20pt
**And** the font size is increased to .body or larger
**And** haptic feedback confirms my tap

### Story 1.2: Enlarge Guidance Controls Touch Targets

As a user with tremors,
I want guidance context buttons to have larger touch targets (minimum 60pt height),
So that I can select conversation contexts without difficulty.

**Acceptance Criteria:**

**Given** the GuidanceControlsView is displayed
**When** I view any guidance button
**Then** the button has a minimum height of 60pt
**And** the button has horizontal padding of at least 20pt
**And** the font size is increased to .body or larger
**And** spacing between buttons is at least 12pt

### Story 1.3: Enlarge Suggestion Header Buttons

As a user with reduced fine motor control,
I want the refresh and dismiss buttons in the suggestions header to be larger (minimum 44pt),
So that I can easily refresh or close suggestions.

**Acceptance Criteria:**

**Given** the SuggestionView header is displayed
**When** I view the refresh button
**Then** the button has minimum dimensions of 44x44pt
**And** when I view the dismiss button
**Then** the button has minimum dimensions of 44x44pt
**And** spacing between header buttons is at least 12pt
**And** the "Autre" button maintains minimum 44pt height

### Story 1.4: Replace Horizontal Scroll with Grid for Keywords

As a user who has difficulty with swipe gestures,
I want keywords displayed in a grid layout instead of horizontal scroll,
So that I can see and access all keywords without swiping.

**Acceptance Criteria:**

**Given** keywords are available from the suggestion service
**When** the KeywordChipsView is displayed
**Then** keywords are shown in a LazyVGrid with adaptive columns (minimum 100pt)
**And** all keywords are visible without scrolling (if 12 or fewer)
**And** spacing between grid items is 12pt
**And** the grid layout works correctly in both portrait and landscape orientations

---

## Epic 2: Simplified Navigation

Users can access all features with fewer, larger, and more accessible controls. Modal menu replaces horizontal scrolling for guidance contexts, and sidebar is reorganized to separate actions from settings, reducing cognitive load.

### Story 2.1: Create Modal Menu for Guidance Contexts

As a user with limited hand mobility,
I want guidance contexts accessible via a modal menu instead of horizontal scrolling,
So that I can select a context with a simple tap without needing swipe gestures.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** I view the guidance controls area
**Then** I see a single dropdown button showing the current context (e.g., "Contexte: Conversation")
**And** when I tap the dropdown button
**Then** a full-screen modal opens with all context options

**Given** the context modal is open
**When** I view the available contexts
**Then** contexts are displayed in a 2-column grid
**And** each context button is minimum 150x100pt
**And** each button shows an icon and text label
**And** a close button (minimum 60pt) is visible at the bottom

**Given** the context modal is open
**When** I tap a context option
**Then** the modal closes
**And** the selected context is applied
**And** haptic feedback confirms my selection

### Story 2.2: Reorganize Sidebar Separating Actions from Settings

As a user with cognitive fatigue,
I want the sidebar to show only essential actions with settings in a separate menu,
So that I can quickly find the buttons I need without visual overload.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** I view the sidebar (ControlButtonsView)
**Then** I see a maximum of 5-6 buttons in the main area:
  - "PARLER" (primary action, largest: 200x80pt)
  - "Répéter" and "Effacer" (secondary actions: 95x60pt each, side by side)
  - "Mes phrases" (action: 200x50pt)
  - "Paramètres" (opens settings submenu: 200x50pt)
**And** user info remains at the bottom

**Given** I tap the "Paramètres" button
**When** the settings submenu opens
**Then** I see all configuration options previously in sidebar:
  - Usage, Voix, Gradium STT, Gradium TTS, IA Settings, Personnalisation
**And** each settings button is minimum 60pt height
**And** a back/close button allows returning to main sidebar

**Given** I am viewing the reorganized sidebar
**When** I compare to the previous layout
**Then** the number of visible buttons is reduced from 11+ to 5-6
**And** visual hierarchy clearly distinguishes primary from secondary actions
**And** the sidebar remains usable with one hand

---

## Epic 3: Accessibility Settings

Users can customize the accessibility level to match their specific needs. Enhanced Accessibility mode provides 80pt targets and high contrast, with confirmation dialogs protecting against accidental destructive actions.

### Story 3.1: Create Accessibility Settings Screen with Enhanced Mode

As a user with a degenerative disease,
I want an accessibility settings screen with an "Enhanced Accessibility" toggle,
So that I can enable features adapted to my level of motor impairment.

**Acceptance Criteria:**

**Given** I am in the Settings submenu
**When** I tap on "Accessibilité" (new menu item)
**Then** an accessibility settings screen opens

**Given** I am on the accessibility settings screen
**When** I view the available options
**Then** I see an "Accessibilité Renforcée" toggle switch
**And** I see a description explaining the mode: "Agrandit les cibles tactiles, augmente le contraste, réduit les animations"
**And** all controls on this screen are minimum 60pt height
**And** the toggle state is persisted in UserDefaults

**Given** Enhanced Accessibility mode is toggled
**When** I return to the main screen
**Then** the app applies the enhanced settings immediately
**And** no app restart is required

### Story 3.2: Implement Enlarged Touch Targets in Enhanced Mode

As a user with severe tremors,
I want all touch targets to be 80pt minimum when Enhanced Accessibility is enabled,
So that I can interact with the app more reliably during difficult periods.

**Acceptance Criteria:**

**Given** Enhanced Accessibility mode is enabled
**When** I view KeywordChipsView
**Then** all keyword chips have minimum 80pt height (instead of 60pt)

**Given** Enhanced Accessibility mode is enabled
**When** I view GuidanceControlsView or its modal
**Then** all buttons have minimum 80pt height

**Given** Enhanced Accessibility mode is enabled
**When** I view SuggestionView
**Then** suggestion cards have increased padding
**And** header buttons are minimum 60pt (instead of 44pt)

**Given** Enhanced Accessibility mode is enabled
**When** I view the sidebar
**Then** the primary "PARLER" button is 200x100pt
**And** secondary buttons are minimum 80pt height

**Given** Enhanced Accessibility mode is disabled
**When** I view any component
**Then** standard accessibility sizes apply (44-60pt)

### Story 3.3: Implement High Contrast and Reduced Animations

As a user with visual fatigue,
I want increased contrast and reduced animations when Enhanced Accessibility is enabled,
So that the interface is easier to see and less distracting.

**Acceptance Criteria:**

**Given** Enhanced Accessibility mode is enabled
**When** I view any text in the app
**Then** text uses high contrast colors (pure black on white, or pure white on dark backgrounds)
**And** secondary text opacity is increased from 0.6 to 0.8 minimum

**Given** Enhanced Accessibility mode is enabled
**When** I interact with buttons
**Then** scale animations are disabled or reduced to 0.98 (instead of 0.9-0.95)
**And** transition durations are reduced by 50%

**Given** Enhanced Accessibility mode is enabled
**When** I view the ListeningIndicator overlay
**Then** pulsing circle animations are simplified or disabled
**And** the microphone icon remains clearly visible

**Given** the system "Reduce Motion" setting is enabled
**When** I use the app regardless of Enhanced mode
**Then** the app respects the system setting

### Story 3.4: Add Confirmation Dialogs for Destructive Actions

As a user who sometimes taps accidentally,
I want confirmation dialogs before destructive actions,
So that I don't accidentally clear my text or dismiss important content.

**Acceptance Criteria:**

**Given** I have text in the input field
**When** I tap the "Effacer" button
**Then** a confirmation dialog appears: "Effacer le texte ?"
**And** the dialog has two buttons: "Annuler" (60pt) and "Effacer" (60pt, red)
**And** tapping outside the dialog cancels the action

**Given** I have active suggestions displayed
**When** I tap the dismiss (X) button in SuggestionView header
**Then** a confirmation dialog appears: "Masquer les suggestions ?"
**And** the dialog offers "Annuler" and "Masquer" options

**Given** Enhanced Accessibility mode is enabled
**When** any confirmation dialog appears
**Then** dialog buttons are minimum 80pt height
**And** button text is enlarged

**Given** Enhanced Accessibility mode is disabled
**When** I perform destructive actions
**Then** confirmation dialogs still appear (safety feature always active)
**Or** an optional setting allows disabling confirmations for experienced users

---

## Epic 4: Quick Phrase Organization

Users can find and reuse common phrases quickly. Phrases are categorized by theme (Needs, Social, Health) and recent phrases history provides fast access to frequently used messages.

### Story 4.1: Categorize Quick Phrases by Theme

As a user looking for a specific phrase,
I want quick phrases organized by category (Needs, Social, Health),
So that I can find the right phrase faster without scanning all options.

**Acceptance Criteria:**

**Given** I have preset phrases configured
**When** I view the SpeechShortcutsView
**Then** phrases are grouped under category headers
**And** default categories are: "Besoins", "Social", "Santé"

**Given** categories are displayed
**When** I view a category section
**Then** the category header shows an icon and label (e.g., "🍽️ Besoins")
**And** the header is visually distinct (larger font, separator line)
**And** phrases within the category are displayed in a grid below the header

**Given** I am in the phrase management screen (PhrasesListView)
**When** I add or edit a phrase
**Then** I can assign it to a category via a picker
**And** categories available are: Besoins, Social, Santé, Autre
**And** the category selection is persisted with the phrase

**Given** Enhanced Accessibility mode is enabled
**When** I view categorized phrases
**Then** category headers are minimum 60pt height
**And** phrase buttons remain minimum 80pt height

### Story 4.2: Add Recent Phrases History

As a user who repeats certain phrases frequently,
I want a "Recent" section showing my last used phrases,
So that I can quickly repeat common messages without searching.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** I have previously spoken phrases (via shortcuts or suggestions)
**Then** a "Récents" section appears above the categorized phrases
**And** it shows the 5 most recently used phrases

**Given** the "Récents" section is displayed
**When** I view it
**Then** each recent phrase shows the text and relative time ("il y a 5 min")
**And** phrases are displayed as tappable buttons (minimum 60pt height)
**And** tapping a recent phrase speaks it via TTS

**Given** I speak a phrase (from any source)
**When** the phrase is spoken
**Then** it is added to the recent history
**And** duplicates are moved to the top (not duplicated)
**And** history is limited to the 10 most recent entries
**And** history is persisted across app sessions (UserDefaults)

**Given** Enhanced Accessibility mode is enabled
**When** I view the "Récents" section
**Then** recent phrase buttons are minimum 80pt height
**And** the section header is clearly visible

**Given** I want to clear my history
**When** I long-press on the "Récents" header
**Then** a context menu offers "Effacer l'historique"
**And** confirmation is required before clearing

---

## Epic 5: Emergency Panel

Users can quickly communicate urgent needs. Dedicated emergency panel provides immediate access to critical messages (Call for help, Pain, Feeling unwell) with extra-large, high-contrast buttons accessible from any screen.

### Story 5.1: Add Emergency Panel Trigger

As a user who may need to communicate urgent needs,
I want an always-visible emergency button on the main screen,
So that I can quickly access critical messages at any time.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** I view the interface
**Then** an "URGENCE" button is visible in a fixed position
**And** the button is positioned at the top-right or in an easily reachable area
**And** the button has high contrast (red background, white text)
**And** the button is minimum 60pt height with clear "⚡ URGENCE" label

**Given** the emergency button is displayed
**When** I view it alongside other UI elements
**Then** it is always visible (not obscured by overlays except TranscriptionOverlay)
**And** it has a subtle but noticeable visual indicator (slight pulse or border)

**Given** Enhanced Accessibility mode is enabled
**When** I view the emergency button
**Then** the button is enlarged to minimum 80pt height
**And** contrast is maximum (pure red #FF0000)

### Story 5.2: Create Emergency Panel with Critical Messages

As a user in an urgent situation,
I want an emergency panel with large buttons for critical messages,
So that I can quickly communicate pain, need for help, or medical emergency.

**Acceptance Criteria:**

**Given** I tap the "URGENCE" button
**When** the emergency panel opens
**Then** a full-screen modal overlay appears
**And** the background is semi-transparent dark (0.85 opacity)
**And** the header shows "⚠️ URGENCE ⚠️" in large text

**Given** the emergency panel is open
**When** I view the available options
**Then** I see 4 large emergency buttons in a 2x2 grid:
  - "🚨 APPELER À L'AIDE" (Call for help)
  - "😰 J'AI MAL" (I'm in pain)
  - "🏥 MÉDECIN" (Doctor/Medical)
  - "😵 MALAISE" (Feeling unwell)
**And** each button is minimum 200x100pt
**And** buttons have high contrast colors
**And** a close button "✕ Fermer" (minimum 80pt) is at the bottom

**Given** I tap an emergency message button
**When** the action is triggered
**Then** the message is immediately spoken via TTS at maximum volume
**And** strong haptic feedback occurs (UIImpactFeedbackGenerator .heavy)
**And** the panel remains open for additional messages
**And** the spoken message is added to recent history

**Given** the emergency panel is open
**When** I tap the close button or the background
**Then** the panel closes
**And** I return to the main screen

**Given** TTS is currently playing
**When** I open the emergency panel and tap a message
**Then** the current TTS is interrupted
**And** the emergency message takes priority

### Story 5.3: Allow Emergency Message Customization

As a caregiver or user,
I want to customize the emergency panel messages,
So that the urgent messages match my specific needs.

**Acceptance Criteria:**

**Given** I am in the accessibility settings screen
**When** I tap on "Messages d'urgence"
**Then** a configuration screen opens showing the 4 emergency messages

**Given** I am on the emergency messages configuration screen
**When** I tap on a message slot
**Then** I can edit the message text
**And** I can select from predefined options or enter custom text
**And** changes are saved immediately

**Given** I have customized emergency messages
**When** I open the emergency panel
**Then** my custom messages are displayed
**And** icons remain consistent with message type

**Given** default emergency messages exist
**When** I reset to defaults
**Then** the original 4 messages are restored

---

## Epic 6: Fatigue Mode

Users experiencing high fatigue can still communicate essential messages. Minimal interface mode displays only 4-6 full-width buttons at 100pt height, enabling communication with minimal effort.

### Story 6.1: Add Fatigue Mode Trigger

As a user experiencing high fatigue,
I want an easy way to switch to a simplified interface mode,
So that I can still communicate when I have very limited energy.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** I view the sidebar
**Then** a "Mode Fatigue" button is visible in the actions section
**And** the button shows a clear icon (e.g., "😴" or moon icon) with label
**And** the button is minimum 60pt height

**Given** I am in the accessibility settings
**When** I view the options
**Then** I see a "Mode Fatigue" section with:
  - Toggle to enable/disable fatigue mode
  - Option to configure which messages appear in fatigue mode

**Given** Enhanced Accessibility mode is enabled
**When** I view the fatigue mode button
**Then** the button is minimum 80pt height

### Story 6.2: Create Minimal Fatigue Mode Interface

As a user with very limited energy,
I want an extremely simplified interface with only essential buttons,
So that I can communicate basic needs with minimal effort.

**Acceptance Criteria:**

**Given** I activate fatigue mode (via button or setting)
**When** the mode activates
**Then** a full-screen simplified interface replaces the main view
**And** the background is a calm, low-contrast color
**And** maximum 6 buttons are displayed

**Given** fatigue mode is active
**When** I view the interface
**Then** buttons are displayed in a single vertical column
**And** each button is full-width with 100pt minimum height
**And** text is large (.title or .largeTitle)
**And** only essential messages are shown:
  - "OUI"
  - "NON"
  - "APPELER"
  - "DOULEUR"
  - "SOIF" / "FAIM"
  - "Mode normal" (to exit)

**Given** fatigue mode is active
**When** I tap a message button
**Then** the message is spoken via TTS
**And** gentle haptic feedback confirms the action
**And** the interface remains in fatigue mode

**Given** fatigue mode is active
**When** I tap "Mode normal"
**Then** a confirmation appears: "Quitter le mode fatigue ?"
**And** confirming returns to the standard interface
**And** canceling keeps fatigue mode active

**Given** fatigue mode is active
**When** the app is closed and reopened
**Then** fatigue mode remains active (persisted state)
**And** user returns directly to simplified interface

### Story 6.3: Allow Fatigue Mode Button Customization

As a caregiver setting up the app,
I want to customize which messages appear in fatigue mode,
So that the simplified interface matches the user's specific needs.

**Acceptance Criteria:**

**Given** I am in the fatigue mode settings
**When** I view the configuration options
**Then** I see a list of 6 customizable message slots
**And** each slot shows the current message and an edit button

**Given** I tap edit on a message slot
**When** the edit interface opens
**Then** I can choose from predefined options:
  - Basic responses: Oui, Non, Peut-être, D'accord
  - Needs: Soif, Faim, Toilettes, Fatigue
  - Communication: Appeler, Aide, Merci, Pardon
  - Medical: Douleur, Malaise, Médicament
**And** I can enter custom text
**And** the message is saved when confirmed

**Given** I have customized fatigue mode messages
**When** I activate fatigue mode
**Then** my custom messages are displayed
**And** the "Mode normal" exit button is always present (cannot be removed)

**Given** I want to reset fatigue mode messages
**When** I tap "Réinitialiser" in settings
**Then** default messages are restored: Oui, Non, Appeler, Douleur, Soif, Mode normal

---

## Epic 7: Smart Assistance

Users benefit from intelligent contextual help and alternative input methods. Time-based predictive phrases suggest relevant messages based on time of day, and scanning mode enables input for users with severely reduced mobility.

### Story 7.1: Implement Time-Based Predictive Phrases

As a user with predictable daily routines,
I want the app to suggest relevant phrases based on the time of day,
So that I can quickly access contextually appropriate messages.

**Acceptance Criteria:**

**Given** I am on the main screen
**When** the app loads or refreshes suggestions
**Then** a "Suggestions du moment" section appears above other suggestions
**And** it displays 3-4 phrases relevant to the current time period

**Given** the current time is between 7h-9h (morning)
**When** I view time-based suggestions
**Then** suggestions include phrases like: "Bonjour", "Café", "Médicaments", "Petit-déjeuner"

**Given** the current time is between 12h-14h (lunch)
**When** I view time-based suggestions
**Then** suggestions include phrases like: "J'ai faim", "Repas", "Merci", "C'est bon"

**Given** the current time is between 18h-20h (evening)
**When** I view time-based suggestions
**Then** suggestions include phrases like: "Dîner", "Fatigué", "Télévision", "Merci"

**Given** the current time is between 21h-23h (night)
**When** I view time-based suggestions
**Then** suggestions include phrases like: "Bonne nuit", "Lit", "Lumière", "Toilettes"

**Given** I tap a time-based suggestion
**When** the action is triggered
**Then** the phrase is spoken via TTS
**And** it is added to recent history
**And** haptic feedback confirms the action

### Story 7.2: Allow Time-Based Phrase Customization

As a caregiver or user,
I want to customize which phrases appear for each time period,
So that suggestions match my specific daily routine.

**Acceptance Criteria:**

**Given** I am in the accessibility settings
**When** I tap on "Phrases du moment"
**Then** a configuration screen opens showing the 4 time periods

**Given** I am on the time-based phrases configuration
**When** I tap on a time period (e.g., "Matin 7h-9h")
**Then** I see the list of phrases for that period
**And** I can add, edit, or remove phrases
**And** each period supports 4-6 phrases

**Given** I edit phrases for a time period
**When** I save my changes
**Then** the custom phrases are used for that time period
**And** changes take effect immediately

**Given** I want to disable time-based suggestions
**When** I toggle off "Suggestions du moment" in settings
**Then** the section no longer appears on the main screen

### Story 7.3: Create Scanning Mode for Severely Reduced Mobility

As a user with severely reduced mobility,
I want a scanning mode where buttons highlight sequentially,
So that I can select options with a single tap or switch input.

**Acceptance Criteria:**

**Given** I am in the accessibility settings
**When** I view advanced options
**Then** I see a "Mode Scanning" toggle with description:
  "Les boutons s'illuminent tour à tour. Tapez pour sélectionner."

**Given** scanning mode is enabled
**When** I view any button group (keywords, phrases, suggestions)
**Then** buttons are highlighted one by one in sequence
**And** the highlight is a clear visual indicator (bright border, scale effect)
**And** each button is highlighted for a configurable duration (default: 2 seconds)

**Given** scanning mode is active and a button is highlighted
**When** I tap anywhere on the screen
**Then** the currently highlighted button is activated
**And** the action is performed (TTS, navigation, etc.)
**And** scanning pauses briefly then resumes from the next button

**Given** scanning mode is active
**When** I do not tap during a full scan cycle
**Then** scanning pauses after completing the cycle
**And** tapping anywhere restarts the scan

**Given** scanning mode is enabled
**When** I view the emergency panel or fatigue mode
**Then** scanning also works in these modes
**And** buttons are scanned in logical order (top to bottom, left to right)

### Story 7.4: Configure Scanning Mode Settings

As a caregiver setting up scanning mode,
I want to adjust scanning speed and behavior,
So that it matches the user's reaction time and preferences.

**Acceptance Criteria:**

**Given** scanning mode is enabled in settings
**When** I view scanning configuration options
**Then** I see the following adjustable parameters:
  - Scan speed: Slow (3s), Medium (2s), Fast (1s)
  - Scan direction: Forward only / Forward and backward
  - Auto-restart: On/Off
  - Sound feedback: On/Off (beep on highlight)

**Given** I adjust the scan speed
**When** I select "Slow (3s)"
**Then** each button is highlighted for 3 seconds
**And** the change takes effect immediately

**Given** sound feedback is enabled
**When** a button is highlighted during scanning
**Then** a subtle audio cue plays
**And** the sound is distinct and non-intrusive

**Given** I am testing scanning settings
**When** I tap "Tester le scanning"
**Then** a preview mode activates showing scanning behavior
**And** I can adjust settings in real-time
**And** tapping "Terminé" saves settings and exits preview
