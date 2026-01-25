# CalliVox iOS App - Architecture Documentation

**Part ID:** ios-app
**Project Type:** Mobile Application
**Generated:** 2026-01-25

## Executive Summary

The CalliVox iOS app is a SwiftUI-based accessibility application providing text-to-speech functionality for users with speech impairments. It features Apple Pencil handwriting support, predefined phrase shortcuts, and integration with both native iOS TTS (AVFoundation) and ElevenLabs AI voice synthesis.

## Technology Stack

| Category | Technology | Purpose |
|----------|------------|---------|
| UI Framework | SwiftUI | Declarative UI |
| Language | Swift 5+ | Primary language |
| TTS Engine | AVFoundation | Native speech synthesis |
| TTS Engine | ElevenLabs API | AI voice synthesis |
| Authentication | AuthenticationServices | Apple Sign In |
| Storage | Keychain | Secure credential storage |
| Storage | UserDefaults | App settings persistence |

## Architecture Pattern

**Style:** MVVM-inspired with Service Layer

```
┌─────────────────────────────────────────────┐
│                 Views Layer                 │
│  (ContentView, PhrasesListView, etc.)       │
├─────────────────────────────────────────────┤
│               Models Layer                  │
│  (UserModel, UsageLogModel, AppConfig)      │
├─────────────────────────────────────────────┤
│              Managers Layer                 │
│  (SpeechService, UsageLogManager, etc.)     │
├─────────────────────────────────────────────┤
│            External Services                │
│  (Backend API, ElevenLabs, Apple Sign In)   │
└─────────────────────────────────────────────┘
```

## Module Structure

### Models

#### AppConfig

**Purpose:** Centralized configuration and feature flags

```swift
struct AppConfig {
    struct API {
        static let baseURL = "https://api.callivox.app"
        static let bypassServerAPI = true  // Development flag
    }

    struct Features {
        static let skipAuthentication = true  // Development flag
    }

    struct ElevenLabs {
        static let apiKey = "..."
        static let voiceId = "..."
    }
}
```

#### UserModel

**Purpose:** User authentication state management

```swift
@MainActor
class UserModel: ObservableObject {
    @Published var userId: String?
    @Published var email: String?
    @Published var isAuthenticated: Bool

    // Keychain-backed persistence
    func signIn(userId: String, email: String?, token: String)
    func signOut()
}
```

#### UsageLogModel

**Purpose:** Usage event data structure for analytics

```swift
struct UsageLog: Codable {
    let sentence: String
    let timestamp: Date
    let location: Location?
    let deviceInfo: String?
}
```

### Managers (Services)

#### SpeechService

**Purpose:** Core text-to-speech functionality

**Features:**

- AVFoundation native TTS
- ElevenLabs API integration
- Text correction/normalization
- Voice availability monitoring

```swift
@MainActor
class SpeechService: ObservableObject {
    @Published var isSpeaking: Bool
    @Published var showError: Bool
    @Published var errorMessage: String

    func speakText(_ text: String)
    func stopSpeaking()
    func correctText(_ text: String) -> String
}
```

#### KeychainManager

**Purpose:** Secure credential storage

```swift
class KeychainManager {
    static let shared = KeychainManager()

    func save(key: String, value: String) throws
    func retrieve(key: String) -> String?
    func delete(key: String) throws
}
```

#### UsageLogManager

**Purpose:** Offline-first usage logging with sync

```swift
@MainActor
class UsageLogManager: ObservableObject {
    @Published var pendingLogsCount: Int

    func logUsage(sentence: String, location: Location?)
    func submitOfflineLogs()  // Sync when online
}
```

#### PresetSentenceManager

**Purpose:** Predefined phrase management

```swift
@MainActor
class PresetSentenceManager: ObservableObject {
    @Published var presetSentences: [PresetSentence]
    @Published var selectedPresets: [PresetSentence]

    func addPreset(_ sentence: String)
    func removePreset(at index: Int)
    func toggleSelection(_ preset: PresetSentence)
}
```

### Views

| View | Purpose |
|------|---------|
| `ContentView` | Main application interface |
| `AppleSignInView` | Authentication flow |
| `AppleSignInButton` | Sign In with Apple button |
| `ControlButtonsView` | Primary control panel |
| `PhrasesListView` | Preset phrase editor |
| `SpeechShortcutsView` | Quick phrase buttons |
| `SpeechToggleView` | Auto-read toggle |
| `UsageSettingsView` | Usage settings panel |

## Application Flow

### Main View Hierarchy

```
HandwritingToSpeechSwiftUIApp
├── [if !authenticated]
│   └── AppleSignInView
│       └── AppleSignInButton
└── [if authenticated]
    └── ContentView
        ├── ControlButtonsView
        ├── TextInputWithSpeakButton
        ├── SpeechToggleView
        └── SpeechShortcutsView
```

### Authentication Flow

```
┌──────────────┐    ┌───────────────┐    ┌──────────────┐
│ AppleSignIn  │───►│ Backend API   │───►│ KeychainMgr  │
│ View         │    │ /auth/mobile  │    │ (store JWT)  │
└──────────────┘    └───────────────┘    └──────────────┘
       │                   │                    │
       │ 1. User taps     │                    │
       │    Sign In       │                    │
       │                  │                    │
       │ 2. Apple ID      │                    │
       │    token         │                    │
       │─────────────────►│                    │
       │                  │                    │
       │ 3. JWT token     │                    │
       │◄─────────────────│                    │
       │                  │                    │
       │ 4. Store token   │                    │
       │──────────────────────────────────────►│
```

### Text-to-Speech Flow

```
User Input ──► TextEditor ──► SpeechService ──► AVFoundation
                    │                              or
                    │                          ElevenLabs API
                    │
                    └──► [if autoRead enabled]
                         Wait 3 seconds ──► Speak
```

## State Management

### Global State (EnvironmentObject)

```swift
// App-level state injection
ContentView()
    .environmentObject(userModel)
    .environmentObject(speechService)
    .environmentObject(presetManager)
```

### Local State (@State, @StateObject)

```swift
@State private var recognizedText: String = ""
@State private var autoRead: Bool = false
@State private var showPhraseManager: Bool = false
```

## Configuration

### Development Flags

| Flag | Purpose | Default |
|------|---------|---------|
| `API.bypassServerAPI` | Skip backend calls | `true` |
| `Features.skipAuthentication` | Bypass auth flow | `true` |

### ElevenLabs Configuration

| Setting | Description |
|---------|-------------|
| `apiKey` | ElevenLabs API key |
| `voiceId` | Selected voice identifier |

## Security Implementation

### Keychain Storage

- JWT tokens stored in iOS Keychain
- Credentials never stored in UserDefaults
- Automatic cleanup on sign out

### Privacy Considerations

- Location data optional
- Usage logs anonymized before sync
- No PII stored locally beyond user preferences

## Error Handling

```swift
// Error display pattern
.alert("Erreur", isPresented: $speechService.showError) {
    Button("OK") { speechService.showError = false }
} message: {
    Text(speechService.errorMessage)
}
```

## UI/UX Patterns

### Accessibility Features

- Large touch targets (50x50pt minimum)
- High contrast colors
- VoiceOver labels on all controls
- Auto-read mode for hands-free operation

### Visual Design

- Blue primary color scheme
- Green accent for speak button
- Card-based layout
- Floating action button pattern
