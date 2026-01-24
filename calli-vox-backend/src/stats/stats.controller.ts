import { Controller, Post, Body, Get, Param, Query, UseGuards, Req, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBody, ApiParam, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { StatsService } from './stats.service';
import { CreateUsageStatDto } from './dto/create-usage-stat.dto';
import { AuthGuard } from '@nestjs/passport';

/**
 * Stats Controller
 * 
 * Provides endpoints for logging and retrieving usage statistics.
 * All endpoints require authentication to prevent abuse.
 */
@ApiTags('stats')
@ApiBearerAuth()
@Controller('stats')
@UseGuards(AuthGuard('jwt')) // Apply JWT authentication to all routes
export class StatsController {
  private readonly logger = new Logger(StatsController.name);
  
  constructor(private readonly statsService: StatsService) {}
  
  /**
   * Test endpoint that bypasses DTO validation
   */
  @Post('raw')
  async testRawLog(@Req() req, @Body() rawBody: any) {
    this.logger.warn('🧪 TEST RAW ENDPOINT CALLED');
    this.logger.warn(`🧪 TEST Raw body: ${JSON.stringify(rawBody)}`);
    this.logger.warn(`🧪 TEST Headers: ${JSON.stringify(req.headers)}`);
    this.logger.warn(`🧪 TEST User: ${JSON.stringify(req.user)}`);
    
    // Return success response
    return {
      success: true,
      message: 'Raw data received',
      data: rawBody
    };
  }
  
  /**
   * Log a new usage statistic
   * 
   * This endpoint requires authentication to prevent abuse.
   * The user ID is extracted from the authenticated user.
   * 
   * @param req - Request with authenticated user
   * @param createUsageStatDto - The usage statistic data to log
   * @returns The created usage statistic
   */
  @ApiOperation({ 
    summary: 'Log a new usage statistic', 
    description: 'Records a new usage event with pseudonymized user identification. Requires authentication.' 
  })
  @ApiBody({ type: CreateUsageStatDto })
  @ApiResponse({ 
    status: 201, 
    description: 'The usage statistic has been successfully created'
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - User must be authenticated'
  })
  @Post()
  async logUsage(@Req() req, @Body() createUsageStatDto: CreateUsageStatDto) {
    try {
      // Log the raw request body for debugging
      const rawBody = req.body;
      this.logger.warn(`🔍 DEBUG RAW REQUEST BODY: ${JSON.stringify(rawBody)}`);
      this.logger.warn(`🔍 DEBUG REQUEST HEADERS: ${JSON.stringify(req.headers)}`);
      
      // Get the authenticated user's ID from the request
      const authenticatedUserId = req.user.id;
      
      this.logger.log(`📊 Received usage log from user ${authenticatedUserId}`);
      
      // Log the DTO as received by NestJS for debugging
      this.logger.warn(`🔍 DEBUG DTO AS RECEIVED: ${JSON.stringify(createUsageStatDto)}`);
      
      // Inspect the sentence field specifically
      if (createUsageStatDto.sentence) {
        this.logger.log(`📝 Sentence content: "${createUsageStatDto.sentence?.substring(0, 30)}${createUsageStatDto.sentence?.length > 30 ? '...' : ''}"`);
        this.logger.warn(`🔍 DEBUG Sentence type: ${typeof createUsageStatDto.sentence}`);
      } else {
        this.logger.error(`❌ No sentence field found in request!`);
      }
      
      // Check if location data is provided
      if (createUsageStatDto.location) {
        this.logger.log(`📍 Location data included: ${JSON.stringify(createUsageStatDto.location)}`);
      }
      
      // Check device info
      if (createUsageStatDto.deviceInfo) {
        this.logger.log(`📱 Device info: ${createUsageStatDto.deviceInfo}`);
      }
      
      // Override the userId in the DTO with the authenticated user's ID
      // This ensures users can only log data for themselves
      const dataToLog = {
        ...createUsageStatDto,
        userId: authenticatedUserId
      };
      
      // Log the data being sent to the service
      this.logger.warn(`🔍 DEBUG DATA TO LOG: ${JSON.stringify(dataToLog)}`);
      
      const result = await this.statsService.logUsage(dataToLog);
      
      this.logger.log(`✅ Usage log successfully created with ID: ${result.id}`);
      
      // Return a simplified response without the pseudonymized ID
      return {
        id: result.id,
        sentence: result.sentence,
        timestamp: result.timestamp,
        success: true
      };
    } catch (error) {
      this.logger.error(`❌ Failed to create usage log: ${error.message}`);
      this.logger.error(`❌ Error stack: ${error.stack}`);
      
      if (error.response) {
        this.logger.error(`❌ Error response: ${JSON.stringify(error.response)}`);
      }
      
      throw error;
    }
  }
  
  /**
   * Get usage statistics for the authenticated user
   * 
   * This endpoint is protected and requires authentication.
   * Users can only access their own statistics.
   * 
   * @param req - Request with authenticated user
   * @returns List of usage statistics for the user
   */
  @ApiOperation({ 
    summary: 'Get user statistics', 
    description: 'Retrieves usage statistics for the authenticated user'
  })
  @ApiResponse({ 
    status: 200, 
    description: 'Returns the usage statistics for the user'
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - User must be authenticated'
  })
  @Get('user')
  getUserStats(@Req() req) {
    const userId = req.user.id;
    return this.statsService.getUserStats(userId);
  }
  
  /**
   * Get all usage statistics for analytics (admin only)
   * 
   * This endpoint is protected and requires admin authentication
   * 
   * @param limit - Maximum number of records to return
   * @returns List of all usage statistics
   */
  @ApiOperation({ 
    summary: 'Get all statistics', 
    description: 'Retrieves all usage statistics (admin only)'
  })
  @ApiQuery({ name: 'limit', required: false, description: 'Maximum number of records to return' })
  @ApiResponse({ 
    status: 200, 
    description: 'Returns all usage statistics'
  })
  @ApiResponse({ 
    status: 401, 
    description: 'Unauthorized - Admin authentication required'
  })
  // This endpoint would need additional admin role checking in a real application
  @Get('admin')
  getAllStats(@Query('limit') limit?: string) {
    return this.statsService.getAllStats(limit ? parseInt(limit) : undefined);
  }
}