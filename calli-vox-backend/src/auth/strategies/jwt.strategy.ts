import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from 'src/prisma/prisma.service';

/**
 * JWT Strategy for API authentication
 * 
 * This strategy extracts and validates JWT tokens from requests
 * to protect API endpoints.
 */
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private configService: ConfigService,
    private prismaService: PrismaService
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET') || 'your-secret-key',
    });
  }

  /**
   * Validate the JWT payload and return the user
   * 
   * This method is called after the token is verified. It takes the decoded
   * JWT payload and should return the user object to be added to the request.
   * 
   * @param payload - Decoded JWT payload
   * @returns User object
   */
  async validate(payload: any) {
    // In a real application, you would:
    // 1. Look up the user in the database using the payload.sub (user ID)
    // 2. Return the user object to be added to the request (req.user)
    
    // For now, we'll just return the payload as the user
    // In a production app, you should do a proper database lookup
    return {
      id: payload.sub,
      email: payload.email,
      name: payload.name
    };
  }
}