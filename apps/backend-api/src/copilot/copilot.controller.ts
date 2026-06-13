import { Controller, Post, Body, Request, UseGuards } from '@nestjs/common';
import { CopilotService } from './copilot.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@UseGuards(JwtAuthGuard)
@Controller('api/copilot')
export class CopilotController {
  constructor(private readonly copilotService: CopilotService) {}

  @Post('chat')
  async chat(@Request() req: any, @Body('message') message: string) {
    if (!message) {
      return { role: 'assistant', content: 'Empty message received.', timestamp: new Date().toISOString() };
    }
    return this.copilotService.chat(req.user.id, message);
  }
}
