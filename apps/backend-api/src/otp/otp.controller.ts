import { Body, Controller, Post, Req, UseGuards } from '@nestjs/common';
import { OtpService } from './otp.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('otp')
@UseGuards(JwtAuthGuard)
export class OtpController {
  constructor(private readonly otpService: OtpService) {}

  @Post('generate')
  async generateSecret(@Req() req: any) {
    const userId = req.user.id;
    return await this.otpService.generateSecret(userId);
  }

  @Post('verify')
  async verifyOtp(@Req() req: any, @Body('token') token: string) {
    if (!token) {
      return { isValid: false, message: 'Token is required' };
    }
    const userId = req.user.id;
    return await this.otpService.verifyOtp(userId, token);
  }
}
