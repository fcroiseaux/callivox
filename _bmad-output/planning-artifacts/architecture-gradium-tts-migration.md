---
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8]
status: 'complete'
completedAt: '2026-01-25'
inputDocuments: ["_bmad-output/planning-artifacts/prd-gradium-tts-migration.md", "docs/index.md", "docs/architecture-ios-app.md", "docs/integration-architecture.md"]
workflowType: 'architecture'
project_name: 'CalliVox'
user_name: 'Fabrice'
date: '2026-01-25'
feature_name: 'Gradium TTS Migration'
---

# Architecture Decision Document - Gradium TTS Migration

_This document builds collaboratively through step-by-step discovery. Sections are appended as we work through each architectural decision together._

## Project Context Analysis

### Requirements Overview

**Functional Requirements:**

- **TTS Integration (FR-1, FR-2, FR-7):** Replace ElevenLabs with Gradium TTS API using streaming PCM audio at 24kHz. Support French voice "Olivier" as default for French locale users.
- **Resilience (FR-3, FR-6):** Maintain AVFoundation as offline fallback. Implement graceful degradation: Gradium → retry → AVFoundation. No silent failures.
- **Configuration (FR-4, FR-5):** Voice selection UI with preview. Provider toggle in AppConfig for migration flexibility.
- **Security (FR-8):** API key stored in iOS Keychain, never in source code or logs.

**Non-Functional Requirements:**

- **Performance:** < 300ms latency to first audio byte (SC-1)
- **Reliability:** 99.9% TTS success rate including fallbacks (NFR-2)
- **Audio Quality:** 24kHz PCM format matching InvincibleVoice standard
- **Efficiency:** < 5% battery drain/hour, < 50MB memory for streaming
- **Security:** HTTPS-only, Keychain storage, no PII exposure
- **Compatibility:** iOS 16+ (matching current CalliVox minimum)

**Scale & Complexity:**

- Primary domain: iOS Mobile Application
- Complexity level: Medium (brownfield component replacement)
- Estimated architectural components: 4 (GradiumClient, SpeechService refactor, AudioManager enhancement, AppConfig extension)

### Technical Constraints & Dependencies

| Constraint | Impact |
|------------|--------|
| Existing SpeechService pattern | Must maintain ObservableObject interface |
| AVFoundation fallback | Already implemented, must preserve |
| Keychain storage | Pattern exists via KeychainManager |
| MVVM architecture | New client must integrate with service layer |
| No external dependencies | Use native URLSession and AVAudioEngine |

### Cross-Cutting Concerns Identified

1. **Audio Format Transition:** ElevenLabs returns MP3, Gradium returns PCM - requires AVAudioEngine for PCM streaming vs current AVAudioPlayer
2. **Error Propagation:** All TTS errors must surface to UI via existing showError/errorMessage pattern
3. **Configuration Migration:** Users with saved ElevenLabs voices need graceful migration to Gradium voices
4. **Offline Detection:** Network status must be checked before TTS call to route appropriately

## Starter Template Evaluation

### Primary Technology Domain

**iOS Mobile Application (Brownfield Enhancement)**

This is a component replacement within an existing SwiftUI application, not a greenfield project. The architectural foundation is already established.

### Existing Foundation (No Starter Needed)

| Technology | Version | Purpose |
|------------|---------|---------|
| Swift | 5+ | Primary language |
| SwiftUI | iOS 16+ | UI framework |
| AVFoundation | Native | Audio playback |
| URLSession | Native | Network requests |
| Keychain | Native | Secure storage |

### Architectural Patterns Established

**Code Organization:**

- `Models/` - Data models and configuration (AppConfig, UserModel)
- `Managers/` - Service layer (SpeechService, KeychainManager)
- `Views/` - SwiftUI views

**State Management:**

- `@MainActor` for thread safety
- `ObservableObject` for reactive state
- `EnvironmentObject` for dependency injection

**Error Handling:**

- Published error state on services
- Alert presentation via `.alert()` modifier

### New Components for Gradium Migration

**Required Additions:**

1. `Services/GradiumClient.swift` - API client for Gradium TTS
2. `Managers/PCMStreamPlayer.swift` - AVAudioEngine-based PCM streaming
3. `Models/TTSProvider.swift` - Protocol abstraction for provider switching
4. `AppConfig` extension - Gradium configuration struct

**Modification to Existing:**

1. `SpeechService.swift` - Integrate new providers, maintain interface
2. `AppConfig.swift` - Add Gradium credentials section

**Note:** No project initialization needed. First implementation story is creating GradiumClient.swift

## Core Architectural Decisions

### Decision Priority Analysis

**Critical Decisions (Block Implementation):**

1. TTS Client Architecture → Protocol Abstraction
2. Audio Streaming → AVAudioEngine for PCM
3. Provider Strategy → Gradium-only (complete ElevenLabs removal)

**Important Decisions (Shape Architecture):**

4. Configuration Management → UserDefaults + Keychain

**Deferred Decisions (Post-MVP):**

- Kyutai self-hosted option (Phase 2)
- Voice cloning support (Phase 2)

### TTS Client Architecture

**Decision:** Protocol Abstraction with `TTSProvider`

```swift
protocol TTSProvider {
    func synthesize(text: String, voice: String) async throws -> AsyncStream<Data>
}

// Single implementation for MVP
class GradiumTTSProvider: TTSProvider { ... }
```

**Rationale:**

- Clean architecture for future Kyutai self-hosted option
- Testable with mock providers
- ElevenLabs code completely removed, not abstracted

**Affects:** SpeechService, new GradiumClient

### Audio Streaming Architecture

**Decision:** AVAudioEngine with PCM buffer scheduling

```swift
class PCMStreamPlayer {
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()

    // 24kHz mono PCM format (Gradium output)
    let format = AVAudioFormat(commonFormat: .pcmFormatInt16,
                               sampleRate: 24000,
                               channels: 1,
                               interleaved: false)

    func scheduleBuffer(_ data: Data) { ... }
}
```

**Rationale:**

- Enables < 300ms time-to-first-audio (SC-1)
- Native iOS API, no external dependencies
- Supports streaming without full download

**Affects:** New PCMStreamPlayer component

### Provider Strategy

**Decision:** Gradium-only with complete ElevenLabs removal

| Condition | Behavior |
|-----------|----------|
| Network available | Use Gradium TTS API |
| Gradium API error | Display error to user (no retry to other provider) |
| No network (offline) | Use AVFoundation native TTS (FR-3) |

**Rationale:**

- Clean migration, no legacy code maintenance
- Simpler architecture without multi-provider complexity
- AVFoundation offline is native iOS capability, not a "fallback provider"

**Affects:** SpeechService refactor, AppConfig cleanup

### Configuration Management

**Decision:** Hybrid UserDefaults + Keychain

| Data | Storage | Access |
|------|---------|--------|
| Gradium API Key | Keychain | `KeychainManager.shared` |
| Selected Voice ID | UserDefaults | `UserDefaults.standard` |
| TTS Endpoint URL | AppConfig (static) | Compile-time |

**Rationale:**

- Security best practice for API credentials
- User preferences persist across sessions
- Endpoint rarely changes, can be static

**Affects:** AppConfig.swift, KeychainManager usage

### Decision Impact Analysis

**Implementation Sequence:**

1. Create `TTSProvider` protocol
2. Implement `GradiumTTSProvider` with URLSession streaming
3. Create `PCMStreamPlayer` with AVAudioEngine
4. Refactor `SpeechService` to use new components
5. Remove all ElevenLabs code
6. Update `AppConfig` for Gradium credentials
7. Add voice selection UI

**Cross-Component Dependencies:**

```
TTSProvider (protocol)
     │
     ▼
GradiumTTSProvider ──► PCMStreamPlayer
     │                      │
     ▼                      ▼
SpeechService ◄────── AVAudioEngine
     │
     ▼
ContentView (UI)
```

## Implementation Patterns & Consistency Rules

### Critical Conflict Points Addressed

5 areas where AI agents could make different choices have been standardized.

### Naming Patterns (Swift)

| Element | Convention | Example |
|---------|------------|---------|
| Protocols | Descriptive suffix | `TTSProvider` |
| Classes/Structs | PascalCase | `GradiumTTSProvider` |
| Properties | camelCase | `isPlaying`, `apiKey` |
| Methods | camelCase, action verb | `synthesize(text:)` |
| Files | Match primary type | `GradiumTTSProvider.swift` |
| Error enums | Descriptive cases | `TTSError.networkUnavailable` |

### Structure Patterns

**File Organization:**

- `Models/` → Protocols, data models, configuration
- `Managers/` → Service layer, state management
- `Services/` → External API clients
- `Views/` → SwiftUI views

**Test Organization:**

- Co-located in `ios-appTests/`
- Naming: `{ClassName}Tests.swift`

### Error Handling Patterns

**Standard Error Enum:**

```swift
enum TTSError: LocalizedError {
    case networkUnavailable
    case apiError(statusCode: Int, message: String)
    case audioPlaybackFailed(underlying: Error)
}
```

**UI Propagation:**

- All errors surface via `@Published var showError` and `errorMessage`
- Use `.alert()` modifier pattern for display
- French localized error messages

### Async/Await Patterns

**Network Operations:**

- Always check `NWPathMonitor` before API calls
- Use `async throws` for all network methods
- Stream processing with `for try await`

**Main Thread Safety:**

- All UI updates via `@MainActor`
- Published properties only modified on main thread

### Audio Lifecycle Patterns

**AVAudioEngine Management:**

- Initialize engine lazily
- Always call `stop()` before dealloc
- Implement `deinit` with cleanup
- Use optional engine to allow nil state

### Enforcement Guidelines

**All AI Agents MUST:**

1. Follow Swift naming conventions exactly as specified
2. Place new files in correct directories per structure patterns
3. Use `TTSError` enum for all TTS-related errors
4. Check network availability before Gradium API calls
5. Clean up AVAudioEngine resources in deinit

**Anti-Patterns to Avoid:**

- Direct API calls without network check
- Error strings instead of `TTSError` enum
- UI updates outside `@MainActor`
- Forgetting `deinit` cleanup for audio resources

## Project Structure & Boundaries

### Complete Project Directory Structure

```
ios-app/HandwritingToSpeechSwiftUI/
├── Models/
│   ├── AppConfig.swift              # 🔄 Add Gradium config section
│   ├── TTSProvider.swift            # ✨ NEW - TTS protocol
│   └── TTSError.swift               # ✨ NEW - Error enum
├── Managers/
│   ├── SpeechService.swift          # 🔄 Integrate Gradium provider
│   ├── NetworkMonitor.swift         # ✨ NEW - NWPathMonitor wrapper
│   └── PCMStreamPlayer.swift        # ✨ NEW - AVAudioEngine streaming
├── Services/
│   └── GradiumTTSProvider.swift     # ✨ NEW - Gradium API client
└── Views/
    └── VoiceSelectionView.swift     # ✨ NEW - Voice picker UI
```

### New Files Summary

| File | Purpose | Lines (est.) |
|------|---------|--------------|
| `TTSProvider.swift` | Protocol definition | ~20 |
| `TTSError.swift` | Error enum | ~30 |
| `NetworkMonitor.swift` | Network availability | ~40 |
| `PCMStreamPlayer.swift` | PCM audio streaming | ~100 |
| `GradiumTTSProvider.swift` | Gradium API client | ~120 |
| `VoiceSelectionView.swift` | Voice selection UI | ~80 |

### Architectural Boundaries

**Service Layer Boundary:**

- `SpeechService` is the ONLY entry point for TTS from Views
- Views never directly access `GradiumTTSProvider` or `PCMStreamPlayer`
- All state changes flow through `@Published` properties

**Network Boundary:**

- All external API calls go through `GradiumTTSProvider`
- `NetworkMonitor` provides network state, does not make calls
- Keychain access only through `KeychainManager.shared`

**Audio Boundary:**

- `PCMStreamPlayer` owns AVAudioEngine lifecycle
- No direct AVAudioEngine access from other components
- Audio session configuration in `PCMStreamPlayer` only

### Integration Points

| Integration | Protocol/Interface | Data Format |
|-------------|-------------------|-------------|
| SpeechService → TTSProvider | `TTSProvider` protocol | `AsyncStream<Data>` |
| GradiumTTSProvider → Gradium API | HTTPS POST | JSON → PCM stream |
| PCMStreamPlayer → AVAudioEngine | Native API | PCM Int16 @ 24kHz |
| VoiceSelectionView → UserDefaults | Standard API | String (voice ID) |

### Code to Remove (ElevenLabs)

Files/sections to DELETE during migration:

- `AppConfig.ElevenLabs` struct
- ElevenLabs API call code in `SpeechService`
- Any ElevenLabs-specific error handling
- ElevenLabs voice ID references

## Architecture Validation Results

### Coherence Validation ✅

**Decision Compatibility:** All technology choices (Swift, SwiftUI, AVAudioEngine, URLSession) are native iOS frameworks that work seamlessly together.

**Pattern Consistency:** MVVM + ObservableObject + async/await patterns align with modern SwiftUI best practices.

**Structure Alignment:** Project structure follows iOS conventions with clear separation of Models/Managers/Services/Views.

### Requirements Coverage Validation ✅

**Functional Requirements:**

- FR-1 to FR-8: All covered by specific architectural components
- FR-5 (Provider Config): Simplified to Gradium-only per stakeholder decision

**Non-Functional Requirements:**

- NFR-1 (Latency): AVAudioEngine streaming enables < 300ms
- NFR-2 (Availability): Offline fallback + error handling
- NFR-3 to NFR-7: All addressed by architecture

### Implementation Readiness Validation ✅

**Decision Completeness:** 4 critical decisions documented with code examples

**Structure Completeness:** 6 new files + 2 modifications identified

**Pattern Completeness:** All potential conflict points addressed

### Architecture Completeness Checklist

- [x] Project context thoroughly analyzed
- [x] Scale and complexity assessed (Medium - brownfield)
- [x] Technical constraints identified (existing SpeechService interface)
- [x] Critical decisions documented with Swift code examples
- [x] Technology stack fully specified (native iOS only)
- [x] Naming conventions established (Swift standards)
- [x] Error handling patterns documented (TTSError enum)
- [x] Complete directory structure defined
- [x] Component boundaries established
- [x] Integration points mapped (protocol-based)

### Architecture Readiness Assessment

**Overall Status:** READY FOR IMPLEMENTATION

**Confidence Level:** HIGH

**Key Strengths:**

- Clean protocol-based abstraction for future extensibility
- Complete ElevenLabs removal - no legacy maintenance
- Native iOS APIs only - no external dependencies
- Clear patterns prevent AI agent conflicts

**First Implementation Priority:**

1. Create `TTSProvider.swift` protocol
2. Create `TTSError.swift` enum
3. Create `GradiumTTSProvider.swift` client

## Architecture Completion Summary

### Workflow Completion

**Architecture Decision Workflow:** COMPLETED ✅
**Total Steps Completed:** 8
**Date Completed:** 2026-01-25
**Document Location:** `_bmad-output/planning-artifacts/architecture-gradium-tts-migration.md`

### Final Architecture Deliverables

**Complete Architecture Document:**

- 4 critical architectural decisions documented
- 5 implementation pattern categories defined
- 6 new files + 2 modifications specified
- 8 FRs + 7 NFRs fully supported

**Implementation Ready Foundation:**

- Protocol-based TTS abstraction (`TTSProvider`)
- AVAudioEngine streaming for PCM playback
- Gradium-only provider (ElevenLabs removed)
- Native iOS APIs only - no external dependencies

### Implementation Handoff

**For AI Agents:**

This architecture document is your complete guide for implementing the Gradium TTS Migration for CalliVox. Follow all decisions, patterns, and structures exactly as documented.

**Development Sequence:**

1. Create `TTSProvider.swift` protocol
2. Create `TTSError.swift` error enum
3. Create `NetworkMonitor.swift` wrapper
4. Create `PCMStreamPlayer.swift` with AVAudioEngine
5. Create `GradiumTTSProvider.swift` API client
6. Refactor `SpeechService.swift` to use new components
7. Update `AppConfig.swift` with Gradium configuration
8. Create `VoiceSelectionView.swift` UI
9. Remove all ElevenLabs code
10. Add unit tests for new components

### Quality Assurance Checklist

**✅ Architecture Coherence**

- [x] All decisions work together without conflicts
- [x] Technology choices are compatible (native iOS only)
- [x] Patterns support the architectural decisions
- [x] Structure aligns with existing CalliVox patterns

**✅ Requirements Coverage**

- [x] All functional requirements are supported
- [x] All non-functional requirements are addressed
- [x] Cross-cutting concerns (error handling, security) handled
- [x] Integration points clearly defined

**✅ Implementation Readiness**

- [x] Decisions are specific and actionable
- [x] Swift code examples provided for all patterns
- [x] Structure is complete and unambiguous
- [x] Boundaries clearly established

---

**Architecture Status:** READY FOR IMPLEMENTATION ✅

**Next Phase:** Create epics and stories based on this architecture for sprint planning.

