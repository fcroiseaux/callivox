import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsObject, IsOptional } from 'class-validator';

/**
 * Location DTO for usage statistics
 */
export class LocationDto {
  @ApiProperty({
    description: 'Latitude coordinate',
    example: 48.856614
  })
  lat: number;

  @ApiProperty({
    description: 'Longitude coordinate',
    example: 2.352222
  })
  lng: number;
}

/**
 * DTO for creating a new usage statistic entry
 * 
 * Note: The userId field is no longer required in the DTO as it will be 
 * automatically populated from the authenticated user's ID.
 */
export class CreateUsageStatDto {
  @ApiProperty({
    description: 'Sentence spoken or recorded by the user',
    example: 'Hello, how are you today?'
  })
  @IsNotEmpty()
  @IsString()
  sentence: string;

  @ApiPropertyOptional({
    description: 'Geographic location',
    type: LocationDto
  })
  @IsOptional()
  @IsObject()
  location?: LocationDto;

  @ApiPropertyOptional({
    description: 'Device information',
    example: 'iPhone 14 Pro, iOS 16.5'
  })
  @IsOptional()
  @IsString()
  deviceInfo?: string;
}