# CalliVox API Contracts

**Part:** Backend
**Base URL:** `https://api.callivox.app`
**API Documentation:** `/api` (Swagger UI)
**Generated:** 2026-01-25

## Authentication

All protected endpoints require a Bearer token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Endpoints

---

### Authentication

#### GET /auth/apple

**Description:** Initiate Apple Sign In OAuth flow (web)

**Authentication:** None

**Response:** Redirects to Apple Sign In page

---

#### GET /auth/apple/callback

**Description:** OAuth callback handler for web authentication

**Authentication:** None

**Query Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `code` | string | Authorization code from Apple |
| `state` | string | CSRF state token |

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "001234.abcdef1234567890.1234",
    "email": "user@privaterelay.appleid.com"
  }
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 401 | Invalid authorization code |
| 500 | Apple verification failed |

---

#### POST /auth/apple/mobile

**Description:** Exchange Apple identity token for JWT (mobile app)

**Authentication:** None

**Request Body:**

```json
{
  "identityToken": "eyJraWQiOiJXNldjT0tCIiwiYWxnIjoiUlMyNTYifQ...",
  "authorizationCode": "c1234567890abcdef...",
  "email": "user@example.com",
  "fullName": {
    "givenName": "John",
    "familyName": "Doe"
  }
}
```

**Response:**

```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "001234.abcdef1234567890.1234",
    "email": "user@privaterelay.appleid.com"
  }
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 400 | Missing required fields |
| 401 | Invalid identity token |
| 500 | Token verification failed |

---

### Statistics

#### POST /stats

**Description:** Log a usage event

**Authentication:** Required (JWT)

**Request Body:**

```json
{
  "sentence": "Hello, how are you?",
  "location": {
    "latitude": 48.8566,
    "longitude": 2.3522
  },
  "deviceInfo": "iPhone 15 Pro, iOS 17.2"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `sentence` | string | Yes | The spoken sentence |
| `location` | object | No | User location (optional) |
| `location.latitude` | number | No | Latitude coordinate |
| `location.longitude` | number | No | Longitude coordinate |
| `deviceInfo` | string | No | Device information |

**Response:**

```json
{
  "success": true,
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 400 | Missing sentence field |
| 401 | Unauthorized (invalid/expired token) |
| 500 | Database error |

**Note:** User ID is pseudonymized (SHA256 hashed) before storage for privacy.

---

#### GET /stats/user

**Description:** Get statistics for the authenticated user

**Authentication:** Required (JWT)

**Response:**

```json
{
  "totalUsage": 42,
  "stats": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "sentence": "Hello, how are you?",
      "timestamp": "2026-01-25T10:30:00Z",
      "deviceInfo": "iPhone 15 Pro, iOS 17.2"
    }
  ]
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 500 | Database error |

---

#### GET /stats/admin

**Description:** Get all statistics (admin only)

**Authentication:** Required (JWT with admin privileges)

**Response:**

```json
{
  "totalUsers": 150,
  "totalUsage": 4200,
  "stats": [
    {
      "userId": "a3f5b2c1d4e6...",  // Pseudonymized
      "sentence": "Hello, how are you?",
      "timestamp": "2026-01-25T10:30:00Z",
      "location": {
        "latitude": 48.8566,
        "longitude": 2.3522
      }
    }
  ]
}
```

**Errors:**

| Code | Description |
|------|-------------|
| 401 | Unauthorized |
| 403 | Forbidden (not admin) |
| 500 | Database error |

---

## Data Types

### JWT Token Structure

```json
{
  "userId": "001234.abcdef1234567890.1234",
  "email": "user@privaterelay.appleid.com",
  "iat": 1706173800,
  "exp": 1708765800
}
```

- **Expiration:** 30 days from issuance
- **Algorithm:** HS256

### Error Response Format

```json
{
  "statusCode": 401,
  "message": "Unauthorized",
  "error": "Invalid token"
}
```

## Rate Limiting

Currently no rate limiting implemented. Consider adding for production:

- `/auth/*`: 10 requests/minute per IP
- `/stats`: 60 requests/minute per user

## CORS Configuration

CORS is enabled for all origins to support mobile app access:

```typescript
app.enableCors();
```

For production, restrict to specific origins:

```typescript
app.enableCors({
  origin: ['https://callivox.app', 'callivox://'],
  credentials: true
});
```
