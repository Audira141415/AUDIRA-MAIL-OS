import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { GoogleAuthModule } from './auth/google-auth.module';
import { BullModule } from '@nestjs/bullmq';
import { MailModule } from './mail/mail.module';
import { ConfigModule } from '@nestjs/config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule, 
    GoogleAuthModule,
    BullModule.forRoot({
      connection: {
        host: 'localhost',
        port: 6379,
      },
    }),
    MailModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
