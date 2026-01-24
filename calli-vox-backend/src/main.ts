import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

/**
 * Application Bootstrap Function
 * 
 * Creates and configures the NestJS application instance.
 */
async function bootstrap() {
  // Create a new NestJS application
  const app = await NestFactory.create(AppModule);
  const logger = new Logger('HTTP');
  
  // Add middleware to log all requests
  app.use((req: Request, res: Response, next: NextFunction) => {
    const { method, originalUrl, ip, headers } = req;
    const userAgent = headers['user-agent'] || 'unknown';
    
    logger.log(`📥 ${method} ${originalUrl} - ${ip} - ${userAgent}`);
    
    // Capture response status after request is complete
    res.on('finish', () => {
      const { statusCode } = res;
      const contentLength = res.getHeader('content-length');
      logger.log(`📤 ${method} ${originalUrl} - ${statusCode} - ${contentLength || 0}b`);
    });
    
    next();
  });
  
  // Enable CORS for frontend communication
  app.enableCors();
  
  // Enable validation pipes for DTOs
  app.useGlobalPipes(new ValidationPipe({
    transform: true, // Automatically transform payloads to DTO instances
    whitelist: true, // Strip properties that are not in the DTO
    forbidNonWhitelisted: true, // Throw errors if non-whitelisted properties are present
  }));
  
  // Set up Swagger documentation
  const config = new DocumentBuilder()
    .setTitle('Calli-Vox API')
    .setDescription('API for Calli-Vox authentication and services')
    .setVersion('1.0')
    .addTag('auth', 'Authentication endpoints')
    .addBearerAuth()
    .build();
  
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api', app, document);
  
  // Start the application on port 3000
  await app.listen(8080);
  
  console.log(`Application is running on: http://localhost:8080`);
  console.log(`API documentation available at: http://localhost:8080/api`);
}

// Start the application
bootstrap();
