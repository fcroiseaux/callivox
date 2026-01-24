import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * Prisma Service
 * 
 * Provides database access through Prisma ORM.
 * Handles connection lifecycle and exposes the Prisma client.
 */
@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  
  /**
   * Connect to the database when the module initializes
   */
  async onModuleInit() {
    try {
      console.log('Attempting to connect to database with URL:', this.getDatabaseUrlSafe());
      await this.$connect();
      console.log('✅ Successfully connected to the database');
    } catch (error) {
      this.logger.warn('❌ Could not connect to the database. Error:', error.message);
      this.logger.warn('⚠️ DATABASE CONNECTION FAILED: Running in mock mode');
      this.setupMockMethods();
    }
  }
  
  /**
   * Returns a safe version of the database URL for logging (hides password)
   */
  private getDatabaseUrlSafe(): string {
    const dbUrl = process.env.DATABASE_URL || 'No DATABASE_URL defined';
    // If it contains a password, mask it for security
    if (dbUrl.includes('@')) {
      try {
        const url = new URL(dbUrl);
        return dbUrl.replace(`${url.password}`, '********');
      } catch {
        return 'Invalid database URL format';
      }
    }
    return dbUrl;
  }

  /**
   * Disconnect from the database when the module is destroyed
   */
  async onModuleDestroy() {
    try {
      await this.$disconnect();
    } catch (error) {
      this.logger.warn('Error disconnecting from database');
    }
  }

  /**
   * Create a hash of user's ID for pseudonymization
   * 
   * This method creates a consistent hash that can be used to identify a user
   * without storing any personally identifiable information.
   * 
   * @param userId - Original user ID (like Apple ID)
   * @returns Hashed identifier string
   */
  createPseudoId(userId: string): string {
    // Simple hash function - in production, use a more secure hashing algorithm
    // You might want to add a secret salt that's stored securely
    const crypto = require('crypto');
    return crypto
      .createHash('sha256')
      .update(userId + process.env.PSEUDO_ID_SALT || 'callivox-salt')
      .digest('hex');
  }
  
  /**
   * Setup mock methods for development/testing
   * 
   * This allows the server to run without a database connection
   */
  private setupMockMethods() {
    // Use Prisma's $use method to intercept queries
    this.$use(async (params, next) => {
      // Log every operation in mock mode
      this.logger.warn(`MOCK MODE: ${params.model}.${params.action} operation intercepted`);
      
      // Log data for create operations
      if (params.action === 'create' && params.args?.data) {
        this.logger.warn(`MOCK MODE: Attempted to create with data: ${JSON.stringify(params.args.data)}`);
      }
      
      // Handle UserProfile operations
      if (params.model === 'UserProfile') {
        if (params.action === 'upsert' || params.action === 'findUnique') {
          this.logger.warn(`MOCK MODE: Returning mock UserProfile`);
          return { id: 'mock-user-id', createdAt: new Date(), updatedAt: new Date() };
        }
        if (params.action === 'findMany') {
          this.logger.warn(`MOCK MODE: Returning mock UserProfile list`);
          return [{ id: 'mock-user-id', createdAt: new Date(), updatedAt: new Date() }];
        }
      }
      
      // Handle UsageStat operations
      if (params.model === 'UsageStat') {
        if (params.action === 'create') {
          const data = params.args.data;
          this.logger.warn(`MOCK MODE: Creating mock UsageStat for sentence: "${data.sentence}"`);
          return { 
            id: 'mock-stat-id', 
            userId: 'mock-user-id',
            sentence: data.sentence || 'Mock sentence',
            location: data.location,
            timestamp: new Date(),
            deviceInfo: data.deviceInfo || 'Mock device'
          };
        }
        if (params.action === 'findMany') {
          this.logger.warn(`MOCK MODE: Returning mock UsageStat list`);
          return [{
            id: 'mock-stat-id',
            userId: 'mock-user-id',
            sentence: 'Mock sentence',
            location: { lat: 48.856614, lng: 2.352222 },
            timestamp: new Date(),
            deviceInfo: 'Mock device'
          }];
        }
      }
      
      // For any other operations, return mock data
      this.logger.warn(`MOCK MODE: Passing through operation to default handler`);
      return next(params);
    });
    
    this.logger.warn('⚠️ DATABASE MOCK MODE ACTIVE: No real database connection available. All data operations are being mocked.');
  }
}