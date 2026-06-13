import { Module } from '@nestjs/common';
import { OtpService } from './otp.service';
import { OtpController } from './otp.controller';
import { OtpShareService } from './otp-share.service';
import { OtpShareController } from './otp-share.controller';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [OtpService, OtpShareService],
  controllers: [OtpController, OtpShareController],
  exports: [OtpService, OtpShareService],
})
export class OtpModule {}
