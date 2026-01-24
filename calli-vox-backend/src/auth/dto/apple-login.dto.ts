import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsObject, IsOptional, IsBoolean } from 'class-validator';
import { User } from '../auth.service';

/**
 * Apple user information DTO
 */
export class AppleUserDTO {
  @ApiPropertyOptional({ description: 'User first name' })
  @IsOptional()
  @IsString()
  firstName?: string;

  @ApiPropertyOptional({ description: 'User last name' })
  @IsOptional()
  @IsString()
  lastName?: string;
}

/**
 * Apple login request DTO
 * 
 * Contains data sent from iOS app after "Sign in with Apple" authentication
 */
export class AppleLoginDTO {
  @ApiProperty({ 
    description: 'JWT token received from Apple authentication', 
    example: 'eyJraWQiOiI4NkQ4OEtmIiwiYWxnIjoiUlMyNTYifQ...' 
  })
  @IsNotEmpty()
  @IsString()
  identityToken: string;

  @ApiPropertyOptional({
    description: 'User information object received from Apple',
    type: AppleUserDTO
  })
  @IsOptional()
  @IsObject()
  user?: AppleUserDTO;
}

/**
 * Auth response DTO
 * 
 * Contains authentication response data sent back to the client
 */
export class AuthResponseDTO {
  @ApiProperty({ 
    description: 'Whether authentication was successful',
    example: true
  })
  @IsBoolean()
  success: boolean;

  @ApiProperty({ 
    description: 'JWT token for API authentication',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
    nullable: true
  })
  @IsString()
  token: string;

  @ApiProperty({ 
    description: 'User information',
    type: User,
    nullable: true
  })
  user: User;

  @ApiPropertyOptional({ 
    description: 'Error message in case of failure',
    example: 'Authentication failed'
  })
  @IsOptional()
  @IsString()
  message?: string;

  @ApiPropertyOptional({ 
    description: 'Detailed error information',
    example: 'Token validation failed'
  })
  @IsOptional()
  @IsString()
  error?: string;
}