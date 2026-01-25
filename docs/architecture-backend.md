# CalliVox Backend - Architecture Documentation

**Part ID:** backend
**Project Type:** Backend API
**Generated:** 2026-01-25

## Executive Summary

The CalliVox backend is a NestJS API server providing authentication via Apple Sign In and usage statistics tracking. It uses PostgreSQL for persistence via Prisma ORM and implements JWT-based session management with 30-day token expiry.

## Technology Stack

| Category | Technology | Version | Purpose |
|----------|------------|---------|---------|
| Framework | NestJS | ^11.0.1 | API framework |
| Language | TypeScript | ^5.7.2 | Type-safe JavaScript |
| ORM | Prisma | ^6.2.1 | Database access |
| Database | PostgreSQL | - | Data persistence |
| Authentication | Passport.js | ^0.7.0 | Auth strategies |
| JWT | @nestjs/jwt | ^11.0.0 | Token management |
| API Docs | @nestjs/swagger | ^11.0.3 | OpenAPI documentation |

## Architecture Pattern

**Style:** Layered Architecture with Modular Design

```
┌─────────────────────────────────────────────┐
│              Controllers Layer              │
│   (auth.controller, stats.controller)       │
├─────────────────────────────────────────────┤
│              Services Layer                 │
│   (auth.service, stats.service)             │
├─────────────────────────────────────────────┤
│              Guards/Strategies              │
│   (jwt-auth.guard, apple.strategy)          │
├─────────────────────────────────────────────┤
│              Data Access Layer              │
│   (prisma.service)                          │
├─────────────────────────────────────────────┤
│              Database                       │
│   (PostgreSQL via Prisma)                   │
└─────────────────────────────────────────────┘
```

## Module Structure

### AppModule (Root)

```typescript
@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    AuthModule,
    StatsModule,
  ],
})
export class AppModule {}
```

### AuthModule

**Purpose:** Handle Apple Sign In authentication and JWT token management

**Components:**

- `AuthController` - Endpoints for web and mobile authentication
- `AuthService` - User validation and creation logic
- `AppleStrategy` - Passport strategy for Apple OAuth
- `JwtStrategy` - Passport strategy for JWT validation
- `JwtAuthGuard` - Route protection decorator

**Key Configuration:**

```typescript
JwtModule.register({
  secret: process.env.JWT_SECRET,
  signOptions: { expiresIn: '30d' },
})
```

### StatsModule

**Purpose:** Track and retrieve usage statistics with privacy preservation

**Components:**

- `StatsController` - Endpoints for logging and retrieving stats
- `StatsService` - Business logic with pseudonymization

**Privacy Implementation:**

```typescript
// User ID pseudonymization for privacy
private pseudonymize(userId: string): string {
  return crypto.createHash('sha256').update(userId).digest('hex');
}
```

### PrismaModule

**Purpose:** Provide database access throughout the application

**Components:**

- `PrismaService` - Extends PrismaClient with lifecycle hooks

## Authentication Flow

### Apple Sign In (Mobile)

```
┌──────────┐    ┌───────────┐    ┌──────────┐    ┌────────────┐
│ iOS App  │───►│ Apple ID  │───►│ Backend  │───►│ PostgreSQL │
└──────────┘    └───────────┘    └──────────┘    └────────────┘
     │               │                │                 │
     │  1. Request   │                │                 │
     │──────────────►│                │                 │
     │               │                │                 │
     │  2. ID Token  │                │                 │
     │◄──────────────│                │                 │
     │               │                │                 │
     │  3. POST /auth/apple/mobile    │                 │
     │───────────────────────────────►│                 │
     │               │                │  4. Upsert User │
     │               │                │────────────────►│
     │               │                │                 │
     │  5. JWT Token │                │                 │
     │◄───────────────────────────────│                 │
```

### JWT Token Structure

```typescript
{
  userId: string,    // Apple user identifier
  email?: string,    // Optional email
  exp: number,       // 30 days from issue
  iat: number        // Issue timestamp
}
```

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/auth/apple` | No | Web OAuth redirect |
| GET | `/auth/apple/callback` | No | Web OAuth callback |
| POST | `/auth/apple/mobile` | No | Mobile token exchange |
| POST | `/stats` | JWT | Log usage event |
| GET | `/stats/user` | JWT | Get user statistics |
| GET | `/stats/admin` | JWT | Get all statistics (admin) |

## Configuration

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `DATABASE_URL` | PostgreSQL connection string | Yes |
| `JWT_SECRET` | JWT signing secret | Yes |
| `APPLE_CLIENT_ID` | Apple OAuth client ID | Yes |
| `APPLE_TEAM_ID` | Apple Developer team ID | Yes |
| `APPLE_KEY_ID` | Apple private key ID | Yes |
| `APPLE_PRIVATE_KEY` | Apple private key (PEM) | Yes |
| `APPLE_CALLBACK_URL` | OAuth callback URL | Yes |

### Bootstrap Configuration

```typescript
// main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.enableCors();  // CORS enabled for mobile access

  // Swagger documentation at /api
  const config = new DocumentBuilder()
    .setTitle('CalliVox API')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  SwaggerModule.setup('api', app, document);

  await app.listen(8080);
}
```

## Error Handling

- Authentication failures return 401 Unauthorized
- Validation errors return 400 Bad Request
- Database errors return 500 Internal Server Error
- All errors are logged for debugging

## Security Considerations

1. **JWT Secret:** Must be cryptographically strong, stored in environment
2. **Token Expiry:** 30-day expiry balances security with UX
3. **Pseudonymization:** User IDs hashed before storage for privacy
4. **CORS:** Enabled for mobile app access
5. **No Passwords:** Apple Sign In eliminates password storage risks
