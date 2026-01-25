# CalliVox Development Guide

**Generated:** 2026-01-25

## Prerequisites

### Common Requirements

- Git
- Code editor (VS Code, Xcode)
- Internet connection for dependencies

### Backend Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Node.js | 18+ LTS | Runtime |
| npm/yarn | Latest | Package manager |
| PostgreSQL | 14+ | Database |
| Docker | Optional | Database containerization |

### iOS App Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Xcode | 15+ | IDE and build tools |
| macOS | Sonoma+ | Development OS |
| iOS Simulator | iOS 17+ | Testing |
| Apple Developer Account | - | Signing and Apple Sign In |

### Website Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| Any web browser | Modern | Testing |
| Local server | Optional | Live reload |

## Project Setup

### Clone Repository

```bash
git clone <repository-url>
cd CalliVox
```

### Backend Setup

```bash
# Navigate to backend
cd calli-vox-backend

# Install dependencies
npm install

# Setup environment
cp .env.example .env
# Edit .env with your configuration

# Database setup
npx prisma migrate dev

# Start development server
npm run start:dev
```

#### Backend Environment Variables

Create `.env` file:

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/callivox"

# JWT
JWT_SECRET="your-secure-secret-key-min-32-chars"

# Apple Sign In
APPLE_CLIENT_ID="com.yourcompany.callivox"
APPLE_TEAM_ID="XXXXXXXXXX"
APPLE_KEY_ID="XXXXXXXXXX"
APPLE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----"
APPLE_CALLBACK_URL="https://api.callivox.app/auth/apple/callback"
```

#### Database Setup with Docker

```bash
# Start PostgreSQL container
docker run -d \
  --name callivox-db \
  -e POSTGRES_USER=callivox \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DB=callivox \
  -p 5432:5432 \
  postgres:14

# Update DATABASE_URL
DATABASE_URL="postgresql://callivox:password@localhost:5432/callivox"
```

### iOS App Setup

```bash
# Navigate to iOS project
cd HandwritingToSpeechSwiftUI

# Open in Xcode
open HandwritingToSpeechSwiftUI.xcodeproj
```

#### Xcode Configuration

1. **Select Development Team**
   - Open project settings
   - Select your Apple Developer team for signing

2. **Configure App Config**
   - Edit `Models/AppConfig.swift`
   - Set `API.baseURL` for your backend
   - Set `ElevenLabs.apiKey` and `voiceId`

3. **Development Flags**
   ```swift
   // For local development without backend
   static let bypassServerAPI = true
   static let skipAuthentication = true
   ```

### Website Setup

```bash
# Navigate to website
cd CalliVox-Site

# Option 1: Open directly
open index.html

# Option 2: Use local server
npx serve .
# or
python -m http.server 8000
```

## Development Workflow

### Backend Development

```bash
# Start development server (with hot reload)
npm run start:dev

# Build for production
npm run build

# Run production build
npm run start:prod

# Format code
npm run format

# Lint code
npm run lint
```

**API Documentation:** Available at `http://localhost:8080/api`

### iOS Development

1. **Run on Simulator**
   - Select target device in Xcode toolbar
   - Press `Cmd+R` to build and run

2. **Run on Physical Device**
   - Connect device via USB
   - Select device in Xcode toolbar
   - Press `Cmd+R` to build and run

3. **Development Flags**
   - Set flags in `AppConfig.swift` for local testing
   - `bypassServerAPI = true` skips backend calls
   - `skipAuthentication = true` skips login screen

### Website Development

- Edit HTML/CSS/JS files directly
- Refresh browser to see changes
- Use browser DevTools for debugging

## Code Structure

### Backend Architecture

```
src/
├── main.ts           # Entry point, bootstrap
├── app.module.ts     # Root module
├── auth/             # Authentication module
│   ├── *.controller  # HTTP endpoints
│   ├── *.service     # Business logic
│   └── *.strategy    # Passport strategies
├── stats/            # Statistics module
│   ├── *.controller  # HTTP endpoints
│   └── *.service     # Business logic
└── prisma/           # Database module
    └── *.service     # Prisma client
```

### iOS App Architecture

```
HandwritingToSpeechSwiftUI/
├── *App.swift        # Entry point
├── ContentView.swift # Main view
├── Models/           # Data structures
├── Managers/         # Services/business logic
└── Views/            # UI components
```

## Testing

### Backend Testing

```bash
# Run unit tests
npm run test

# Run e2e tests
npm run test:e2e

# Test coverage
npm run test:cov
```

### iOS Testing

1. **Unit Tests**
   - Press `Cmd+U` in Xcode
   - Or run from Test Navigator

2. **UI Tests**
   - Create UI test targets
   - Use XCUITest framework

### Manual Testing Checklist

**Backend:**

- [ ] Health check endpoint responds
- [ ] Swagger UI loads at /api
- [ ] Apple Sign In callback works
- [ ] Stats endpoints require auth
- [ ] Database connections work

**iOS App:**

- [ ] App launches without crash
- [ ] Apple Sign In flow works
- [ ] Text input accepts text
- [ ] Speak button triggers TTS
- [ ] Preset phrases display
- [ ] Auto-read mode works
- [ ] Offline mode stores logs

**Website:**

- [ ] All sections display
- [ ] Navigation works
- [ ] Responsive on mobile
- [ ] Animations trigger
- [ ] Links are valid

## Common Issues

### Backend

**Issue:** Database connection failed
**Solution:** Check DATABASE_URL and PostgreSQL is running

**Issue:** Apple Sign In verification fails
**Solution:** Verify APPLE_* environment variables are correct

**Issue:** JWT token invalid
**Solution:** Check JWT_SECRET matches between environments

### iOS App

**Issue:** Build fails with signing error
**Solution:** Select valid development team in Xcode

**Issue:** Network requests fail
**Solution:** Check `API.baseURL` and backend is running

**Issue:** ElevenLabs not working
**Solution:** Verify API key and voice ID in AppConfig

### Website

**Issue:** Animations not working
**Solution:** Check AOS library is loaded from CDN

**Issue:** Carousel not sliding
**Solution:** Check Owl Carousel and jQuery are loaded

## Deployment

### Backend Deployment

```bash
# Build
npm run build

# Deploy (example: Railway, Heroku, etc.)
# Set all environment variables in deployment platform
```

### iOS App Deployment

1. Archive in Xcode (`Product > Archive`)
2. Upload to App Store Connect
3. Submit for review

### Website Deployment

Upload files to any static hosting:

- Netlify
- Vercel
- GitHub Pages
- AWS S3 + CloudFront

## Contributing Guidelines

### Commit Convention

```
type(scope): description

Examples:
feat(auth): add Apple Sign In support
fix(speech): handle empty text input
docs(readme): update setup instructions
```

### Branch Strategy

- `main` - Production ready
- `develop` - Integration branch
- `feature/*` - New features
- `fix/*` - Bug fixes

### Pull Request Process

1. Create feature branch from `develop`
2. Make changes with tests
3. Submit PR to `develop`
4. Code review
5. Merge after approval

## Resources

### Documentation

- [NestJS Docs](https://docs.nestjs.com/)
- [Prisma Docs](https://www.prisma.io/docs)
- [SwiftUI Docs](https://developer.apple.com/documentation/swiftui)
- [ElevenLabs API](https://elevenlabs.io/docs)

### Apple Developer

- [Sign In with Apple](https://developer.apple.com/sign-in-with-apple/)
- [App Store Connect](https://appstoreconnect.apple.com/)
