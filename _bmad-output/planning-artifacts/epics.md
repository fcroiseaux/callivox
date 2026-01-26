---
stepsCompleted: [1, 2, 3, 4]
status: 'complete'
completedAt: '2026-01-25'
inputDocuments:
  - "_bmad-output/planning-artifacts/prd-gradium-tts-migration.md"
  - "_bmad-output/planning-artifacts/architecture-gradium-tts-migration.md"
  - "invincible-voice/README.md"
project_name: CalliVox
feature_name: "InvincibleVoice Integration (Gradium TTS + LLM Suggestions)"
date: "2026-01-25"
---

# CalliVox - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for CalliVox, decomposing the requirements from the PRD, Architecture, and InvincibleVoice README into implementable stories. The scope covers both the Gradium TTS migration and the LLM multi-suggestion functionality.

## Requirements Inventory

### Functional Requirements

| ID | Description | Source |
|----|-------------|--------|
| FR-1 | **Gradium TTS Integration** - App sends text to Gradium TTS API and receives streaming PCM audio | PRD |
| FR-2 | **Streaming Audio Playback** - Audio plays as it streams, not after full download | PRD |
| FR-3 | **Offline Fallback to AVFoundation** - Use iOS native TTS when network unavailable | PRD |
| FR-4 | **Voice Selection Persistence** - User can select and persist voice preference | PRD |
| FR-5 | **TTS Provider Configuration** - App supports TTS provider configuration in AppConfig | PRD |
| FR-6 | **Error Handling with Graceful Degradation** - TTS errors handled gracefully, user always informed | PRD |
| FR-7 | **French Voice "Olivier" Support** - Default voice for French users is "Olivier" | PRD |
| FR-8 | **API Key Security** - Gradium API key stored securely in Keychain, never in source code | PRD |
| FR-9 | **LLM Multi-Suggestions** - LLM generates multiple possible responses for each context | README |
| FR-10 | **User Response Selection** - User selects which response to vocalize from suggestions | README |
| FR-11 | **LLM Personalization** - LLM can be personalized according to user needs | README |
| FR-12 | **UI Guidance Controls** - Interface allows guiding LLM responses | README |
| FR-13 | **LLM Service Integration** - Integration with OpenAI-compatible LLM service (Cerebras recommended) | README |

### Non-Functional Requirements

| ID | Description | Source |
|----|-------------|--------|
| NFR-1 | **Latency** - Time-to-first-audio-byte < 300ms (95th percentile) | PRD |
| NFR-2 | **Availability** - 99.9% TTS success rate (including fallbacks) | PRD |
| NFR-3 | **Audio Quality** - 24kHz sample rate, PCM format | PRD |
| NFR-4 | **Battery Impact** - < 5% battery drain per hour of active TTS use | PRD |
| NFR-5 | **Memory Usage** - < 50MB additional memory for streaming playback | PRD |
| NFR-6 | **Security** - All API calls over HTTPS, API keys in Keychain | PRD |
| NFR-7 | **Backward Compatibility** - Support iOS 16+ | PRD |
| NFR-8 | **LLM Latency** - Suggestions available < 500ms for fluid experience | README |
| NFR-9 | **LLM API Security** - LLM API key stored in Keychain, never in plaintext | README |

### Additional Requirements

**From Architecture Document:**

- **Brownfield Project** - No starter template needed, modify existing CalliVox iOS app
- **Protocol Abstraction** - `TTSProvider` protocol for future extensibility (Kyutai self-hosted option)
- **AVAudioEngine Required** - Use AVAudioEngine (not AVAudioPlayer) for PCM streaming at 24kHz
- **Complete ElevenLabs Removal** - Delete all existing ElevenLabs code during migration
- **Swift Patterns Required** - @MainActor, ObservableObject, async/await mandatory
- **Error Enum** - TTSError enum with LocalizedError protocol for French error messages
- **Network Check Mandatory** - NWPathMonitor check required before all API calls

**From InvincibleVoice README:**

- **OpenAI Compatible API** - LLM service must be compatible with OpenAI API format
- **Low Latency LLM** - Prefer low-latency LLM services (Cerebras recommended for throughput)
- **Multiple Suggestions Display** - UI must display multiple suggestions simultaneously
- **Selection Mechanism** - Clear mechanism for user to select a response to vocalize

### FR Coverage Map

| FR | Epic | Description |
|----|------|-------------|
| FR-1 | Epic 1 | Gradium TTS Integration |
| FR-2 | Epic 1 | Streaming Audio Playback |
| FR-3 | Epic 2 | Offline Fallback to AVFoundation |
| FR-4 | Epic 1 | Voice Selection Persistence |
| FR-5 | Epic 1 | TTS Provider Configuration |
| FR-6 | Epic 2 | Error Handling with Graceful Degradation |
| FR-7 | Epic 1 | French Voice "Olivier" Support |
| FR-8 | Epic 1 | API Key Security |
| FR-9 | Epic 3 | LLM Multi-Suggestions |
| FR-10 | Epic 3 | User Response Selection |
| FR-11 | Epic 4 | LLM Personalization |
| FR-12 | Epic 4 | UI Guidance Controls |
| FR-13 | Epic 3 | LLM Service Integration |

## Epic List

### Epic 1: High-Quality Voice Communication

Users can type text and hear it spoken with high-quality Gradium TTS voice.

**User Outcome:** Complete text-to-speech functionality with voice selection and streaming playback.

**FRs covered:** FR-1, FR-2, FR-4, FR-5, FR-7, FR-8

**Implementation Notes:**
- Gradium API integration with PCM streaming
- AVAudioEngine for 24kHz PCM playback
- Voice selection UI with preview
- Keychain storage for API key
- TTSProvider protocol abstraction

---

### Epic 2: Reliable Communication

Users can communicate reliably even when offline or when errors occur.

**User Outcome:** Seamless fallback to iOS native TTS when network unavailable, graceful error handling.

**FRs covered:** FR-3, FR-6

**Implementation Notes:**
- NWPathMonitor for network detection
- AVFoundation fallback for offline mode
- TTSError enum with French localized messages
- Visual indicator for offline mode

---

### Epic 3: AI-Assisted Responses

Users receive multiple AI-generated response suggestions and select which one to vocalize.

**User Outcome:** Smart response suggestions powered by LLM, with user control over which response is spoken.

**FRs covered:** FR-9, FR-10, FR-13

**Implementation Notes:**
- OpenAI-compatible LLM service integration (Cerebras recommended)
- Multi-suggestion generation and display
- Selection UI for choosing response
- Keychain storage for LLM API key

---

### Epic 4: Personalized AI Experience

Users can personalize and guide how the AI generates suggestions.

**User Outcome:** Customized AI behavior matching user preferences and communication style.

**FRs covered:** FR-11, FR-12

**Implementation Notes:**
- LLM personalization settings
- UI controls for guiding responses
- Persistent user preferences

---

## Epic 1: High-Quality Voice Communication - Stories

### Story 1.1: Basic Gradium TTS Integration

As a CalliVox user,
I want to type text and hear it spoken via Gradium TTS,
So that I can communicate with others using high-quality synthesized speech.

**Acceptance Criteria:**

**Given** the user has entered text in the input field
**When** the user taps the "Speak" button
**Then** the text is sent to Gradium TTS API via HTTPS POST request
**And** the API key is retrieved securely from Keychain
**And** the audio response plays through the device speaker

**Given** no Gradium API key is stored in Keychain
**When** the app attempts to use TTS
**Then** an appropriate error message is displayed in French
**And** the user is guided to configure the API key

**Given** the Gradium API returns an error response
**When** the error is received
**Then** a user-friendly error message is displayed in French
**And** the error is logged for debugging

**Technical Notes:**
- Create `TTSProvider` protocol in `Models/TTSProvider.swift`
- Create `TTSError` enum in `Models/TTSError.swift` with LocalizedError
- Create `GradiumTTSProvider` in `Services/GradiumTTSProvider.swift`
- Update `AppConfig.swift` with Gradium configuration
- Use `@MainActor` and `async/await` patterns
- API endpoint: `https://eu.api.gradium.ai/api/tts`

**FRs addressed:** FR-1, FR-5, FR-8

---

### Story 1.2: Streaming Audio Playback

As a CalliVox user,
I want audio to start playing immediately as it streams,
So that I experience minimal delay when communicating.

**Acceptance Criteria:**

**Given** the user initiates TTS
**When** the first audio data chunk arrives from Gradium API
**Then** audio playback begins within 300ms of the request
**And** playback continues smoothly as more data streams in

**Given** the audio is streaming
**When** data arrives in PCM format (24kHz, Int16, Mono)
**Then** AVAudioEngine processes and plays the audio correctly
**And** no buffering gaps occur during normal network conditions

**Given** audio playback is in progress
**When** the user initiates a new TTS request
**Then** the current playback stops cleanly
**And** the new audio begins streaming

**Given** the audio engine is no longer needed
**When** playback completes or is cancelled
**Then** AVAudioEngine resources are properly released in deinit

**Technical Notes:**
- Create `PCMStreamPlayer` in `Managers/PCMStreamPlayer.swift`
- Use `AVAudioEngine` with `AVAudioPlayerNode`
- Audio format: 24kHz, Int16, Mono (Gradium output)
- Implement proper cleanup in `deinit`
- Use `AsyncStream<Data>` for streaming response

**FRs addressed:** FR-2
**NFRs addressed:** NFR-1 (< 300ms latency), NFR-3 (24kHz PCM)

---

### Story 1.3: Voice Selection and Persistence

As a CalliVox user,
I want to select my preferred voice and have it remembered,
So that I always hear speech in my chosen voice.

**Acceptance Criteria:**

**Given** the user navigates to Settings > Voice Options
**When** the voice selection screen appears
**Then** available voices are displayed (including "Olivier" for French)
**And** the currently selected voice is highlighted

**Given** the user is on the voice selection screen
**When** the user taps on a voice
**Then** a preview of that voice plays a sample text
**And** the user can hear the voice quality before confirming

**Given** the user selects a voice
**When** the user confirms the selection
**Then** the voice ID is stored in UserDefaults
**And** all subsequent TTS calls use this voice

**Given** the user is French locale
**When** no voice preference has been set
**Then** "Olivier" is used as the default voice

**Given** the app launches
**When** the user has a saved voice preference
**Then** that voice is loaded and used for TTS

**Technical Notes:**
- Create `VoiceSelectionView` in `Views/VoiceSelectionView.swift`
- Store voice preference in `UserDefaults`
- Default voice ID: "olivier" for French locale
- Voice preview uses same TTS flow with short sample text

**FRs addressed:** FR-4, FR-7

---

### Story 1.4: Remove ElevenLabs Legacy Code

As a developer,
I want all ElevenLabs code removed from the codebase,
So that the codebase is clean and maintainable with only Gradium TTS.

**Acceptance Criteria:**

**Given** the Gradium TTS integration is complete and working
**When** the migration cleanup is performed
**Then** all ElevenLabs references are removed from `AppConfig.swift`
**And** all ElevenLabs API call code is removed from `SpeechService.swift`
**And** any ElevenLabs-specific error handling is removed
**And** any ElevenLabs voice ID references are removed

**Given** the cleanup is complete
**When** the project is built
**Then** the build succeeds with no errors
**And** no warnings related to unused ElevenLabs code appear

**Given** the cleanup is complete
**When** searching the codebase for "ElevenLabs" or "elevenlabs"
**Then** no references are found in source code files

**Technical Notes:**
- Remove `AppConfig.ElevenLabs` struct if present
- Update `SpeechService.swift` to only use `GradiumTTSProvider`
- Verify clean build on iOS 16+ targets
- Run existing tests to ensure no regressions

**FRs addressed:** Architecture requirement (Complete ElevenLabs Removal)

---

## Epic 2: Reliable Communication - Stories

### Story 2.1: Network Monitoring and Offline Detection

As a CalliVox user,
I want the app to automatically detect network status,
So that I know when I'm offline and the app can adapt accordingly.

**Acceptance Criteria:**

**Given** the app is running
**When** the network status changes (connected/disconnected)
**Then** the app detects this change in real-time via NWPathMonitor
**And** the network state is available to all services

**Given** the user is offline
**When** viewing the main screen
**Then** a visual indicator shows "Mode hors-ligne" (offline mode)
**And** the indicator is clearly visible but not intrusive

**Given** the user regains network connectivity
**When** the connection is restored
**Then** the offline indicator disappears
**And** Gradium TTS becomes available again

**Given** the app is about to make an API call
**When** the network check is performed
**Then** the check completes quickly (< 10ms)
**And** does not block the main thread

**Technical Notes:**
- Create `NetworkMonitor` in `Managers/NetworkMonitor.swift`
- Use `NWPathMonitor` from Network framework
- Implement as `@MainActor ObservableObject` for SwiftUI binding
- Check `monitor.currentPath.status == .satisfied` before API calls

**FRs addressed:** FR-3 (partial - detection component)

---

### Story 2.2: AVFoundation Offline Fallback

As a CalliVox user,
I want to continue communicating even when offline,
So that I am never unable to speak due to network issues.

**Acceptance Criteria:**

**Given** the user is offline (no network)
**When** the user taps "Speak" with text entered
**Then** the app automatically uses AVFoundation native TTS
**And** the text is spoken using iOS system voice
**And** the experience feels seamless to the user

**Given** the user is online
**When** the user taps "Speak"
**Then** Gradium TTS is used (not AVFoundation)

**Given** AVFoundation TTS is used
**When** the speech completes
**Then** the text clears as normal
**And** the app behaves identically to online mode

**Given** the user switches from offline to online
**When** the next TTS request is made
**Then** the app automatically uses Gradium TTS again
**And** no user intervention is required

**Technical Notes:**
- Integrate AVFoundation TTS in `SpeechService.swift`
- Use `AVSpeechSynthesizer` with `AVSpeechUtterance`
- Select appropriate French voice for offline mode
- Maintain same `SpeechService` interface regardless of provider

**FRs addressed:** FR-3
**NFRs addressed:** NFR-2 (99.9% availability)

---

### Story 2.3: Graceful Error Handling

As a CalliVox user,
I want to always understand what went wrong and what I can do,
So that I am never confused by silent failures or cryptic errors.

**Acceptance Criteria:**

**Given** a TTS error occurs (API error, network timeout, etc.)
**When** the error is caught
**Then** a user-friendly message is displayed in French
**And** the message explains what went wrong
**And** the message suggests what the user can do

**Given** the Gradium API returns HTTP 401 (unauthorized)
**When** the error is processed
**Then** the message indicates "Clé API invalide" or similar
**And** the user is guided to check their API key configuration

**Given** the Gradium API returns HTTP 429 (rate limited)
**When** the error is processed
**Then** the message indicates "Trop de requêtes, veuillez patienter"
**And** the user understands they need to wait

**Given** a network timeout occurs
**When** the error is processed
**Then** the message indicates "Connexion lente ou indisponible"
**And** offline fallback is suggested if available

**Given** any error occurs
**When** the error is displayed
**Then** the error appears via SwiftUI `.alert()` modifier
**And** the alert can be dismissed
**And** no errors are silently swallowed

**Technical Notes:**
- Extend `TTSError` enum with all error cases
- Implement `LocalizedError` with French `errorDescription`
- Use `@Published var showError` and `errorMessage` pattern
- Error cases: `networkUnavailable`, `apiError(statusCode:message:)`, `audioPlaybackFailed`, `invalidApiKey`, `rateLimited`, `timeout`

**FRs addressed:** FR-6
**NFRs addressed:** NFR-2 (availability through graceful degradation)

---

## Epic 3: AI-Assisted Responses - Stories

### Story 3.1: LLM Service Integration

As a CalliVox user,
I want the app to connect to an AI service,
So that I can receive intelligent response suggestions.

**Acceptance Criteria:**

**Given** the app is configured with an LLM API key
**When** the app needs to generate suggestions
**Then** it connects to the configured LLM service via HTTPS
**And** the API key is retrieved securely from Keychain
**And** the request uses OpenAI-compatible API format

**Given** no LLM API key is stored in Keychain
**When** the user tries to use AI suggestions
**Then** an appropriate error message is displayed in French
**And** the user is guided to configure the API key in settings

**Given** the LLM service returns an error
**When** the error is received
**Then** a user-friendly error message is displayed in French
**And** the app continues to function (TTS still works without suggestions)

**Given** the user wants to configure the LLM service
**When** they access the settings
**Then** they can enter their API key
**And** they can optionally change the endpoint URL (default: Cerebras)

**Technical Notes:**
- Create `LLMProvider` protocol in `Models/LLMProvider.swift`
- Create `OpenAICompatibleLLMProvider` in `Services/OpenAICompatibleLLMProvider.swift`
- Default endpoint: `https://api.cerebras.ai/v1`
- Default model: `qwen-3-235b-a22b-instruct-2507`
- Store API key in Keychain via `KeychainManager`
- Use `async/await` for API calls

**FRs addressed:** FR-13
**NFRs addressed:** NFR-9 (LLM API Security)

---

### Story 3.2: Multi-Suggestion Generation

As a CalliVox user,
I want to receive multiple response suggestions from the AI,
So that I can choose the most appropriate response for my situation.

**Acceptance Criteria:**

**Given** the user is in a conversation context
**When** the app requests suggestions from the LLM
**Then** the LLM returns 3-5 different response options
**And** each suggestion is distinct and contextually appropriate

**Given** a suggestion request is made
**When** the LLM processes the request
**Then** suggestions are available within 500ms
**And** the UI shows a loading indicator while waiting

**Given** the conversation has history
**When** new suggestions are requested
**Then** the context includes recent conversation history
**And** suggestions are relevant to the ongoing conversation

**Given** the LLM request times out or fails
**When** the error is handled
**Then** the user is informed with a French message
**And** they can retry or continue without suggestions

**Given** the user types partial text
**When** suggestions are generated
**Then** the suggestions complete or complement the user's input
**And** the user's intent is preserved in suggestions

**Technical Notes:**
- Create `SuggestionService` in `Managers/SuggestionService.swift`
- Design prompt to request multiple distinct suggestions
- Parse LLM response into array of suggestion strings
- Maintain conversation context (last N exchanges)
- Implement timeout handling (500ms target, 2s max)

**FRs addressed:** FR-9
**NFRs addressed:** NFR-8 (LLM latency < 500ms)

---

### Story 3.3: Suggestion Selection UI

As a CalliVox user,
I want to see AI suggestions and tap to select one,
So that I can quickly choose and speak my response.

**Acceptance Criteria:**

**Given** suggestions have been generated
**When** the suggestions are ready
**Then** they appear in a clear, accessible UI component
**And** each suggestion is displayed as a tappable card/button
**And** suggestions are readable with appropriate font size

**Given** suggestions are displayed
**When** the user taps on a suggestion
**Then** visual feedback confirms the selection (highlight/animation)
**And** the selected text is sent to TTS for vocalization
**And** the suggestion cards are dismissed or updated

**Given** suggestions are displayed
**When** the user prefers to type their own response
**Then** they can dismiss the suggestions
**And** continue typing manually
**And** request new suggestions if desired

**Given** new suggestions are being loaded
**When** the loading state is active
**Then** a subtle loading indicator is shown
**And** previous suggestions remain visible until new ones arrive

**Given** the user is using VoiceOver (accessibility)
**When** suggestions are displayed
**Then** each suggestion is properly labeled for screen readers
**And** selection works with VoiceOver gestures

**Technical Notes:**
- Create `SuggestionView` in `Views/SuggestionView.swift`
- Use SwiftUI with `@ObservedObject` for reactive updates
- Implement as horizontal scrollable cards or vertical list
- Add haptic feedback on selection
- Ensure accessibility labels are set
- Connect selection to existing TTS flow via `SpeechService`

**FRs addressed:** FR-10

---

## Epic 4: Personalized AI Experience - Stories

### Story 4.1: LLM Personalization Settings

As a CalliVox user,
I want to personalize how the AI generates suggestions,
So that the responses match my communication style and needs.

**Acceptance Criteria:**

**Given** the user navigates to Settings > AI Personalization
**When** the personalization screen appears
**Then** options for customizing AI behavior are displayed
**And** current settings are shown with their values

**Given** the user is on the personalization screen
**When** they adjust the communication tone setting
**Then** they can choose between options (formal, neutral, casual)
**And** the selection is visually confirmed

**Given** the user is on the personalization screen
**When** they set a personal context
**Then** they can enter information about themselves (name, situation, preferences)
**And** this context is used to make suggestions more relevant

**Given** the user saves personalization settings
**When** the settings are confirmed
**Then** they are stored in UserDefaults
**And** they persist across app sessions
**And** they are applied to all future LLM requests

**Given** personalization settings exist
**When** a suggestion request is made to the LLM
**Then** the prompt includes the personalization context
**And** suggestions reflect the configured tone and style

**Given** the user wants to reset personalization
**When** they tap "Reset to defaults"
**Then** all personalization settings are cleared
**And** the AI returns to default behavior

**Technical Notes:**
- Create `PersonalizationSettingsView` in `Views/PersonalizationSettingsView.swift`
- Create `PersonalizationConfig` model to store settings
- Store in UserDefaults as encoded JSON
- Inject personalization into LLM prompt in `SuggestionService`
- Settings: tone (formal/neutral/casual), response length (short/medium/long), personal context (free text)

**FRs addressed:** FR-11

---

### Story 4.2: UI Guidance Controls

As a CalliVox user,
I want quick controls to guide AI suggestions in real-time,
So that I can get contextually appropriate responses faster.

**Acceptance Criteria:**

**Given** the user is on the main communication screen
**When** they want to guide the AI
**Then** quick context buttons are visible (e.g., "Salutation", "Question", "Réponse", "Remerciement")
**And** the buttons are easily accessible

**Given** quick context buttons are displayed
**When** the user taps a context button (e.g., "Salutation")
**Then** the AI generates suggestions appropriate for that context
**And** suggestions like "Bonjour", "Salut", "Bonsoir" appear

**Given** suggestions are displayed
**When** the user taps "More like this" on a suggestion
**Then** the AI generates variations of that suggestion
**And** the new suggestions are similar in tone/content

**Given** suggestions are displayed
**When** the user taps "Different" or swipes to refresh
**Then** the AI generates completely different suggestions
**And** the previous suggestions are replaced

**Given** the user adjusts the response length control
**When** they select "Short", "Medium", or "Long"
**Then** subsequent suggestions match the selected length
**And** the control state is visually indicated

**Given** the user is in a specific conversation context
**When** they use guidance controls
**Then** the conversation history is still considered
**And** guidance adds to rather than replaces context

**Technical Notes:**
- Add guidance controls to main view or as overlay
- Create `GuidanceControlsView` in `Views/GuidanceControlsView.swift`
- Quick context options: greeting, question, answer, thanks, goodbye, custom
- Implement "more like this" by including selected suggestion in next prompt
- Implement "different" by adding "different from previous" instruction
- Real-time control state stored in `SuggestionService`

**FRs addressed:** FR-12
