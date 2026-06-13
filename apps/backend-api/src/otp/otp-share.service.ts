import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import * as crypto from 'crypto';

@Injectable()
export class OtpShareService {
  constructor(private prisma: PrismaService) {}

  async createShareLink(otpMessageId: string, durationMinutes: number) {
    const otp = await this.prisma.otpMessage.findUnique({
      where: { id: otpMessageId },
    });

    if (!otp) {
      throw new NotFoundException('OTP Message not found');
    }

    const token = crypto.randomBytes(16).toString('hex');
    const expiresAt = new Date(Date.now() + durationMinutes * 60000);

    const shareLink = await this.prisma.otpShareLink.create({
      data: {
        otpMessageId,
        token,
        expiresAt,
        maxUses: 1,
      },
    });

    return shareLink;
  }

  async getOtpByToken(token: string) {
    const shareLink = await this.prisma.otpShareLink.findUnique({
      where: { token },
      include: {
        otpMessage: {
          include: {
            email: true,
          },
        },
      },
    });

    if (!shareLink) {
      throw new NotFoundException('Share link not valid or has expired');
    }

    if (new Date() > shareLink.expiresAt) {
      throw new BadRequestException('This share link has expired');
    }

    if (shareLink.usedCount >= shareLink.maxUses) {
      throw new BadRequestException('This share link has already been used and self-destructed');
    }

    // Increment use count
    await this.prisma.otpShareLink.update({
      where: { id: shareLink.id },
      data: { usedCount: shareLink.usedCount + 1 },
    });

    return {
      serviceName: shareLink.otpMessage.serviceName,
      otpCode: shareLink.otpMessage.otpCode,
      sender: shareLink.otpMessage.email.sender,
      receivedAt: shareLink.otpMessage.email.receivedAt,
      expiresAt: shareLink.expiresAt,
    };
  }
}
