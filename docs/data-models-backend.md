# CalliVox Data Models

**Part:** Backend
**ORM:** Prisma
**Database:** PostgreSQL
**Generated:** 2026-01-25

## Schema Overview

```
┌─────────────────┐         ┌─────────────────┐
│   UserProfile   │────────<│   UsageStat     │
│                 │  1:N    │                 │
│  id (PK)        │         │  id (PK)        │
│  createdAt      │         │  userId (FK)    │
│  updatedAt      │         │  sentence       │
└─────────────────┘         │  timestamp      │
                            │  location       │
                            │  deviceInfo     │
                            └─────────────────┘
```

## Prisma Schema

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model UserProfile {
  id        String      @id
  createdAt DateTime    @default(now())
  updatedAt DateTime    @updatedAt
  stats     UsageStat[]
}

model UsageStat {
  id         String      @id @default(uuid())
  userId     String
  user       UserProfile @relation(fields: [userId], references: [id])
  location   Json?
  sentence   String
  timestamp  DateTime    @default(now())
  deviceInfo String?
}
```

## Model Definitions

### UserProfile

**Purpose:** Store user account information

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | String | Primary Key | Apple User ID |
| `createdAt` | DateTime | Default: now() | Account creation timestamp |
| `updatedAt` | DateTime | Auto-updated | Last modification timestamp |
| `stats` | UsageStat[] | Relation | User's usage statistics |

**Notes:**

- The `id` field stores the Apple User ID directly (e.g., "001234.abcdef1234567890.1234")
- No email or personal data stored in UserProfile for privacy

### UsageStat

**Purpose:** Track individual text-to-speech usage events

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | String | Primary Key, UUID | Unique event identifier |
| `userId` | String | Foreign Key | Reference to UserProfile |
| `sentence` | String | Required | The spoken text |
| `timestamp` | DateTime | Default: now() | When the event occurred |
| `location` | Json | Optional | GPS coordinates |
| `deviceInfo` | String | Optional | Device information |

**Location JSON Structure:**

```json
{
  "latitude": 48.8566,
  "longitude": 2.3522
}
```

## Relationships

### UserProfile → UsageStat (One-to-Many)

```
UserProfile.stats -> UsageStat[]
UsageStat.user -> UserProfile
```

**Cascade Behavior:**

- When a UserProfile is deleted, associated UsageStat records are preserved (userId becomes orphaned)
- Consider adding `onDelete: Cascade` for GDPR compliance

## Indexes

### Recommended Indexes (Add to schema)

```prisma
model UsageStat {
  // ... fields ...

  @@index([userId])
  @@index([timestamp])
  @@index([userId, timestamp])
}
```

## Migrations

### Initial Migration

```sql
-- CreateTable
CREATE TABLE "UserProfile" (
    "id" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "UsageStat" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "location" JSONB,
    "sentence" TEXT NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deviceInfo" TEXT,

    CONSTRAINT "UsageStat_pkey" PRIMARY KEY ("id")
);

-- AddForeignKey
ALTER TABLE "UsageStat" ADD CONSTRAINT "UsageStat_userId_fkey"
    FOREIGN KEY ("userId") REFERENCES "UserProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
```

## Privacy Considerations

### Pseudonymization

The `StatsService` pseudonymizes user IDs before querying/aggregating:

```typescript
private pseudonymize(userId: string): string {
  return crypto.createHash('sha256').update(userId).digest('hex');
}
```

This ensures:

- Raw Apple User IDs are stored for authentication
- Analytics queries use hashed IDs
- User identity is protected in reports

### Data Retention

Consider implementing:

- Automatic deletion after X days
- User data export (GDPR)
- Complete data deletion on request

## Query Examples

### Create User on First Login

```typescript
await prisma.userProfile.upsert({
  where: { id: appleUserId },
  update: { updatedAt: new Date() },
  create: { id: appleUserId }
});
```

### Log Usage Event

```typescript
await prisma.usageStat.create({
  data: {
    userId: appleUserId,
    sentence: "Hello, how are you?",
    location: { latitude: 48.8566, longitude: 2.3522 },
    deviceInfo: "iPhone 15 Pro, iOS 17.2"
  }
});
```

### Get User Statistics

```typescript
const stats = await prisma.usageStat.findMany({
  where: { userId: appleUserId },
  orderBy: { timestamp: 'desc' },
  take: 100
});
```

### Aggregate Statistics

```typescript
const totalUsage = await prisma.usageStat.count({
  where: { userId: appleUserId }
});
```

## Database Connection

### Configuration

```
DATABASE_URL="postgresql://user:password@host:5432/callivox?schema=public"
```

### Connection Pool (Prisma defaults)

- Connection limit: 10
- Connection timeout: 10s
- Idle timeout: 300s
