import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { CopilotModule } from './copilot/copilot.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    CopilotModule
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
