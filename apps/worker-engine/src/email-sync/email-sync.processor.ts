import { Processor, WorkerHost } from '@nestjs/bullmq';
import { Job } from 'bullmq';

@Processor('EMAIL_SYNC_QUEUE')
export class EmailSyncProcessor extends WorkerHost {
  async process(job: Job<any, any, string>): Promise<any> {
    console.log(`[Worker Engine] Processing job ${job.id} of type ${job.name}...`);
    console.log(`[Worker Engine] Data received:`, job.data);

    // Simulate heavy lifting (e.g., parsing email, extracting OTPs, calling AI)
    await new Promise((resolve) => setTimeout(resolve, 2000));

    console.log(`[Worker Engine] Job ${job.id} completed successfully!`);
    return { success: true, processedAt: new Date().toISOString() };
  }
}
