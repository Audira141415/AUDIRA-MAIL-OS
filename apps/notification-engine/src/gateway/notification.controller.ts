import { Controller, Post, Body } from '@nestjs/common';
import { NotificationGateway } from './notification.gateway';

@Controller('api/notify')
export class NotificationController {
  constructor(private readonly gateway: NotificationGateway) {}

  @Post()
  notifyUser(@Body() body: { userId: string, event: string, data: any }) {
    if (body.userId && body.event) {
      this.gateway.notifyUser(body.userId, body.event, body.data);
      return { success: true };
    }
    return { success: false, message: 'Missing parameters' };
  }
}
