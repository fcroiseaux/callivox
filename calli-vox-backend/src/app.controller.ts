import { Controller, Get, Res } from '@nestjs/common';
import { Response } from 'express';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @Get()
  getHomePage(@Res() res: Response): void {
    const htmlContent = this.appService.getLatestChanges();
    res.type('text/html').send(htmlContent);
  }
}
