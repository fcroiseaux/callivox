import { Injectable, Logger } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-apple';
import { AuthService } from '../auth.service';

/**
 * Apple Sign In Strategy
 * 
 * Implements the Passport strategy for authenticating with Apple Sign In
 * using OAuth 2.0 and JWT verification.
 */
@Injectable()
export class AppleStrategy extends PassportStrategy(Strategy, 'apple') {
  private readonly logger = new Logger(AppleStrategy.name);
  private readonly authService: AuthService;
  
  /**
   * Constructor - configures the Apple authentication strategy
   * 
   * @param authService - Service for user validation and management
   */
  constructor(authService: AuthService) {
    // Check if Apple credentials are available
    const clientID = process.env.APPLE_CLIENT_ID;
    const teamID = process.env.APPLE_TEAM_ID;
    const keyID = process.env.APPLE_KEY_ID;
    const privateKey = process.env.APPLE_PRIVATE_KEY;
    
    // Determine configuration based on available credentials
    const config = !clientID || !teamID || !keyID || !privateKey 
      ? {
          clientID: 'dummy-client-id',
          teamID: 'dummy-team-id',
          keyID: 'dummy-key-id',
          privateKeyLocation: 'dummy-path', // For backward compatibility
          callbackURL: 'https://api.callivox.app/auth/apple/callback',
          passReqToCallback: true,
        }
      : {
          clientID,
          teamID,
          keyID,
          // Use privateKey directly instead of reading from a file
          privateKey: privateKey.replace(/\\n/g, '\n'),
          callbackURL: process.env.APPLE_CALLBACK_URL || 'https://api.callivox.app/auth/apple/callback',
          passReqToCallback: true,
        };
    
    // Initialize the parent with the determined configuration
    super(config);
    
    // Store service reference after super() call
    this.authService = authService;
    
    // Log warning if credentials are missing
    if (!clientID || !teamID || !keyID || !privateKey) {
      this.logger.warn('Apple authentication credentials missing. Apple authentication will not work.');
    }
  }

  /**
   * Validates the Apple authentication and creates/retrieves a user
   * 
   * This method is called by Passport after successful Apple authentication.
   * It extracts user information from Apple's response and validates the user.
   * 
   * @param request - The HTTP request
   * @param accessToken - OAuth 2.0 access token
   * @param refreshToken - OAuth 2.0 refresh token
   * @param idToken - Decoded JWT ID token containing user info
   * @param profile - User profile information from Apple
   * @param done - Passport callback to return authenticated user
   */
  async validate(
    request: any,
    accessToken: string,
    refreshToken: string,
    idToken: any,
    profile: any,
    done: Function,
  ) {
    try {
      // Check if this is a dummy configuration
      if (!process.env.APPLE_CLIENT_ID) {
        this.logger.warn('Apple authentication attempted but credentials are not configured');
        return done(new Error('Apple authentication not configured'), false);
      }
      
      // Extract user information from Apple's response
      const { id } = profile;
      
      // Email may be in different places depending on response format
      const email = idToken?.email || (profile._json?.email);
      
      // Format full name from first and last name if available
      const name = profile.name?.firstName 
        ? `${profile.name.firstName} ${profile.name.lastName || ''}`
        : undefined;

      // Validate or create the user in our system
      const user = await this.authService.validateAppleUser(id, email, name);
      
      // Return the user to Passport
      done(null, user);
    } catch (error) {
      // Handle authentication errors
      this.logger.error(`Apple authentication error: ${error.message}`, error.stack);
      done(error, false);
    }
  }
}