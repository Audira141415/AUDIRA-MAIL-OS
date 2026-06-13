import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-custom';
import { Request } from 'express';
import { PrismaService } from '../../prisma/prisma.service';
import * as crypto from 'crypto';

@Injectable()
export class ApiKeyStrategy extends PassportStrategy(Strategy, 'api-key') {
  constructor(private prisma: PrismaService) {
    super();
  }

  async validate(req: Request): Promise<any> {
    const apiKeyHeader = req.headers['x-api-key'] as string;

    if (!apiKeyHeader) {
      throw new UnauthorizedException('API Key is missing');
    }

    const keyHash = crypto.createHash('sha256').update(apiKeyHeader).digest('hex');

    const apiKey = await this.prisma.apiKey.findUnique({
      where: { keyHash },
      include: { organization: true },
    });

    if (!apiKey) {
      throw new UnauthorizedException('Invalid API Key');
    }

    if (apiKey.expiresAt && apiKey.expiresAt < new Date()) {
      throw new UnauthorizedException('API Key has expired');
    }

    // Update last used timestamp asynchronously
    this.prisma.apiKey.update({
      where: { id: apiKey.id },
      data: { lastUsedAt: new Date() },
    }).catch(console.error);

    // Return a constructed "user" object that represents the API consumer
    return {
      isApiKey: true,
      organizationId: apiKey.organizationId,
      organization: apiKey.organization,
      name: `API-Consumer-${apiKey.name}`,
      role: 'API_CLIENT',
    };
  }
}
