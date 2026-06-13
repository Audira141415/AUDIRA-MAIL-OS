import { Injectable, Logger } from '@nestjs/common';
import { google } from 'googleapis';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class GoogleAuthService {
  private readonly logger = new Logger(GoogleAuthService.name);
  private oauth2Client: any;

  constructor(private prisma: PrismaService) {
    this.oauth2Client = new google.auth.OAuth2(
      process.env.GOOGLE_CLIENT_ID || 'dummy-client-id',
      process.env.GOOGLE_CLIENT_SECRET || 'dummy-client-secret',
      'http://localhost:3001/api/mail/auth/google/callback',
    );
  }

  getAuthUrl(userId: string) {
    const scopes = [
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
      'https://mail.google.com/',
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      prompt: 'consent',
      scope: scopes,
      state: userId, // Pass userId in state to associate account later
    });
  }

  async handleCallback(code: string, userId: string) {
    try {
      const { tokens } = await this.oauth2Client.getToken(code);
      this.oauth2Client.setCredentials(tokens);

      const oauth2 = google.oauth2({
        auth: this.oauth2Client,
        version: 'v2',
      });

      const userInfo = await oauth2.userinfo.get();
      const email = userInfo.data.email;

      if (!email) {
        throw new Error('Email not found from Google Profile');
      }

      // Upsert Gmail Account
      const gmailAccount = await this.prisma.gmailAccount.upsert({
        where: { emailAddress: email },
        update: {
          status: 'connected',
          lastSync: new Date(),
        },
        create: {
          userId: userId, // User who initiated the connection
          emailAddress: email,
          accountName: userInfo.data.name || email.split('@')[0],
          status: 'connected',
          storageUsage: 0,
        },
      });

      // Upsert OAuth Tokens
      if (tokens.access_token && tokens.refresh_token) {
        await this.prisma.oauthToken.upsert({
          where: { accountId: gmailAccount.id },
          update: {
            accessToken: tokens.access_token,
            refreshToken: tokens.refresh_token,
            expiresAt: new Date(tokens.expiry_date || Date.now() + 3600000),
            scope: tokens.scope || '',
          },
          create: {
            accountId: gmailAccount.id,
            accessToken: tokens.access_token,
            refreshToken: tokens.refresh_token,
            expiresAt: new Date(tokens.expiry_date || Date.now() + 3600000),
            scope: tokens.scope || '',
          },
        });
      }
      
      return { success: true, email };
    } catch (error) {
      this.logger.error(`Error handling Google OAuth callback: ${error}`);
      throw error;
    }
  }
}
