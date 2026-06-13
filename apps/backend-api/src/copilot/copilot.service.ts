import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class CopilotService {
  private readonly logger = new Logger(CopilotService.name);
  private readonly AI_ENGINE_URL = 'http://localhost:4002/api/copilot/chat';

  constructor(private prisma: PrismaService) {}

  async chat(userId: string, message: string) {
    this.logger.log(`Copilot query from user ${userId}: ${message}`);
    
    // 1. Gather context from database
    const emailCount = await this.prisma.email.count({ where: { account: { userId } } });
    const latestOtp = await this.prisma.otpMessage.findFirst({
      where: { email: { account: { userId } } },
      orderBy: { createdAt: 'desc' }
    });
    const accountsCount = await this.prisma.gmailAccount.count({ where: { userId, status: 'connected' } });
    
    let contextStr = `User Data Context: \n- Active Accounts: ${accountsCount}\n- Total Emails: ${emailCount}\n`;
    if (latestOtp) {
      contextStr += `- Latest OTP: ${latestOtp.otpCode} for ${latestOtp.serviceName} received at ${latestOtp.createdAt.toISOString()}\n`;
    }

    // 2. Delegate to ai-engine microservice
    try {
      const response = await fetch(this.AI_ENGINE_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message, context: contextStr }),
      });
      
      if (!response.ok) {
        throw new Error(`AI Engine returned ${response.status}`);
      }
      
      const data = await response.json();
      return {
        role: 'assistant',
        content: data.content,
        timestamp: new Date().toISOString()
      };
    } catch (e) {
      this.logger.error('Failed to communicate with ai-engine', e);
      return {
        role: 'assistant',
        content: 'SYSTEM_ERR: AI Neural Engine is currently offline or unreachable.',
        timestamp: new Date().toISOString()
      };
    }
  }
}
