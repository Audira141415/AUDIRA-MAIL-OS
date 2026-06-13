import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { MailController } from './mail.controller';
import { MailService } from './mail.service';

@Module({
  imports: [
    BullModule.registerQueue({
      name: 'EMAIL_SYNC_QUEUE',
    }),
  ],
  controllers: [MailController],
  providers: [MailService],
})
export class MailModule {}
