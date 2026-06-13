import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

@Injectable()
export class MailService {
  constructor(
    @InjectQueue('EMAIL_SYNC_QUEUE') private readonly emailQueue: Queue,
  ) {}

  async triggerEmailSync(emailId: string, userId: string) {
    // Add job to the BullMQ queue
    const job = await this.emailQueue.add('process-new-email', {
      emailId,
      userId,
      timestamp: new Date().toISOString(),
    });

    console.log(`[Mail Engine] Dispatched job ${job.id} to EMAIL_SYNC_QUEUE`);

    return {
      message: 'Job successfully added to queue',
      jobId: job.id,
    };
  }
}
