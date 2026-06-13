import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getStats(userId: string) {
    const now = new Date();
    const todayStart = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    const [
      totalAccounts,
      activeAccounts,
      emailsToday,
      otpToday,
      storageUsedRaw,
    ] = await Promise.all([
      // Total Gmail accounts linked to this user
      this.prisma.gmailAccount.count({ where: { userId } }),

      // Active accounts (status = connected)
      this.prisma.gmailAccount.count({ where: { userId, status: 'connected' } }),

      // Emails received today across all user's accounts
      this.prisma.email.count({
        where: {
          account: { userId },
          receivedAt: { gte: todayStart },
        },
      }),

      // OTP codes extracted today
      this.prisma.otpMessage.count({
        where: {
          email: {
            account: { userId },
          },
          createdAt: { gte: todayStart },
        },
      }),

      // Sum of storage usage across accounts
      this.prisma.gmailAccount.aggregate({
        where: { userId },
        _sum: { storageUsage: true },
      }),
    ]);

    const storageUsedGb = storageUsedRaw._sum.storageUsage ?? 0;

    return {
      totalAccounts,
      activeAccounts,
      emailsToday,
      otpToday,
      storageUsedGb: parseFloat(storageUsedGb.toFixed(2)),
    };
  }

  async getRecentOtps(userId: string, limit = 10, search?: string, accountId?: string, page = 1) {
    const whereClause: any = {
      email: { account: { userId } },
    };

    if (accountId) {
      whereClause.email.accountId = accountId;
    }

    if (search) {
      whereClause.OR = [
        { serviceName: { contains: search } },
        { otpCode: { contains: search } },
      ];
    }

    const otps = await this.prisma.otpMessage.findMany({
      where: whereClause,
      orderBy: { createdAt: 'desc' },
      take: Number(limit),
      skip: (Number(page) - 1) * Number(limit),
      include: {
        email: {
          select: { sender: true, subject: true, receivedAt: true },
        },
      },
    });

    return otps.map((otp) => ({
      id: otp.id,
      serviceName: otp.serviceName,
      otpCode: otp.otpCode,
      expiresAt: otp.expiresAt,
      createdAt: otp.createdAt,
      sender: otp.email.sender,
      subject: otp.email.subject,
    }));
  }

  async getRecentEmails(userId: string, limit = 20, search?: string, accountId?: string, page = 1, category?: string) {
    const whereClause: any = { account: { userId } };
    
    if (accountId) {
      whereClause.accountId = accountId;
    }

    if (category && category !== 'All') {
      whereClause.category = category;
    }

    if (search) {
      whereClause.OR = [
        { sender: { contains: search } },
        { subject: { contains: search } },
      ];
    }

    const emails = await this.prisma.email.findMany({
      where: whereClause,
      orderBy: { receivedAt: 'desc' },
      take: Number(limit),
      skip: (Number(page) - 1) * Number(limit),
      select: {
        id: true,
        sender: true,
        subject: true,
        category: true,
        isRead: true,
        receivedAt: true,
        bodyText: true,
        bodyHtml: true,
        sentiment: true,
        securityScore: true,
        securityAnalysis: true,
      },
    });

    return emails;
  }

  async getGmailAccounts(userId: string) {
    return this.prisma.gmailAccount.findMany({
      where: { userId },
      select: {
        id: true,
        emailAddress: true,
        accountName: true,
        status: true,
        lastSync: true,
        storageUsage: true,
        tags: true,
        createdAt: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async globalSearch(userId: string, query: string, limit = 5) {
    if (!query || query.trim() === '') {
      return { emails: [], otps: [], accounts: [] };
    }

    const searchQuery = query.trim();

    const [emails, otps, accounts] = await Promise.all([
      // Search Emails
      this.prisma.email.findMany({
        where: {
          account: { userId },
          OR: [
            { subject: { contains: searchQuery, mode: 'insensitive' } },
            { sender: { contains: searchQuery, mode: 'insensitive' } },
            { bodyText: { contains: searchQuery, mode: 'insensitive' } }
          ]
        },
        orderBy: { receivedAt: 'desc' },
        take: limit,
        select: { id: true, subject: true, sender: true, receivedAt: true }
      }),
      // Search OTPs
      this.prisma.otpMessage.findMany({
        where: {
          email: { account: { userId } },
          OR: [
            { serviceName: { contains: searchQuery, mode: 'insensitive' } },
            { otpCode: { contains: searchQuery, mode: 'insensitive' } }
          ]
        },
        orderBy: { createdAt: 'desc' },
        take: limit,
        select: { id: true, serviceName: true, otpCode: true, createdAt: true }
      }),
      // Search Accounts
      this.prisma.gmailAccount.findMany({
        where: {
          userId,
          OR: [
            { emailAddress: { contains: searchQuery, mode: 'insensitive' } },
            { accountName: { contains: searchQuery, mode: 'insensitive' } },
            { tags: { contains: searchQuery, mode: 'insensitive' } }
          ]
        },
        take: limit,
        select: { id: true, emailAddress: true, accountName: true, status: true }
      })
    ]);

    return { emails, otps, accounts };
  }
}
