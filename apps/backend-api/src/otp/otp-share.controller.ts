import { Body, Controller, Post, Get, Param, UseGuards } from '@nestjs/common';
import { OtpShareService } from './otp-share.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('api/otp-share')
export class OtpShareController {
  constructor(private readonly otpShareService: OtpShareService) {}

  @Post('create')
  @UseGuards(JwtAuthGuard)
  async createLink(@Body() body: { otpMessageId: string, durationMinutes?: number }) {
    const duration = body.durationMinutes || 5;
    const link = await this.otpShareService.createShareLink(body.otpMessageId, duration);
    return {
      success: true,
      token: link.token,
      expiresAt: link.expiresAt,
      url: `http://localhost:3310/otp/share/${link.token}`
    };
  }

  @Get('public/:token')
  async getSharedOtp(@Param('token') token: string) {
    return await this.otpShareService.getOtpByToken(token);
  }
}
