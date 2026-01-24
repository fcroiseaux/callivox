import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUsageStatDto } from './dto/create-usage-stat.dto';

/**
 * Stats Service
 * 
 * Handles logging and retrieval of usage statistics
 * with user pseudonymization.
 */
@Injectable()
export class StatsService {
  constructor(private prisma: PrismaService) {}

  /**
   * Log a new usage statistic
   * 
   * This method:
   * 1. Pseudonymizes the user ID
   * 2. Creates a user profile if it doesn't exist
   * 3. Creates a new usage statistic entry
   * 
   * @param createUsageStatDto - The usage statistic data
   * @returns The created usage statistic entry
   */
  async logUsage(createUsageStatDto: CreateUsageStatDto & { userId: string }) {
    const { userId, sentence, location, deviceInfo } = createUsageStatDto;
    
    console.log('StatsService.logUsage called with:', JSON.stringify({
      userId,
      sentence,
      location,
      deviceInfo
    }, null, 2));
    
    // Create pseudonymized user ID
    const pseudoId = this.prisma.createPseudoId(userId);
    console.log(`Pseudonymized ID created: ${pseudoId} for user: ${userId}`);
    
    try {
      // Create user profile if it doesn't exist (using upsert)
      const userProfile = await this.prisma.userProfile.upsert({
        where: { id: pseudoId },
        update: {}, // No updates needed if it exists
        create: { id: pseudoId }
      });
      
      console.log('User profile created/updated:', JSON.stringify(userProfile));
      
      // Create the usage statistic
      const result = await this.prisma.usageStat.create({
        data: {
          userId: pseudoId,
          sentence,
          location: location ? JSON.parse(JSON.stringify(location)) : null,
          deviceInfo,
        }
      });
      
      console.log('Usage stat created:', JSON.stringify(result));
      return result;
    } catch (error) {
      console.error('Error in StatsService.logUsage:', error);
      throw error;
    }
  }

  /**
   * Get usage statistics for a specific user
   * 
   * @param userId - Original user ID (will be pseudonymized)
   * @returns List of usage statistics for the user
   */
  async getUserStats(userId: string) {
    const pseudoId = this.prisma.createPseudoId(userId);
    
    return this.prisma.usageStat.findMany({
      where: { userId: pseudoId },
      orderBy: { timestamp: 'desc' }
    });
  }

  /**
   * Get all usage statistics (for analytics)
   * 
   * @param limit - Maximum number of records to return
   * @returns List of all usage statistics
   */
  async getAllStats(limit = 100) {
    return this.prisma.usageStat.findMany({
      take: limit,
      orderBy: { timestamp: 'desc' },
      include: { user: true }
    });
  }
}