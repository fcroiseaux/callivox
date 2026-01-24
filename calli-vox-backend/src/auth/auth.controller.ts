import { Controller, Get, Post, UseGuards, Req, Res, Body, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { AuthService } from './auth.service';
import { AppleLoginDTO, AuthResponseDTO } from './dto/apple-login.dto';
import { ApiTags, ApiOperation, ApiResponse, ApiBody, ApiBearerAuth } from '@nestjs/swagger';
import { JwtService } from '@nestjs/jwt';

/**
 * Authentication Controller
 * 
 * Handles authentication-related endpoints for Apple Sign In
 * with both web callback and direct token verification routes.
 */
@ApiTags('auth')
@Controller('auth')
export class AuthController {
  private readonly logger = new Logger(AuthController.name);

  constructor(
    private authService: AuthService,
    private jwtService: JwtService
  ) {}

  /**
   * Apple Sign In callback endpoint
   * 
   * This endpoint handles redirects from Apple's authentication service
   * after a user has successfully authenticated through a web flow.
   * Most iOS apps will use the direct token verification instead.
   * 
   * @param req - The HTTP request (contains user from passport strategy)
   * @param res - The HTTP response for redirecting
   * @returns Redirects to the app with an auth token
   */
  @ApiOperation({ 
    summary: 'Apple Sign In callback', 
    description: 'Handles web authentication flow redirects from Apple' 
  })
  @ApiResponse({ 
    status: 302, 
    description: 'Redirects to app with authentication token'
  })
  @Get('apple/callback')
  @UseGuards(AuthGuard('apple'))
  async appleCallback(@Req() req, @Res() res) {
    try {
      // Check if Apple authentication is configured
      const clientID = process.env.APPLE_CLIENT_ID;
      const teamID = process.env.APPLE_TEAM_ID;
      const keyID = process.env.APPLE_KEY_ID;
      const privateKey = process.env.APPLE_PRIVATE_KEY;
      
      if (!clientID || !teamID || !keyID || !privateKey) {
        return res.status(503).json({
          success: false,
          message: 'Apple authentication is not configured on this server'
        });
      }
      
      // User information is available in req.user after successful authentication
      const user = req.user;
      
      // Generate a JWT token for the authenticated user
      const token = this.generateJwtToken(user);
      
      // For mobile apps, redirect to a custom URL scheme that opens your app
      // For example: yourappscheme://auth?token=yourtoken
      return res.redirect(`yourappscheme://auth?token=${token}`);
    } catch (error) {
      return res.status(500).json({
        success: false,
        message: 'Authentication failed',
        error: error.message
      });
    }
  }
  
  /**
   * Direct Apple token verification endpoint for mobile apps
   * 
   * This is the main endpoint for iOS native "Sign in with Apple" integration.
   * The iOS app sends the identity token it receives from Apple directly to this endpoint.
   * 
   * @param payload - Contains the identity token and user info from Apple
   * @returns Authentication response with user info and app token
   */
  @ApiOperation({ 
    summary: 'Verify Apple identity token', 
    description: 'Directly verifies Apple identity token from iOS app and authenticates user'
  })
  @ApiBody({ type: AppleLoginDTO })
  @ApiResponse({ 
    status: 200, 
    description: 'Authentication successful',
    type: AuthResponseDTO
  })
  @ApiResponse({ 
    status: 400, 
    description: 'Invalid request or missing identity token',
    type: AuthResponseDTO
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Authentication failed',
    type: AuthResponseDTO
  })
  @Post('apple/mobile')
  async appleLoginMobile(@Body() payload: AppleLoginDTO): Promise<AuthResponseDTO> {
    this.logger.log(`🔐 Apple mobile auth attempt received`);
    
    // Check if Apple authentication is configured
    const clientID = process.env.APPLE_CLIENT_ID;
    const teamID = process.env.APPLE_TEAM_ID;
    const keyID = process.env.APPLE_KEY_ID;
    const privateKey = process.env.APPLE_PRIVATE_KEY;
    
    if (!clientID || !teamID || !keyID || !privateKey) {
      this.logger.error(`❌ Apple authentication config missing`);
      return { 
        success: false, 
        message: 'Apple authentication is not configured on this server',
        token: null,
        user: null
      };
    }
    
    // Payload from iOS app contains the identity token and user info
    const { identityToken, user } = payload;
    
    this.logger.log(`📱 Apple auth request with user info: ${user ? JSON.stringify({
      firstName: user.firstName,
      lastName: user.lastName
    }) : 'No user info provided'}`);
    
    // First validate that a token was provided
    if (!identityToken) {
      this.logger.error(`❌ No identity token provided in request`);
      return { 
        success: false, 
        message: 'No identity token provided',
        token: null,
        user: null
      };
    }
    
    // In a production implementation, you would:
    // 1. Verify the JWT token (identityToken) using Apple's public keys
    //    - Fetch Apple's public keys from https://appleid.apple.com/auth/keys
    //    - Validate the token signature, issuer, audience, and expiration
    // 2. Extract the user information from the verified token
    // 3. Find or create the user in your database
    // 4. Generate your own session token/JWT for your app
    
    try {
      this.logger.log(`🔍 Validating Apple identity token (in development mode using mock data)`);
      
      // In production, these values would come from verifying the identityToken
      // This is placeholder logic - implement actual JWT verification in production!
      const appleId = 'example-apple-id'; // Extract from verified token
      const email = 'example@email.com'; // Extract from verified token
      const name = user ? `${user.firstName || ''} ${user.lastName || ''}`.trim() : undefined;
      
      this.logger.log(`👤 Processing user with Apple ID: ${appleId.substring(0, 8)}***, Email: ${email.substring(0, 3)}***`);
      
      // Validate or create the user in your system
      const validatedUser = await this.authService.validateAppleUser(
        appleId, 
        email, 
        name || undefined
      );
      
      // Generate JWT token for the validated user
      const token = this.generateJwtToken(validatedUser);
      
      this.logger.log(`✅ Apple authentication successful for user: ${validatedUser.name}`);
      
      // Return authentication response
      return {
        success: true,
        token: token,
        user: validatedUser
      };
    } catch (error) {
      // Handle authentication errors
      this.logger.error(`❌ Apple authentication failed: ${error.message}`);
      return {
        success: false,
        message: 'Authentication failed',
        error: error.message,
        token: null,
        user: null
      };
    }
  }
  
  /**
   * Generate a JWT token for the authenticated user
   * 
   * @param user - The authenticated user
   * @returns JWT token string
   */
  private generateJwtToken(user: any): string {
    const payload = {
      sub: user.id,
      email: user.email,
      name: user.name
    };
    
    // In a real application, you would use JwtService from @nestjs/jwt
    // and proper configuration for expiration, etc.
    return this.jwtService.sign(payload);
  }
}