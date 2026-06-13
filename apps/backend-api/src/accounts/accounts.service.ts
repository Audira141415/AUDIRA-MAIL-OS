import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AccountsService {
  constructor(private prisma: PrismaService) {}

  async getAccountsByUserId(userId: string) {
    const accounts = await this.prisma.gmailAccount.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return accounts.map(acc => ({
      id: acc.id,
      email: acc.emailAddress,
      status: acc.status,
      storage: acc.storageUsage,
      lastSync: acc.lastSync ? acc.lastSync.toISOString() : 'Never',
    }));
  }
}
