import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AccountsService } from './accounts.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('api/accounts')
export class AccountsController {
  constructor(private readonly accountsService: AccountsService) {}

  @UseGuards(JwtAuthGuard)
  @Get()
  async getAccounts(@Request() req) {
    return this.accountsService.getAccountsByUserId(req.user.userId);
  }
}
