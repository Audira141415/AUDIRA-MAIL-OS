import { Controller, Get, Query, Req, Res, UseGuards } from '@nestjs/common';
import { GmailService } from './gmail.service';
import { Request, Response } from 'express';
// Assuming we have JwtAuthGuard, let's import it. If it doesn't exist, this will fail in compilation, but we know auth module has guards.
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('gmail')
export class GmailController {
  constructor(private readonly gmailService: GmailService) {}

  @UseGuards(JwtAuthGuard)
  @Get('auth/url')
  getAuthUrl(@Req() req: any) {
    const userId = req.user.id; // JWT stores user in req.user
    return { url: this.gmailService.getAuthUrl(userId) };
  }

  @Get('auth/callback')
  async handleCallback(@Query('code') code: string, @Query('state') state: string, @Res() res: Response) {
    if (!code || !state) {
      return res.status(400).send('Missing code or state');
    }
    const userId = state;
    try {
      await this.gmailService.handleCallback(code, userId);
      // Deep link redirect so mobile app can detect success
      res.redirect('audira://gmail/callback?status=success');
    } catch (e) {
      res.redirect('audira://gmail/callback?status=error');
    }
  }

  @UseGuards(JwtAuthGuard)
  @Get('sync')
  async syncEmails(@Req() req: any, @Query('accountId') accountId: string) {
    if (!accountId) {
      return { error: 'Missing accountId parameter' };
    }
    const userId = req.user.id;
    return await this.gmailService.syncEmails(userId, accountId);
  }

  // --- NEW BULK ENDPOINTS ---
  
  @UseGuards(JwtAuthGuard)
  @Get('bulk-sync')
  async bulkSync(@Req() req: any, @Query('accountIds') accountIds: string) {
    if (!accountIds) return { error: 'Missing accountIds parameter' };
    const ids = accountIds.split(',');
    const userId = req.user.id;
    return await this.gmailService.bulkSync(userId, ids);
  }

  @UseGuards(JwtAuthGuard)
  @Get('bulk-delete')
  async bulkDelete(@Req() req: any, @Query('accountIds') accountIds: string) {
    if (!accountIds) return { error: 'Missing accountIds parameter' };
    const ids = accountIds.split(',');
    const userId = req.user.id;
    return await this.gmailService.bulkDelete(userId, ids);
  }

  @UseGuards(JwtAuthGuard)
  @Get('update-tags')
  async updateTags(@Req() req: any, @Query('accountId') accountId: string, @Query('tags') tags: string) {
    if (!accountId) return { error: 'Missing accountId parameter' };
    const userId = req.user.id;
    return await this.gmailService.updateTags(userId, accountId, tags || '');
  }
}
