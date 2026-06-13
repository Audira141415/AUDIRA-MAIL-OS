import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  
  app.enableCors({
    origin: '*',
    credentials: true,
  });
  
  const port = process.env.AI_ENGINE_PORT || 3313;
  await app.listen(port);
  console.log(`Audira AI Engine running on port ${port}`);
}
bootstrap();
