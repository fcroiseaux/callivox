import { Module } from '@nestjs/common';
import { PassportModule } from '@nestjs/passport';
import { JwtModule } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import { AppleStrategy } from './strategies/apple.strategy';
import { JwtStrategy } from './strategies/jwt.strategy';
import { AuthController } from './auth.controller';
import { ConfigModule, ConfigService } from '@nestjs/config';

/**
 * Auth Module
 * 
 * Central module for authentication functionality including:
 * - Apple Sign In authentication strategy
 * - JWT authentication strategy for API access
 * - Auth service for user validation
 * - Auth controller for handling authentication endpoints
 */
@Module({
  imports: [
    // Make ConfigModule available within this module
    ConfigModule,
    
    // Import PassportJS for authentication strategies
    PassportModule.register({ defaultStrategy: 'jwt' }),
    
    // Configure JWT module for token generation and validation
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET') || 'your-secret-key',
        signOptions: {
          expiresIn: '30d', // Token expires in 30 days
        },
      }),
    }),
  ],
  providers: [
    AuthService,
    AppleStrategy,
    JwtStrategy,
    ConfigService, // Provide ConfigService
  ],
  controllers: [AuthController],
  exports: [AuthService, JwtModule], // Export service and JWT module
})
export class AuthModule {}