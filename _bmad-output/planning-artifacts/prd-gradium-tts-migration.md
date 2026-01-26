---
stepsCompleted: ["executive-summary", "success-criteria", "scope", "user-journeys", "functional-requirements", "non-functional-requirements"]
inputDocuments: ["docs/index.md", "docs/architecture-ios-app.md", "invincible-voice/README.md"]
workflowType: 'prd'
projectType: 'brownfield-enhancement'
---

# Product Requirements Document - CalliVox TTS Migration

**Author:** Fabrice
**Date:** 2026-01-25
**Project:** CalliVox
**Feature:** Replace ElevenLabs with Gradium/Kyutai TTS

---

## Executive Summary

### Vision Statement

Migrate CalliVox's text-to-speech engine from ElevenLabs to Gradium/Kyutai TTS to align with the accessibility-focused InvincibleVoice ecosystem, reduce costs, enable self-hosting options, and improve French voice quality through the "Olivier" voice.

### Problem Statement

CalliVox currently uses ElevenLabs API for high-quality voice synthesis. This creates:

1. **Vendor Lock-in** - Single provider dependency with proprietary API
2. **Cost Concerns** - ElevenLabs pricing scales with usage (€22/month for 100K characters)
3. **Privacy Limitations** - Text data sent to third-party servers
4. **No Self-Hosting** - Cannot run TTS locally for offline or privacy-sensitive users
5. **Misaligned Ecosystem** - ElevenLabs targets entertainment; Gradium/Kyutai targets accessibility

### Proposed Solution

Integrate Gradium TTS API as primary provider with optional Kyutai self-hosted fallback:

| Option | Use Case | Latency | Cost |
|--------|----------|---------|------|
| Gradium Cloud | Default for most users | Low (~200ms) | Free tier available |
| Kyutai Self-Hosted | Privacy-focused users | Lowest | Server costs only |
| AVFoundation | Offline fallback | Instant | Free |

### Target Users

- Primary: CalliVox users with speech impairments
- Secondary: Healthcare/institutional deployments requiring self-hosting

### Key Differentiator

InvincibleVoice/Gradium is purpose-built for accessibility applications by Kyutai Labs, the same team behind CalliVox's use case. This alignment provides:

- French "Olivier" voice optimized for natural speech
- Real-time streaming (PCM output)
- Open-source server option for full control

---

## Success Criteria

| ID | Metric | Target | Measurement Method |
|----|--------|--------|-------------------|
| SC-1 | TTS Latency | < 300ms time-to-first-byte | iOS performance logging |
| SC-2 | Voice Quality Rating | ≥ 4.0/5.0 user satisfaction | In-app survey (n≥50) |
| SC-3 | Cost Reduction | ≥ 30% vs ElevenLabs | Monthly billing comparison |
| SC-4 | Offline Availability | 100% graceful fallback | Automated testing |
| SC-5 | Self-Host Option | Deployable in < 30 minutes | Documentation validation |
| SC-6 | Migration Downtime | 0 minutes | Blue-green deployment |
| SC-7 | French Voice Naturalness | ≥ 85% intelligibility | User testing with target audience |

---

## Product Scope

### Phase 1: MVP (This PRD)

- Gradium TTS integration in iOS app
- Streaming audio playback (PCM format)
- AVFoundation fallback when offline
- Voice selection (Olivier for French)
- Configuration toggle between providers

### Phase 2: Growth (Future)

- Self-hosted Kyutai TTS option for enterprises
- Custom voice cloning support
- Multi-language voice expansion
- Usage analytics dashboard

### Phase 3: Vision (Future)

- Real-time voice synthesis during typing
- Voice style customization (speed, pitch)
- Integration with InvincibleVoice's STT for bi-directional communication

### Out of Scope

- STT (Speech-to-Text) integration - separate feature
- LLM integration for response suggestions - separate feature
- Backend TTS processing - iOS-only implementation
- Voice training/cloning - Phase 2

---

## User Journeys

### UJ-1: Standard Text-to-Speech

**Actor:** CalliVox user with speech impairment
**Precondition:** User authenticated, internet connected
**Journey:**

1. User types or writes text in CalliVox
2. User taps "Speak" button
3. App sends text to Gradium TTS API
4. Audio streams back in real-time (PCM)
5. App plays audio through device speaker
6. Text clears after playback completes

**Success:** Audio begins within 300ms, plays clearly

### UJ-2: Offline Fallback

**Actor:** CalliVox user without internet
**Precondition:** User authenticated, no network
**Journey:**

1. User types text in CalliVox
2. User taps "Speak" button
3. App detects no network connectivity
4. App uses AVFoundation (iOS native TTS) as fallback
5. Audio plays through device speaker
6. App displays "Mode hors-ligne" indicator

**Success:** Seamless experience, user informed of fallback mode

### UJ-3: Voice Selection

**Actor:** CalliVox user preferring specific voice
**Precondition:** User in settings
**Journey:**

1. User opens Settings > Voice Options
2. App displays available voices (Olivier, Kelly, etc.)
3. User selects preferred voice
4. App plays sample of selected voice
5. User confirms selection
6. Selection persists in UserDefaults

**Success:** Voice preference applies to all future TTS

### UJ-4: Auto-Read with Streaming

**Actor:** CalliVox user with auto-read enabled
**Precondition:** Auto-read toggle ON
**Journey:**

1. User types text in CalliVox
2. User pauses typing for 3 seconds
3. App automatically sends text to TTS
4. Audio streams and plays
5. Text clears after playback

**Success:** Seamless hands-free experience

---

## Functional Requirements

### FR-1: Gradium TTS Integration

| Attribute | Value |
|-----------|-------|
| **Description** | App sends text to Gradium TTS API and receives streaming PCM audio |
| **Source** | UJ-1, UJ-4 |
| **Priority** | P0 (Critical) |
| **Acceptance Criteria** | 1. POST request to Gradium API with text payload 2. Receive streaming PCM audio response 3. Audio plays through AVAudioPlayer/AVAudioEngine |

### FR-2: Streaming Audio Playback

| Attribute | Value |
|-----------|-------|
| **Description** | Audio plays as it streams, not after full download |
| **Source** | SC-1 (Latency) |
| **Priority** | P0 (Critical) |
| **Acceptance Criteria** | 1. First audio byte plays within 300ms of request 2. Continuous playback without buffering gaps 3. Sample rate: 24kHz PCM |

### FR-3: Offline Fallback to AVFoundation

| Attribute | Value |
|-----------|-------|
| **Description** | When network unavailable, use iOS native TTS |
| **Source** | UJ-2 |
| **Priority** | P0 (Critical) |
| **Acceptance Criteria** | 1. Network status detected before TTS call 2. AVFoundation used when offline 3. Visual indicator shows offline mode 4. Same text cleared behavior |

### FR-4: Voice Selection Persistence

| Attribute | Value |
|-----------|-------|
| **Description** | User can select and persist voice preference |
| **Source** | UJ-3 |
| **Priority** | P1 (High) |
| **Acceptance Criteria** | 1. Settings UI shows available voices 2. Voice preview plays sample text 3. Selection stored in UserDefaults 4. Selection applies to subsequent TTS calls |

### FR-5: TTS Provider Configuration

| Attribute | Value |
|-----------|-------|
| **Description** | App supports switching between TTS providers |
| **Source** | Migration flexibility |
| **Priority** | P1 (High) |
| **Acceptance Criteria** | 1. AppConfig defines active TTS provider 2. Gradium as default 3. ElevenLabs as fallback option 4. Self-hosted URL configurable |

### FR-6: Error Handling with Graceful Degradation

| Attribute | Value |
|-----------|-------|
| **Description** | TTS errors fallback gracefully, user always gets audio |
| **Source** | SC-4 |
| **Priority** | P0 (Critical) |
| **Acceptance Criteria** | 1. Gradium error → retry once → AVFoundation fallback 2. Error logged for debugging 3. User sees brief error indicator, then hears text 4. No silent failures |

### FR-7: French Voice "Olivier" Support

| Attribute | Value |
|-----------|-------|
| **Description** | Default voice for French users is "Olivier" |
| **Source** | SC-7, voices.yaml |
| **Priority** | P1 (High) |
| **Acceptance Criteria** | 1. Olivier voice ID configured in AppConfig 2. French locale auto-selects Olivier 3. Voice sounds natural for French sentences |

### FR-8: API Key Security

| Attribute | Value |
|-----------|-------|
| **Description** | Gradium API key stored securely, not in source code |
| **Source** | Security best practice |
| **Priority** | P0 (Critical) |
| **Acceptance Criteria** | 1. API key stored in Keychain 2. Key retrieved at runtime 3. Key not logged or exposed 4. Key rotatable without app update |

---

## Non-Functional Requirements

### NFR-1: Latency

| Attribute | Value |
|-----------|-------|
| **Requirement** | Time-to-first-audio-byte < 300ms for 95th percentile |
| **Measurement** | iOS Performance logging with timestamps |
| **Rationale** | Conversational flow requires near-instant response |

### NFR-2: Availability

| Attribute | Value |
|-----------|-------|
| **Requirement** | 99.9% TTS success rate (including fallbacks) |
| **Measurement** | Success/failure logging over 30-day period |
| **Rationale** | Accessibility tool must be reliable |

### NFR-3: Audio Quality

| Attribute | Value |
|-----------|-------|
| **Requirement** | 24kHz sample rate, PCM format |
| **Measurement** | Audio specification validation |
| **Rationale** | Match InvincibleVoice standard, sufficient for speech |

### NFR-4: Battery Impact

| Attribute | Value |
|-----------|-------|
| **Requirement** | < 5% battery drain per hour of active TTS use |
| **Measurement** | XCTest energy diagnostics |
| **Rationale** | Accessibility users may use frequently throughout day |

### NFR-5: Memory Usage

| Attribute | Value |
|-----------|-------|
| **Requirement** | < 50MB additional memory for streaming playback |
| **Measurement** | Xcode Memory Profiler |
| **Rationale** | App must run smoothly on older devices |

### NFR-6: Security

| Attribute | Value |
|-----------|-------|
| **Requirement** | All TTS API calls over HTTPS, API key in Keychain |
| **Measurement** | Security audit, network traffic analysis |
| **Rationale** | Protect user text and credentials |

### NFR-7: Backward Compatibility

| Attribute | Value |
|-----------|-------|
| **Requirement** | Support iOS 16+ |
| **Measurement** | Test on iOS 16, 17 simulators |
| **Rationale** | Match current CalliVox minimum iOS version |

---

## Technical Context (Brownfield)

### Existing Architecture

| Component | Current | Migration Impact |
|-----------|---------|------------------|
| SpeechService.swift | ElevenLabs API calls | Replace API client |
| AppConfig.swift | ElevenLabs credentials | Add Gradium credentials |
| AudioManager.swift | AVAudioPlayer setup | Add PCM streaming support |

### Key Files to Modify

1. `Managers/SpeechService.swift` - New GradiumTTSClient
2. `Models/AppConfig.swift` - Gradium configuration
3. `Managers/AudioManager.swift` - PCM streaming playback
4. New: `Services/GradiumClient.swift` - API client

### Dependencies to Add

```swift
// No external dependencies needed
// Use native URLSession for HTTP
// Use native AVAudioEngine for PCM playback
```

### Integration Points

| Integration | Protocol | Notes |
|-------------|----------|-------|
| Gradium TTS | HTTPS POST | Text → PCM stream |
| Gradium Auth | API Key Header | `x-api-key` |

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Gradium API changes | Low | High | Abstract client, monitor changelog |
| Free tier limits exceeded | Medium | Medium | Implement usage tracking, alert threshold |
| Voice quality regression | Low | High | A/B test before full rollout |
| Network latency variance | Medium | Medium | Aggressive timeout + fallback |

---

## Appendix A: Gradium API Reference

### Text-to-Speech Endpoint

```
POST https://eu.api.gradium.ai/api/tts
Headers:
  x-api-key: <GRADIUM_API_KEY>
  Content-Type: application/json

Body:
{
  "text": "Bonjour, comment allez-vous?",
  "voice_id": "olivier",
  "output_format": "pcm"
}

Response: Streaming application/octet-stream (PCM 24kHz)
```

### Voice IDs

| Voice | Language | Description |
|-------|----------|-------------|
| olivier | French | Male, entrepreneur tone |
| kelly | English | Female, default |

---

## Appendix B: Traceability Matrix

| FR/NFR | Success Criteria | User Journey |
|--------|------------------|--------------|
| FR-1 | SC-1, SC-6 | UJ-1, UJ-4 |
| FR-2 | SC-1 | UJ-1, UJ-4 |
| FR-3 | SC-4 | UJ-2 |
| FR-4 | SC-2, SC-7 | UJ-3 |
| FR-5 | SC-3, SC-5 | - |
| FR-6 | SC-4 | UJ-2 |
| FR-7 | SC-7 | UJ-1, UJ-3 |
| FR-8 | - | - |
| NFR-1 | SC-1 | UJ-1 |
| NFR-2 | SC-4 | UJ-1, UJ-2 |
