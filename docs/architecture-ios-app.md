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
| TTS Engine | Gradium API | AI voice synthesis |
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

#### AccessibilitySettings

**Purpose:** Enhanced accessibility mode configuration

```swift
@MainActor
class AccessibilitySettings: ObservableObject {
    @Published var isEnhancedModeEnabled: Bool
    @Published var isFatigueModeEnabled: Bool
    @Published var requireConfirmationDialogs: Bool

    var buttonHeight: CGFloat  // 60pt (standard) or 80pt (enhanced)
}
```

#### TimeBasedPhraseSettings

**Purpose:** Time-based predictive phrase management

```swift
@MainActor
class TimeBasedPhraseSettings: ObservableObject {
    static let shared: TimeBasedPhraseSettings

    @Published var morningPhrases: [String]   // 7h-9h
    @Published var lunchPhrases: [String]     // 12h-14h
    @Published var eveningPhrases: [String]   // 18h-20h
    @Published var nightPhrases: [String]     // 21h-23h

    func phrasesForCurrentTime() -> [String]
    func resetToDefaults()
}
```

#### ScanningModeSettings

**Purpose:** Scanning mode configuration for reduced mobility users

```swift
@MainActor
class ScanningModeSettings: ObservableObject {
    static let shared: ScanningModeSettings

    @Published var isEnabled: Bool
    @Published var scanSpeed: ScanSpeed       // slow (3s), normal (2s), fast (1s)
    @Published var scanDirection: ScanDirection // forwardOnly, forwardAndBackward
    @Published var autoRestart: Bool
    @Published var soundFeedbackEnabled: Bool

    func resetToDefaults()
}
```

#### ScanningModeController

**Purpose:** Runtime state machine for active scanning

```swift
@MainActor
class ScanningModeController: ObservableObject {
    static let shared: ScanningModeController

    @Published var currentHighlightedIndex: Int?
    @Published var isScanning: Bool
    @Published var isPaused: Bool

    func startScanning(itemCount: Int)
    func stopScanning()
    func selectCurrentItem() -> Int?
    func resumeScanning()
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
| `AccessibilitySettingsView` | Enhanced accessibility configuration |
| `TimeBasedPhrasesSettingsView` | Time-based phrase customization |
| `ScanningModeSettingsView` | Scanning mode configuration |
| `EmergencyPanelView` | Emergency messages panel |
| `FatigueModeView` | Simplified fatigue mode interface |
| `FatigueModeSettingsView` | Fatigue mode button customization |
| `EmergencyMessagesSettingsView` | Emergency message customization |

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

- **Enhanced Mode:** Large touch targets (80pt), high contrast, reduced animations
- **Standard Mode:** Touch targets (60pt minimum)
- VoiceOver labels on all controls (French)
- Auto-read mode for hands-free operation
- **Scanning Mode:** Sequential button highlighting for severely reduced mobility users
  - Configurable speed (1s/2s/3s)
  - Direction options (forward only, forward-backward)
  - Audio and haptic feedback
- **Fatigue Mode:** Simplified 4-button interface for high fatigue situations
- **Emergency Panel:** Quick access to 4 customizable emergency messages
- **Time-based Phrases:** Context-aware suggestions based on time of day
- Confirmation dialogs for destructive actions (optional)

### Visual Design

- Blue primary color scheme
- Green accent for speak button
- Card-based layout
- Floating action button pattern
