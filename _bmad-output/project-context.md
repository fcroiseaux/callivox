---
project_name: 'CalliVox'
user_name: 'Fabrice'
date: '2026-01-25'
sections_completed: ['technology_stack', 'language_rules', 'framework_rules', 'testing_rules', 'security_rules', 'anti_patterns']
feature_context: 'Gradium TTS Migration'
---

# Project Context for AI Agents - CalliVox iOS

_Critical rules and patterns for implementing code in CalliVox. Focus on unobvious details._

---

## Technology Stack & Versions

| Technology | Version | Constraint |
|------------|---------|------------|
| Swift | 5+ | Required |
| iOS Deployment Target | 16.0+ | Minimum |
| SwiftUI | Native | Primary UI framework |
| AVFoundation | Native | Audio playback |
| AVAudioEngine | Native | PCM streaming (24kHz) |
| URLSession | Native | Network requests only |
| Keychain | Native | Secure storage |
| NWPathMonitor | Native | Network detection |

**No external dependencies allowed** - Use native iOS APIs only.

---

## Critical Implementation Rules

### Swift Language Rules

- **@MainActor** required on all ObservableObject classes
- **async/await** for all network operations (no completion handlers)
- **AsyncStream<Data>** for streaming responses
- **LocalizedError** protocol for all custom errors
- Property wrappers: `@Published`, `@State`, `@StateObject`, `@EnvironmentObject`

### SwiftUI Patterns

```swift
// REQUIRED: All services use this pattern
@MainActor
class ServiceName: ObservableObject {
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
}
```

### Error Handling Rules

```swift
// REQUIRED: Use TTSError enum, not generic Error
enum TTSError: LocalizedError {
    case networkUnavailable
    case apiError(statusCode: Int, message: String)
    case audioPlaybackFailed(underlying: Error)

    var errorDescription: String? { /* French messages */ }
}
```

**Error Propagation Pattern:**

1. Catch error in service method
2. Set `errorMessage = error.localizedDescription`
3. Set `showError = true`
4. View displays via `.alert()` modifier

### Network Rules

```swift
// REQUIRED: Always check network before API calls
import Network

private let monitor = NWPathMonitor()

guard monitor.currentPath.status == .satisfied else {
    // Use AVFoundation offline fallback
    return
}
// Proceed with Gradium API call
```

### Audio Lifecycle Rules

```swift
// REQUIRED: AVAudioEngine cleanup pattern
class PCMStreamPlayer {
    private var engine: AVAudioEngine?

    deinit {
        engine?.stop()
        engine = nil  // CRITICAL: Release resources
    }
}
```

**PCM Format:** 24kHz, Int16, Mono (Gradium output format)

---

## File Organization Rules

| Directory | Contents |
|-----------|----------|
| `Models/` | Protocols, data models, AppConfig, error enums |
| `Managers/` | Service layer classes (ObservableObject) |
| `Services/` | External API clients |
| `Views/` | SwiftUI views only |

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Classes/Structs | PascalCase | `GradiumTTSProvider` |
| Protocols | PascalCase (no suffix) | `TTSProvider` |
| Properties | camelCase | `isPlaying`, `apiKey` |
| Methods | camelCase, verb first | `synthesize(text:)` |
| Files | Match primary type | `GradiumTTSProvider.swift` |

---

## Testing Rules

- Test files in `ios-appTests/` directory
- Naming: `{ClassName}Tests.swift`
- Use `XCTestCase` for all tests
- Mock protocols, not concrete classes
- Test async methods with `async` test functions

---

## Security Rules

| Data | Storage | Access |
|------|---------|--------|
| API Keys | Keychain | `KeychainManager.shared.retrieve(key:)` |
| User Preferences | UserDefaults | Standard API |
| Credentials | NEVER in source code | Environment or Keychain |

**HTTPS only** - All API calls must use HTTPS.

---

## Anti-Patterns to Avoid

- Direct API calls without network check
- Generic `Error` instead of `TTSError` enum
- UI updates outside `@MainActor`
- Forgetting `deinit` cleanup for audio resources
- Hardcoded API keys in source code
- Using completion handlers instead of async/await
- Creating files outside designated directories
- Using external dependencies (CocoaPods, SPM packages)

---

## Gradium TTS Specific Rules

**API Endpoint:** `https://eu.api.gradium.ai/api/tts`

**Request Format:**

```json
{
  "text": "...",
  "voice_id": "olivier",
  "output_format": "pcm"
}
```

**Response:** Streaming `application/octet-stream` (PCM 24kHz Int16)

**Default Voice:** `olivier` (French)

**Authentication:** `x-api-key` header from Keychain
