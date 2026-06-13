import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
    credentials: true,
  });
  
  const port = process.env.NOTIFICATION_ENGINE_PORT || 3315;
  await app.listen(port);
  console.log(`Audira Notification Engine running on port ${port}`);
}
bootstrap();
