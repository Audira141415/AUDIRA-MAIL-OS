import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { PrometheusModule } from '@willsoto/nestjs-prometheus';
import { LoggerModule } from 'nestjs-pino';
import { AuthModule } from './auth/auth.module';
import { PrismaModule } from './prisma/prisma.module';
import { GmailModule } from './gmail/gmail.module';
import { OtpModule } from './otp/otp.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { FirebaseModule } from './firebase/firebase.module';
import { CopilotModule } from './copilot/copilot.module';
import { AccountsModule } from './accounts/accounts.module';
import { AutomationModule } from './automations/automation.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([{
      ttl: 60000,
      limit: 100, // 100 requests per minute
    }]),
    PrometheusModule.register(),
    LoggerModule.forRoot({
      pinoHttp: {
        transport: {
          target: 'pino-pretty',
          options: { singleLine: true }
        },
      },
    }),
    PrismaModule, 
    AuthModule, 
    GmailModule,
    OtpModule,
    DashboardModule,
    FirebaseModule,
    CopilotModule,
    AccountsModule,
    AutomationModule,
  ],
  controllers: [],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
