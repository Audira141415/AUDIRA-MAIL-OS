import { Controller, Post, Body } from '@nestjs/common';
import { CopilotService } from './copilot.service';

@Controller('api/copilot')
export class CopilotController {
  constructor(private readonly copilotService: CopilotService) {}

  @Post('chat')
  async handleChat(@Body() body: { message: string, context?: string }) {
    if (!body.message) {
      return { content: 'Please provide a message.' };
    }
    const reply = await this.copilotService.getChatResponse(body.message, body.context);
    return { content: reply };
  }

  @Post('classify')
  async handleClassify(@Body() body: { subject: string, body: string }) {
    const category = await this.copilotService.classifyEmail(body.subject || '', body.body || '');
    return { category };
  }

  @Post('analyze-security')
  async handleAnalyzeSecurity(@Body() body: { subject: string, body: string }) {
    const analysis = await this.copilotService.analyzeSecurity(body.subject || '', body.body || '');
    return analysis;
  }

  @Post('analyze-sentiment')
  async handleAnalyzeSentiment(@Body() body: { subject: string, body: string }) {
    const sentimentAnalysis = await this.copilotService.analyzeSentimentAndReply(body.subject || '', body.body || '');
    return sentimentAnalysis;
  }
}
