import { Injectable, InternalServerErrorException, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as speakeasy from 'speakeasy';
import * as qrcode from 'qrcode';

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);

  constructor(private prisma: PrismaService) {}

  async generateSecret(userId: string) {
    try {
      const user = await this.prisma.user.findUnique({ where: { id: userId } });
      if (!user) {
        throw new NotFoundException('User not found');
      }

      // 1. Generate a new secret
      const secret = speakeasy.generateSecret({ 
        name: `AUDIRA-MAIL-OS (${user.email})` 
      });

      // 2. Save secret to the user record
      await this.prisma.user.update({
        where: { id: userId },
        data: { mfaSecret: secret.base32 },
      });

      // 3. Create Key URI for the Authenticator app (already provided by speakeasy)
      const otpauthUrl = secret.otpauth_url;

      // 4. Generate QR code image (Data URL)
      const qrCodeDataUrl = await qrcode.toDataURL(otpauthUrl);

      return {
        secret: secret.base32,
        qrCodeDataUrl,
      };
    } catch (error) {
      this.logger.error('Failed to generate OTP secret', error);
      throw new InternalServerErrorException('Failed to generate OTP secret');
    }
  }

  async verifyOtp(userId: string, token: string) {
    try {
      const user = await this.prisma.user.findUnique({ where: { id: userId } });
      if (!user || !user.mfaSecret) {
        return { isValid: false, message: 'OTP secret not configured' };
      }

      const isValid = speakeasy.totp.verify({
        secret: user.mfaSecret,
        encoding: 'base32',
        token,
      });

      if (isValid && !user.mfaEnabled) {
        // Automatically enable MFA once they successfully verify for the first time
        await this.prisma.user.update({
          where: { id: userId },
          data: { mfaEnabled: true },
        });
      }

      return { isValid };
    } catch (error) {
      this.logger.error('Failed to verify OTP', error);
      return { isValid: false, message: 'Server error during verification' };
    }
  }
}

