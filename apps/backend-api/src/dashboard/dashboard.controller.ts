import { Controller, Get, Request, Query, UseGuards } from '@nestjs/common';
import { DashboardService } from './dashboard.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('api/dashboard')
export class DashboardController {
  constructor(private readonly dashboardService: DashboardService) {}

  @Get('stats')
  async getStats(@Request() req: any) {
    return this.dashboardService.getStats(req.user.id);
  }

  @Get('recent-otps')
  async getRecentOtps(
    @Request() req: any, 
    @Query('search') search?: string,
    @Query('accountId') accountId?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string
  ) {
    return this.dashboardService.getRecentOtps(req.user.id, Number(limit || 10), search, accountId, Number(page || 1));
  }

  @Get('recent-emails')
  async getRecentEmails(
    @Request() req: any, 
    @Query('search') search?: string,
    @Query('accountId') accountId?: string,
    @Query('page') page?: string,
    @Query('limit') limit?: string,
    @Query('category') category?: string
  ) {
    return this.dashboardService.getRecentEmails(req.user.id, Number(limit || 20), search, accountId, Number(page || 1), category);
  }

  @Get('gmail-accounts')
  async getGmailAccounts(@Request() req: any) {
    return this.dashboardService.getGmailAccounts(req.user.id);
  }

  @Get('search')
  async search(
    @Request() req: any,
    @Query('q') query: string,
    @Query('limit') limit?: string
  ) {
    return this.dashboardService.globalSearch(req.user.id, query, limit ? Number(limit) : 5);
  }
}
