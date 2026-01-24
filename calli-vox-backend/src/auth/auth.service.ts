import { Injectable } from '@nestjs/common';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Formats a date as ISO8601 string for compatibility with Swift's .iso8601 date decoding strategy
 */
export function formatDateForClient(date: Date): string {
  // Format as ISO8601 string
  return date.toISOString();
}

/**
 * User entity model (would typically be a database entity)
 */
export class User {
  @ApiProperty({ description: 'Unique user identifier', example: 'apple-id-123456' })
  id: string;
  
  @ApiProperty({ description: 'User email address', example: 'user@example.com' })
  email: string;
  
  @ApiProperty({ description: 'User display name', example: 'John Doe' })
  name: string;
  
  @ApiProperty({ description: 'Authentication provider', example: 'apple' })
  provider: string;
  
  @ApiProperty({ description: 'User account creation date', example: '2025-02-26T17:00:00.000Z' })
  createdAt: string;
  
  @ApiProperty({ description: 'Last login date', example: '2025-02-26T17:00:00.000Z' })
  lastLoginAt: string;
}

/**
 * Authentication Service
 * 
 * Handles user validation, creation and management for authentication flows.
 */
@Injectable()
export class AuthService {
  /**
   * Validates a user authenticated through Apple Sign In
   * 
   * In a real application, this would:
   * 1. Check if user with this Apple ID exists in database
   * 2. Create a new user if none exists
   * 3. Update existing user information if needed
   * 4. Return user object with relevant data
   * 
   * @param appleId - Unique identifier from Apple
   * @param email - User's email from Apple (may not always be provided)
   * @param name - User's name from Apple (optional)
   * @returns A user object representing the authenticated user
   */
  async validateAppleUser(appleId: string, email: string, name?: string): Promise<User> {
    // In production, implement database lookup and user creation logic
    // This is a simplified example implementation:
    const now = new Date();
    
    // Format the date as ISO-8601 string for client compatibility
    // Using our standardized format function that works well with Swift
    const dateString = formatDateForClient(now);
    
    // Simulating a database lookup/creation
    const user: User = {
      id: appleId,
      email,
      name: name || 'Apple User', // Use provided name or default if none
      provider: 'apple',
      createdAt: dateString,
      lastLoginAt: dateString,
    };
    
    return user;
  }
}