# CalliVox - Source Tree Analysis

**Generated:** 2026-01-25

## Complete Project Structure

```
CalliVox/
├── calli-vox-backend/              # NestJS Backend API
│   ├── src/
│   │   ├── main.ts                 # Application entry point (port 8080)
│   │   ├── app.module.ts           # Root module configuration
│   │   ├── auth/                   # Authentication module
│   │   │   ├── auth.module.ts      # Auth module definition
│   │   │   ├── auth.controller.ts  # Auth endpoints (/auth/apple/*)
│   │   │   ├── auth.service.ts     # User validation and JWT generation
│   │   │   ├── apple.strategy.ts   # Apple OAuth strategy
│   │   │   ├── jwt.strategy.ts     # JWT validation strategy
│   │   │   └── jwt-auth.guard.ts   # Route protection guard
│   │   ├── stats/                  # Usage statistics module
│   │   │   ├── stats.module.ts     # Stats module definition
│   │   │   ├── stats.controller.ts # Stats endpoints (POST/GET)
│   │   │   └── stats.service.ts    # Stats logic with pseudonymization
│   │   └── prisma/                 # Database ORM layer
│   │       ├── prisma.module.ts    # Prisma module definition
│   │       └── prisma.service.ts   # Prisma client service
│   ├── prisma/
│   │   └── schema.prisma           # Database schema definition
│   ├── package.json                # Node.js dependencies
│   ├── tsconfig.json               # TypeScript configuration
│   └── nest-cli.json               # NestJS CLI configuration
│
├── HandwritingToSpeechSwiftUI/     # SwiftUI iOS Application
│   ├── HandwritingToSpeechSwiftUI/
│   │   ├── HandwritingToSpeechSwiftUIApp.swift  # App entry point
│   │   ├── ContentView.swift       # Main UI view
│   │   ├── Models/
│   │   │   ├── AppConfig.swift     # API configuration & feature flags
│   │   │   ├── UserModel.swift     # User state management
│   │   │   └── UsageLogModel.swift # Usage log data structure
│   │   ├── Managers/
│   │   │   ├── SpeechService.swift     # TTS service (AVFoundation + ElevenLabs)
│   │   │   ├── KeychainManager.swift   # Secure credential storage
│   │   │   ├── UsageLogManager.swift   # Offline usage logging + sync
│   │   │   ├── PresetSentenceManager.swift  # Preset phrases management
│   │   │   └── AudioManager.swift      # Audio session management
│   │   └── Views/
│   │       ├── AppleSignInButton.swift  # Apple Sign In button component
│   │       ├── AppleSignInView.swift    # Authentication flow view
│   │       ├── ControlButtonsView.swift # Main control buttons
│   │       ├── PhrasesListView.swift    # Preset phrases editor
│   │       ├── SpeechShortcutsView.swift # Quick phrase buttons
│   │       ├── SpeechToggleView.swift   # Auto-read toggle
│   │       └── UsageSettingsView.swift  # Usage settings panel
│   └── HandwritingToSpeechSwiftUI.xcodeproj/
│
└── CalliVox-Site/                  # Marketing Website
    ├── index.html                  # Main landing page (French)
    ├── css/
    │   └── main.css                # Primary stylesheet (Dazzle template)
    └── js/
        └── main.js                 # jQuery interactions and animations
```

## Critical Directories

### Backend Critical Paths

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `src/auth/` | Authentication system | Controllers, strategies, guards |
| `src/stats/` | Usage statistics | Logging, pseudonymization |
| `src/prisma/` | Database layer | Prisma client, schema |
| `prisma/` | Schema definitions | `schema.prisma` |

### iOS App Critical Paths

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `Models/` | Data structures | AppConfig, UserModel, UsageLogModel |
| `Managers/` | Business logic | SpeechService, KeychainManager, UsageLogManager |
| `Views/` | UI components | All SwiftUI views |

### Website Critical Paths

| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `css/` | Styling | main.css (Dazzle template) |
| `js/` | Interactions | main.js (jQuery) |

## Entry Points

| Part | Entry Point | Description |
|------|-------------|-------------|
| Backend | `src/main.ts` | NestJS bootstrap, Swagger setup, port 8080 |
| iOS App | `HandwritingToSpeechSwiftUIApp.swift` | SwiftUI @main app entry |
| Website | `index.html` | Static HTML landing page |

## Integration Points

```
iOS App ──────► Backend API ──────► PostgreSQL
    │               │
    │               ├─► /auth/apple/mobile (POST)
    │               ├─► /stats (POST)
    │               └─► /stats/user (GET)
    │
    └───────────► ElevenLabs API
                    └─► Voice synthesis
```

## File Statistics

| Part | Files | Lines of Code | Primary Extension |
|------|-------|---------------|-------------------|
| Backend | 17 | ~800 | .ts |
| iOS App | 17 | ~1500 | .swift |
| Website | 4 | ~3500 | .html, .css, .js |
