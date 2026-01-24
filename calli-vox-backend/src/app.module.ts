import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { StatsModule } from './stats/stats.module';

/**
 * Root Application Module
 * 
 * Configures the application and connects all modules together.
 */
@Module({
  imports: [
    // Load environment variables from .env file
    ConfigModule.forRoot(),
    // Database access through Prisma ORM
    PrismaModule,
    // Include the authentication module with Apple Sign In
    AuthModule,
    // Usage statistics tracking module
    StatsModule
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
