import { Body, Controller, Post, Get, Param, Patch, Delete, UseGuards, Query } from '@nestjs/common';
import { AutomationService } from './automation.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('api/automations')
@UseGuards(JwtAuthGuard)
export class AutomationController {
  constructor(private readonly automationService: AutomationService) {}

  @Get('rules')
  async getRules() {
    return await this.automationService.getRules();
  }

  @Post('rules')
  async createRule(@Body() body: { name: string, conditions: any, actions: any[] }) {
    return await this.automationService.createRule(body.name, body.conditions, body.actions);
  }

  @Patch('rules/:id')
  async updateRule(
    @Param('id') id: string,
    @Body() body: { name?: string, conditions?: any, actions?: any[], isActive?: boolean }
  ) {
    return await this.automationService.updateRule(id, body);
  }

  @Delete('rules/:id')
  async deleteRule(@Param('id') id: string) {
    await this.automationService.deleteRule(id);
    return { success: true };
  }

  @Get('logs')
  async getLogs(@Query('limit') limit?: number) {
    return await this.automationService.getLogs(limit ? Number(limit) : 50);
  }
}
