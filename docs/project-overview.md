# CalliVox - Project Overview

**Generated:** 2026-01-25
**Workflow Version:** 1.2.0
**Scan Level:** Exhaustive

## Executive Summary

CalliVox is an accessibility application designed to help users with speech impairments communicate through text-to-speech technology. The application supports handwriting recognition via Apple Pencil, predefined phrase shortcuts, and high-quality voice synthesis through ElevenLabs API integration.

## Project Structure

| Attribute | Value |
|-----------|-------|
| **Repository Type** | Multi-part |
| **Parts Count** | 3 |
| **Primary Languages** | TypeScript, Swift, HTML/CSS/JS |
| **Architecture Style** | Client-Server with Mobile App |

## Project Parts

### 1. Backend (calli-vox-backend)

- **Type:** Backend API
- **Language:** TypeScript
- **Framework:** NestJS
- **Database:** PostgreSQL (via Prisma ORM)
- **Purpose:** Authentication, usage statistics, user management

### 2. iOS App (HandwritingToSpeechSwiftUI)

- **Type:** Mobile Application
- **Language:** Swift
- **Framework:** SwiftUI
- **Purpose:** Primary user interface for text-to-speech with Apple Pencil support

### 3. Website (CalliVox-Site)

- **Type:** Static Website
- **Languages:** HTML, CSS, JavaScript
- **Purpose:** Marketing landing page with pricing and app download links

## Technology Stack Summary

| Category | Backend | iOS App | Website |
|----------|---------|---------|---------|
| **Language** | TypeScript | Swift | HTML/CSS/JS |
| **Framework** | NestJS | SwiftUI | Dazzle Template |
| **Authentication** | JWT + Apple Sign In | Apple Sign In + Keychain | N/A |
| **Database** | PostgreSQL | Local Storage | N/A |
| **TTS Engine** | N/A | AVFoundation + ElevenLabs | N/A |

## Key Features

1. **Text-to-Speech Conversion** - Converts typed or handwritten text to speech
2. **Apple Pencil Support** - Handwriting recognition for natural input
3. **Predefined Phrases** - Quick access to frequently used sentences
4. **Auto-Read Mode** - Automatic speech after typing pause (3 seconds)
5. **Usage Statistics** - Tracks usage patterns with privacy-preserving pseudonymization
6. **Offline Support** - Usage logging works offline with sync capability
7. **ElevenLabs Integration** - High-quality AI voice synthesis

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         CalliVox System                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐         ┌──────────────────────────────┐  │
│  │   iOS App        │         │        Backend API           │  │
│  │  (SwiftUI)       │◄───────►│        (NestJS)              │  │
│  │                  │  REST   │                              │  │
│  │  - ContentView   │         │  - Auth Module               │  │
│  │  - SpeechService │         │    └─ Apple Sign In          │  │
│  │  - KeychainMgr   │         │    └─ JWT Generation         │  │
│  │  - UsageLogMgr   │         │  - Stats Module              │  │
│  │  - PresetMgr     │         │    └─ Usage Logging          │  │
│  └────────┬─────────┘         │    └─ User Statistics        │  │
│           │                   └───────────┬──────────────────┘  │
│           │                               │                      │
│           ▼                               ▼                      │
│  ┌──────────────────┐         ┌──────────────────────────────┐  │
│  │   ElevenLabs     │         │       PostgreSQL             │  │
│  │   API            │         │       Database               │  │
│  │  (Voice Synth)   │         │  - UserProfile               │  │
│  └──────────────────┘         │  - UsageStat                 │  │
│                               └──────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                    Marketing Website                      │   │
│  │                    (Static HTML/CSS/JS)                   │   │
│  │   - Landing Page    - Pricing (€120/year, €500 lifetime)  │   │
│  │   - Features        - App Store Download Links            │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

## Security Model

- **Authentication:** Apple Sign In OAuth with JWT tokens (30-day expiry)
- **Privacy:** User IDs pseudonymized via SHA256 hashing
- **Token Storage:** iOS Keychain for secure credential storage
- **API Security:** JWT-protected endpoints with Passport.js guards

## Business Model

- **Annual Subscription:** €120/year
- **Lifetime License:** €500 one-time payment
- **Target Users:** People with speech impairments

## Documentation Index

- [Source Tree Analysis](./source-tree-analysis.md)
- [Architecture - Backend](./architecture-backend.md)
- [Architecture - iOS App](./architecture-ios-app.md)
- [Architecture - Website](./architecture-site.md)
- [API Contracts](./api-contracts-backend.md)
- [Data Models](./data-models-backend.md)
- [Integration Architecture](./integration-architecture.md)
- [Development Guide](./development-guide.md)
