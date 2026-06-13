import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { EmailSyncModule } from './email-sync/email-sync.module';
import { WebhookModule } from './webhooks/webhook.module';

@Module({
  imports: [
    // Redis connection for BullMQ
    // Mocked connection for now, can fail gracefully if redis is not running
    BullModule.forRoot({
      connection: {
        host: 'localhost',
        port: 6379,
      },
    }),
    EmailSyncModule,
    WebhookModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
