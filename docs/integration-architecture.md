# CalliVox Integration Architecture

**Generated:** 2026-01-25

## System Overview

CalliVox is a multi-part system with three distinct components that integrate through REST APIs and external services.

```
┌─────────────────────────────────────────────────────────────────────┐
│                        CalliVox Ecosystem                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐                         ┌─────────────────────┐   │
│  │   Website   │                         │    iOS App          │   │
│  │   (Static)  │                         │    (SwiftUI)        │   │
│  │             │                         │                     │   │
│  │  - Landing  │                         │  - Text Input       │   │
│  │  - Pricing  │                         │  - Speech Output    │   │
│  │  - Download │                         │  - Auth Flow        │   │
│  └──────┬──────┘                         └──────────┬──────────┘   │
│         │                                           │               │
│         │ (App Store Link)                          │ REST API      │
│         │                                           │               │
│         │                                           ▼               │
│         │                                ┌─────────────────────┐   │
│         │                                │   Backend API       │   │
│         │                                │   (NestJS)          │   │
│         │                                │                     │   │
│         │                                │  - Authentication   │   │
│         │                                │  - Usage Stats      │   │
│         │                                └──────────┬──────────┘   │
│         │                                           │               │
│         │                                           │               │
│         ▼                                           ▼               │
│  ┌──────────────┐    ┌──────────────┐    ┌─────────────────────┐   │
│  │  App Store   │    │  ElevenLabs  │    │    PostgreSQL       │   │
│  │              │    │  API         │    │    Database         │   │
│  └──────────────┘    └──────────────┘    └─────────────────────┘   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Integration Points

### 1. iOS App ↔ Backend API

**Protocol:** HTTPS REST
**Base URL:** `https://api.callivox.app`

| Flow | Endpoint | Method | Data |
|------|----------|--------|------|
| Authentication | `/auth/apple/mobile` | POST | Apple ID token → JWT |
| Log Usage | `/stats` | POST | Sentence, location, device |
| Get Stats | `/stats/user` | GET | User statistics |

**Authentication Flow:**

```
iOS App                    Backend                    Apple
   │                          │                         │
   │  1. Sign In with Apple   │                         │
   │─────────────────────────────────────────────────► │
   │                          │                         │
   │  2. Identity Token       │                         │
   │◄─────────────────────────────────────────────────  │
   │                          │                         │
   │  3. POST /auth/apple/mobile                        │
   │─────────────────────────►│                         │
   │                          │  4. Verify Token        │
   │                          │────────────────────────►│
   │                          │                         │
   │                          │  5. Token Valid         │
   │                          │◄────────────────────────│
   │                          │                         │
   │  6. JWT Token            │                         │
   │◄─────────────────────────│                         │
```

**Usage Logging Flow:**

```
iOS App                    Backend                    Database
   │                          │                         │
   │  1. User speaks text     │                         │
   │                          │                         │
   │  2. POST /stats          │                         │
   │     {sentence, location} │                         │
   │─────────────────────────►│                         │
   │                          │  3. Pseudonymize userId │
   │                          │  4. INSERT UsageStat    │
   │                          │────────────────────────►│
   │                          │                         │
   │  5. Success              │                         │
   │◄─────────────────────────│                         │
```

### 2. iOS App ↔ ElevenLabs API

**Protocol:** HTTPS REST
**Base URL:** `https://api.elevenlabs.io`

| Flow | Endpoint | Method | Data |
|------|----------|--------|------|
| Text-to-Speech | `/v1/text-to-speech/{voice_id}` | POST | Text → Audio |

**Voice Synthesis Flow:**

```
iOS App                    ElevenLabs
   │                          │
   │  1. POST /v1/text-to-speech/{voice_id}
   │     {text, model_id, voice_settings}
   │─────────────────────────►│
   │                          │
   │  2. Audio Stream (MP3)   │
   │◄─────────────────────────│
   │                          │
   │  3. Play via AVFoundation│
```

### 3. iOS App ↔ Apple Services

**Services Used:**

| Service | Purpose | SDK |
|---------|---------|-----|
| Sign In with Apple | User authentication | AuthenticationServices |
| Keychain | Secure token storage | Security framework |
| AVFoundation | Native TTS | AVFoundation |

### 4. Website → App Store

**Integration:** Deep link to App Store listing

```html
<a href="https://apps.apple.com/app/callivox/id123456789">
  Download on the App Store
</a>
```

## Data Flow

### User Registration

```
1. User opens iOS app
2. App shows Apple Sign In
3. User authenticates with Apple
4. App receives identity token
5. App sends token to backend
6. Backend verifies with Apple
7. Backend creates/updates UserProfile
8. Backend returns JWT
9. App stores JWT in Keychain
```

### Usage Tracking

```
1. User types/writes text
2. App calls SpeechService.speakText()
3. SpeechService plays audio (AVFoundation or ElevenLabs)
4. UsageLogManager.logUsage() called
5. If online: POST to /stats
6. If offline: Store locally, sync later
```

### Offline Sync

```
1. App stores UsageLog locally when offline
2. On app launch, check for pending logs
3. If authenticated and online: submitOfflineLogs()
4. POST each pending log to /stats
5. Remove successfully synced logs
```

## Security Architecture

### Token Flow

```
┌────────────────┐     ┌────────────────┐     ┌────────────────┐
│    Apple ID    │────►│   Backend      │────►│   iOS App      │
│    Token       │     │   (JWT Gen)    │     │   (Keychain)   │
└────────────────┘     └────────────────┘     └────────────────┘
      │                       │                       │
      │ Short-lived           │ 30-day JWT            │ Secure
      │ (minutes)             │                       │ Storage
```

### Privacy Protection

```
                    Pseudonymization Layer
                           │
User ID ────► SHA256 ────► Hashed ID ────► Analytics/Stats
   │                                              │
   │                                              │
   └──────────────────────────────────────────────┘
         Original ID never exposed in stats
```

## Configuration Management

### Backend Environment

```
DATABASE_URL=postgresql://...
JWT_SECRET=...
APPLE_CLIENT_ID=...
APPLE_TEAM_ID=...
APPLE_KEY_ID=...
APPLE_PRIVATE_KEY=...
```

### iOS App Configuration

```swift
struct AppConfig {
    struct API {
        static let baseURL = "https://api.callivox.app"
        static let bypassServerAPI = true  // Dev only
    }
    struct ElevenLabs {
        static let apiKey = "..."
        static let voiceId = "..."
    }
}
```

## Error Handling

### iOS App → Backend

| Error Type | Handling |
|------------|----------|
| Network unavailable | Queue for offline sync |
| 401 Unauthorized | Refresh auth, re-login |
| 500 Server Error | Retry with backoff |

### iOS App → ElevenLabs

| Error Type | Handling |
|------------|----------|
| Network unavailable | Fall back to AVFoundation |
| API quota exceeded | Fall back to AVFoundation |
| Invalid voice ID | Use default voice |

## Monitoring Recommendations

### Backend Metrics

- Request count by endpoint
- Response time percentiles
- Error rate by type
- Active users (JWT validations)

### iOS App Analytics

- Speech events per user
- Offline sync success rate
- ElevenLabs vs AVFoundation usage
- Session duration

## Future Integration Considerations

1. **Push Notifications** - Firebase/APNs for sync reminders
2. **Analytics** - Firebase Analytics or custom solution
3. **Crash Reporting** - Crashlytics or Sentry
4. **Feature Flags** - Remote configuration service
