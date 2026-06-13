import { Controller, Post, Body } from '@nestjs/common';
import { MailService } from './mail.service';

@Controller('mail')
export class MailController {
  constructor(private readonly mailService: MailService) {}

  @Post('test-queue')
  async testQueue(@Body() body: { emailId: string; userId: string }) {
    return this.mailService.triggerEmailSync(body.emailId, body.userId);
  }
}
