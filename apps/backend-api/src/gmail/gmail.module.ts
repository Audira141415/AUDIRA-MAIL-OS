import { Module } from '@nestjs/common';
import { GmailService } from './gmail.service';
import { GmailController } from './gmail.controller';
import { ConfigModule } from '@nestjs/config';
import { AutomationModule } from '../automations/automation.module';

@Module({
  imports: [ConfigModule, AutomationModule],
  providers: [GmailService],
  controllers: [GmailController],
  exports: [GmailService],
})
export class GmailModule {}
