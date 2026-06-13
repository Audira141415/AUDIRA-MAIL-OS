import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
    credentials: true,
  });
  
  const port = process.env.WORKER_ENGINE_PORT || 3314;
  await app.listen(port);
  console.log(`Audira Worker Engine running on port ${port}`);
}
bootstrap();
