import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { lastValueFrom } from 'rxjs';
import * as crypto from 'crypto';

@Injectable()
export class WebhookService {
  private readonly logger = new Logger(WebhookService.name);

  constructor(private readonly httpService: HttpService) {}

  async dispatchEvent(webhookUrl: string, secret: string, event: string, payload: any) {
    try {
      const timestamp = Date.now().toString();
      const payloadString = JSON.stringify({ event, payload });
      
      // Create signature for security
      const signature = crypto
        .createHmac('sha256', secret)
        .update(`${timestamp}.${payloadString}`)
        .digest('hex');

      const response = await lastValueFrom(
        this.httpService.post(webhookUrl, payloadString, {
          headers: {
            'Content-Type': 'application/json',
            'x-audira-signature': signature,
            'x-audira-timestamp': timestamp,
            'x-audira-event': event,
          },
          timeout: 5000,
        })
      );

      this.logger.log(`Successfully dispatched webhook to ${webhookUrl}. Status: ${response.status}`);
      return true;
    } catch (error: any) {
      this.logger.error(`Failed to dispatch webhook to ${webhookUrl}: ${error.message}`);
      // In a real system, you might want to retry with exponential backoff via BullMQ
      return false;
    }
  }
}
