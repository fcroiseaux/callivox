# Calli-Vox Backend API

<p align="center">
  <img src="./callivox-icon.png" width="100" alt="Calli-Vox Logo" />
</p>

## Description

CalliVox Backend API is a NestJS application that provides authentication and usage tracking services for the CalliVox platform. Built with NestJS, TypeScript, and Prisma ORM, this API allows secure Apple Sign In authentication and collects anonymized usage statistics.

## Features

- **Apple Sign In Authentication**: Secure authentication using Apple ID
- **Usage Statistics**: Anonymized tracking of application usage
- **RESTful API**: Well-structured endpoints following REST principles
- **Swagger Documentation**: Interactive API documentation
- **PostgreSQL Database**: Reliable data storage with Prisma ORM

## Tech Stack

- [NestJS](https://nestjs.com/) - A progressive Node.js framework
- [Prisma](https://www.prisma.io/) - Next-generation ORM for Node.js and TypeScript
- [PostgreSQL](https://www.postgresql.org/) - Advanced open source database
- [Passport.js](http://www.passportjs.org/) - Authentication middleware for Node.js
- [JWT](https://jwt.io/) - JSON Web Tokens for secure authentication
- [Swagger](https://swagger.io/) - API documentation

## Prerequisites

- Node.js >= 16.x
- PostgreSQL >= 12.x
- Apple Developer Account (for Sign in with Apple)

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url>
cd calli-vox-backend
```

## Installation

```bash
# Install dependencies
$ npm install

# Generate Prisma client
$ npx prisma generate
```

## Configuration

1. Copy `.env.example` to `.env` and update the following variables:

```
# Database connection
DATABASE_URL="postgresql://username:password@localhost:5432/callivox"

# Apple Sign In credentials
APPLE_CLIENT_ID=com.your.app.id
APPLE_TEAM_ID=YOUR_APPLE_TEAM_ID
APPLE_KEY_ID=YOUR_APPLE_KEY_ID
APPLE_PRIVATE_KEY_LOCATION=./apple_private_key.p8
APPLE_CALLBACK_URL=http://localhost:8080/auth/apple/callback

# JWT configuration
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRATION=30d

# Server configuration
PORT=8080                     # Port on which the server runs (default: 8080)
```

2. Set up Apple Sign In in your Apple Developer Account:
   - Register an App ID with Sign in with Apple capability
   - Create a Services ID for web authentication
   - Configure the domains and return URLs
   - Create a private key for Sign in with Apple
   - Download the private key as a .p8 file and place it at the path specified in APPLE_PRIVATE_KEY_LOCATION

## Database Setup

### Development

```bash
# Create and apply migrations
$ npx prisma migrate dev
```

### Production

```bash
# Apply existing migrations
$ npx prisma migrate deploy
```

### Seeding

```bash
# Seed the database (if applicable)
$ npx prisma db seed
```

## Running the App

```bash
# Development mode
$ npm run start:dev

# Production mode
$ npm run build
$ npm run start:prod
```

## API Documentation

Once the application is running, you can access the Swagger API documentation at:
http://localhost:8080/api

## API Endpoints

### Authentication
- `POST /auth/apple/mobile` - Authenticate with Apple identity token
- `GET /auth/profile` - Get authenticated user profile

### Statistics
- `POST /stats` - Save usage statistics
- `GET /stats` - Get usage statistics (admin only)

## Testing

```bash
# Unit tests
$ npm run test

# E2E tests
$ npm run test:e2e

# Test coverage
$ npm run test:cov
```

## License

This project is private and unlicensed.