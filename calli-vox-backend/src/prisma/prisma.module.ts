import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

/**
 * Prisma Module - Provides database access throughout the application
 * 
 * This is marked as @Global() so the PrismaService is available everywhere
 * without needing to import the module in each feature module.
 */
@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}