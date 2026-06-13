import { Module } from '@nestjs/common';
import { EmailSyncProcessor } from './email-sync.processor';

@Module({
  providers: [EmailSyncProcessor],
})
export class EmailSyncModule {}
