import { Controller, Get, Query, Res, Req } from '@nestjs/common';
import { GoogleAuthService } from './google-auth.service';
import { Response } from 'express';

@Controller('api/mail/auth')
export class GoogleAuthController {
  constructor(private readonly googleAuthService: GoogleAuthService) {}

  @Get('google')
  async initiateGoogleAuth(@Query('userId') userId: string, @Res() res: Response) {
    if (!userId) {
      // In a real app, userId should come from JWT token
      userId = 'temp-user-id'; 
    }
    const url = this.googleAuthService.getAuthUrl(userId);
    res.redirect(url);
  }

  @Get('google/callback')
  async googleAuthCallback(@Query('code') code: string, @Query('state') state: string, @Res() res: Response) {
    if (!code) {
      return res.status(400).send('No code provided');
    }

    try {
      const result = await this.googleAuthService.handleCallback(code, state);
      // Redirect back to frontend Accounts page with success status
      res.redirect(`http://localhost:3000/accounts?sync=success&email=${result.email}`);
    } catch (error) {
      res.redirect(`http://localhost:3000/accounts?sync=error`);
    }
  }
}
