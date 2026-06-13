import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));
  
  app.enableCors({
    origin: '*',
    credentials: true,
  });
  
  const port = process.env.MAIL_ENGINE_PORT || 3312;
  await app.listen(port);
  console.log(`Audira Mail Engine running on port ${port}`);
}
bootstrap();
