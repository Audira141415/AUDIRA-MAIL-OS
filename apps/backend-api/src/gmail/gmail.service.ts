import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { FirebaseService } from '../firebase/firebase.service';
import { AutomationService } from '../automations/automation.service';
import { google } from 'googleapis';

@Injectable()
export class GmailService {
  private readonly logger = new Logger(GmailService.name);
  private oauth2Client;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
    private firebaseService: FirebaseService,
    private automationService: AutomationService,
  ) {
    const clientId = this.configService.get<string>('GOOGLE_CLIENT_ID');
    const clientSecret = this.configService.get<string>('GOOGLE_CLIENT_SECRET');
    const redirectUri = this.configService.get<string>('GOOGLE_REDIRECT_URI') || 'http://localhost:4000/api/gmail/auth/callback';

    this.oauth2Client = new google.auth.OAuth2(
      clientId,
      clientSecret,
      redirectUri
    );
  }

  getAuthUrl(userId: string) {
    const scopes = [
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/userinfo.email',
    ];

    return this.oauth2Client.generateAuthUrl({
      access_type: 'offline',
      prompt: 'consent',
      scope: scopes,
      state: userId, // Pass userId in state to associate account upon callback
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
      const emailAddress = userInfo.data.email;

      if (!emailAddress) {
        throw new Error('Unable to retrieve email address from Google.');
      }

      // Upsert Gmail Account
      const gmailAccount = await this.prisma.gmailAccount.upsert({
        where: { emailAddress },
        update: {
          userId,
          status: 'connected',
        },
        create: {
          userId,
          emailAddress,
          accountName: emailAddress,
          status: 'connected',
        },
      });

      // Upsert OAuth Tokens
      await this.prisma.oauthToken.upsert({
        where: { accountId: gmailAccount.id },
        update: {
          accessToken: tokens.access_token,
          refreshToken: tokens.refresh_token || '',
          expiresAt: new Date(tokens.expiry_date || Date.now() + 3600000),
          scope: tokens.scope || '',
        },
        create: {
          accountId: gmailAccount.id,
          accessToken: tokens.access_token,
          refreshToken: tokens.refresh_token || '',
          expiresAt: new Date(tokens.expiry_date || Date.now() + 3600000),
          scope: tokens.scope || '',
        },
      });

      return { success: true, email: emailAddress };
    } catch (error) {
      this.logger.error('Failed to handle Google callback', error);
      throw new InternalServerErrorException('Failed to authenticate with Google');
    }
  }

  async syncEmails(userId: string, accountId: string) {
    const account = await this.prisma.gmailAccount.findUnique({
      where: { id: accountId, userId },
      include: { oauthToken: true },
    });

    if (!account || !account.oauthToken) {
      throw new NotFoundException('Gmail account or tokens not found');
    }

    const oauth2Client = new google.auth.OAuth2(
      this.configService.get('GOOGLE_CLIENT_ID'),
      this.configService.get('GOOGLE_CLIENT_SECRET'),
    );
    oauth2Client.setCredentials({
      access_token: account.oauthToken.accessToken,
      refresh_token: account.oauthToken.refreshToken,
    });

    // Auto-refresh token listener
    oauth2Client.on('tokens', async (tokens) => {
      if (tokens.access_token) {
        this.logger.log(`Token refreshed automatically for account ${accountId}`);
        await this.prisma.oauthToken.update({
          where: { accountId: accountId },
          data: {
            accessToken: tokens.access_token,
            ...(tokens.expiry_date && { expiresAt: new Date(tokens.expiry_date) }),
            ...(tokens.refresh_token && { refreshToken: tokens.refresh_token }),
          },
        });
      }
    });

    const gmail = google.gmail({ version: 'v1', auth: oauth2Client });
    
    try {
      const response = await gmail.users.messages.list({
        userId: 'me',
        maxResults: 10, // Fetching latest 10
      });

      const messages = response.data.messages || [];
      let parsedEmails = 0;
      let otpsFound = 0;

      for (const msg of messages) {
        const messageDetails = await gmail.users.messages.get({
          userId: 'me',
          id: msg.id,
          format: 'full',
        });

        const headers = messageDetails.data.payload?.headers;
        const subject = headers?.find((h) => h.name === 'Subject')?.value || 'No Subject';
        const sender = headers?.find((h) => h.name === 'From')?.value || 'Unknown';
        const recipient = headers?.find((h) => h.name === 'To')?.value || 'Unknown';
        const receivedAt = new Date(parseInt(messageDetails.data.internalDate || Date.now().toString()));

        // Extract body
        let bodyText = '';
        if (messageDetails.data.payload?.parts) {
          const part = messageDetails.data.payload.parts.find(p => p.mimeType === 'text/plain');
          if (part && part.body?.data) {
            bodyText = Buffer.from(part.body.data, 'base64').toString('utf-8');
          }
        } else if (messageDetails.data.payload?.body?.data) {
          bodyText = Buffer.from(messageDetails.data.payload.body.data, 'base64').toString('utf-8');
        }

        // AI Analyses: Classification, Phishing Security, Sentiment
        let category = 'General';
        let securityScore = 100;
        let securityAnalysis = '';
        let sentiment = 'Neutral';

        try {
          const [classifyRes, securityRes, sentimentRes] = await Promise.all([
            fetch('http://localhost:4002/api/copilot/classify', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ subject, body: bodyText.substring(0, 500) })
            }).catch(e => null),
            fetch('http://localhost:4002/api/copilot/analyze-security', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ subject, body: bodyText.substring(0, 500) })
            }).catch(e => null),
            fetch('http://localhost:4002/api/copilot/analyze-sentiment', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ subject, body: bodyText.substring(0, 500) })
            }).catch(e => null)
          ]);

          if (classifyRes && classifyRes.ok) {
            const data = await classifyRes.json();
            category = data.category || 'General';
          }
          if (securityRes && securityRes.ok) {
            const data = await securityRes.json();
            securityScore = data.securityScore;
            securityAnalysis = JSON.stringify(data);
          }
          if (sentimentRes && sentimentRes.ok) {
            const data = await sentimentRes.json();
            sentiment = data.sentiment || 'Neutral';
          }
        } catch (err) {
          this.logger.warn('AI Engine services call failed, falling back to heuristics');
        }

        // Save email
        const emailRecord = await this.prisma.email.upsert({
          where: { messageId: msg.id },
          update: { 
            category,
            sentiment,
            securityScore,
            securityAnalysis,
          },
          create: {
            accountId,
            threadId: messageDetails.data.threadId || '',
            messageId: msg.id,
            sender,
            recipient,
            subject,
            bodyText,
            receivedAt,
            category,
            sentiment,
            securityScore,
            securityAnalysis,
          },
        });
        parsedEmails++;

        // Run automation rules
        try {
          await this.automationService.runRules(emailRecord);
        } catch (autoErr) {
          this.logger.error(`Failed to run automation rules for email ${emailRecord.id}`, autoErr);
        }

        // OTP Detection Engine (Simple Regex for 6-digit codes)
        if (bodyText || subject) {
          const combinedText = `${subject} ${bodyText}`;
          // Look for 6 consecutive digits that might be an OTP
          // In a real scenario, this regex would be much smarter (e.g. looking for "code is", "OTP", etc)
          const otpRegex = /\b\d{6}\b/g;
          const matches = combinedText.match(otpRegex);
          
          if (matches && matches.length > 0) {
            // Check if OTP for this email already exists to avoid duplicates
            const existingOtp = await this.prisma.otpMessage.findFirst({
              where: { emailId: emailRecord.id }
            });
            
            if (!existingOtp) {
              const otpCode = matches[0]; // Take the first match
              let serviceName = 'Unknown';
              
              // Simple service guessing based on sender
              if (sender.toLowerCase().includes('google')) serviceName = 'Google';
              else if (sender.toLowerCase().includes('amazon') || sender.toLowerCase().includes('aws')) serviceName = 'AWS';
              else if (sender.toLowerCase().includes('microsoft')) serviceName = 'Microsoft';
              else if (sender.toLowerCase().includes('github')) serviceName = 'GitHub';
              else if (sender.toLowerCase().includes('facebook')) serviceName = 'Facebook';
              else serviceName = sender.split('@')[1]?.split('.')[0] || 'Unknown';
              
              await this.prisma.otpMessage.create({
                data: {
                  emailId: emailRecord.id,
                  serviceName: serviceName.charAt(0).toUpperCase() + serviceName.slice(1),
                  otpCode,
                  expiresAt: new Date(receivedAt.getTime() + 10 * 60000), // Expires 10 mins after receipt
                }
              });
              
              // Update email category
              await this.prisma.email.update({
                where: { id: emailRecord.id },
                data: { category: 'OTP' }
              });
              
              otpsFound++;

              // Trigger FCM Push Notification
              await this.firebaseService.sendPushNotification(
                userId,
                `New OTP: ${serviceName}`,
                `${otpCode} is your ${serviceName} verification code`,
                { type: 'otp', code: otpCode, service: serviceName }
              );

              // Trigger WebSocket Notification via notification-engine
              try {
                fetch('http://localhost:4004/api/notify', {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({
                    userId,
                    event: 'new_otp',
                    data: { serviceName, otpCode }
                  })
                }).catch(e => this.logger.warn('Failed to notify WS gateway'));
              } catch (e) { }
            }
          }
        }
      }

      await this.prisma.gmailAccount.update({
        where: { id: accountId },
        data: { lastSync: new Date(), status: 'connected' },
      });

      return { success: true, synced: parsedEmails, otpsExtracted: otpsFound };
    } catch (error: any) {
      this.logger.error(`Failed to sync emails for account ${accountId}`, error);
      
      // If the token is invalid or revoked, update account status
      const isAuthError = error?.code === 401 || error?.response?.status === 401 || error?.message?.includes('invalid_grant');
      if (isAuthError) {
        await this.prisma.gmailAccount.update({
          where: { id: accountId },
          data: { status: 'disconnected' },
        });
        
        // Notify user to re-authenticate
        await this.firebaseService.sendPushNotification(
          userId,
          'Gmail Sync Failed',
          `Your Gmail account ${account.emailAddress} needs to be reconnected.`,
          { type: 'auth_error', accountId }
        );
      }

      throw new InternalServerErrorException('Failed to sync emails');
    }
  }

  // --- NEW BULK METHODS ---

  async bulkSync(userId: string, accountIds: string[]) {
    const results = [];
    // Process in chunks to avoid slamming the API or DB
    const CHUNK_SIZE = 5;
    for (let i = 0; i < accountIds.length; i += CHUNK_SIZE) {
      const chunk = accountIds.slice(i, i + CHUNK_SIZE);
      const chunkPromises = chunk.map(async (id) => {
        try {
          const res = await this.syncEmails(userId, id);
          return { id, status: 'success', ...res };
        } catch (err) {
          return { id, status: 'failed', error: err.message };
        }
      });
      const chunkResults = await Promise.all(chunkPromises);
      results.push(...chunkResults);
      if (i + CHUNK_SIZE < accountIds.length) await this.delay(1000);
    }
    return { success: true, results };
  }

  async bulkDelete(userId: string, accountIds: string[]) {
    // Make sure all accounts belong to the user
    const accounts = await this.prisma.gmailAccount.findMany({
      where: { userId, id: { in: accountIds } }
    });
    
    const validIds = accounts.map(a => a.id);
    
    if (validIds.length === 0) return { success: false, message: 'No valid accounts found' };

    // Delete in transaction
    await this.prisma.$transaction([
      this.prisma.oauthToken.deleteMany({ where: { accountId: { in: validIds } } }),
      this.prisma.otpMessage.deleteMany({ where: { email: { accountId: { in: validIds } } } }),
      this.prisma.emailLabel.deleteMany({ where: { email: { accountId: { in: validIds } } } }),
      this.prisma.email.deleteMany({ where: { accountId: { in: validIds } } }),
      this.prisma.gmailAccount.deleteMany({ where: { id: { in: validIds } } })
    ]);

    return { success: true, deletedCount: validIds.length };
  }

  async updateTags(userId: string, accountId: string, tags: string) {
    const account = await this.prisma.gmailAccount.findUnique({
      where: { id: accountId, userId }
    });
    if (!account) throw new NotFoundException('Account not found');
    
    await this.prisma.gmailAccount.update({
      where: { id: accountId },
      data: { tags }
    });
    return { success: true, tags };
  }

  // Helper for delay
  private delay(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  @Cron('*/5 * * * *')
  async handleAutoSync() {
    this.logger.log('Running Auto-Sync for all connected Gmail accounts...');
    try {
      const accounts = await this.prisma.gmailAccount.findMany({
        where: { status: 'connected' }
      });
      
      const CHUNK_SIZE = 5;
      for (let i = 0; i < accounts.length; i += CHUNK_SIZE) {
        const chunk = accounts.slice(i, i + CHUNK_SIZE);
        
        await Promise.allSettled(chunk.map(async (account) => {
          try {
            this.logger.log(`Syncing account ${account.emailAddress}...`);
            await this.syncEmails(account.userId, account.id);
          } catch (err) {
            this.logger.error(`Failed to auto-sync account ${account.emailAddress}`, err);
          }
        }));

        if (i + CHUNK_SIZE < accounts.length) {
          this.logger.log(`Chunk finished. Waiting 2 seconds before next chunk...`);
          await this.delay(2000); // 2 second delay between chunks to avoid rate limits
        }
      }
      this.logger.log('Auto-Sync completed.');
    } catch (err) {
      this.logger.error('Failed to fetch accounts for auto-sync', err);
    }
  }
}
