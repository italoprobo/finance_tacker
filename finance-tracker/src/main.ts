import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { databaseConfig } from './config/database.config';

dotenv.config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ?? 3000);

  app.enableCors({
    origin: '*', 
    methods: 'GET,HEAD,POST,PUT,DELETE,PATCH,OPTIONS', 
    allowedHeaders: ['Content-Type', 'Authorization'], 
    credentials: true, 
  });

  app.use(function(req, res, next) {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET,PUT,PATCH,POST,DELETE");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

}
bootstrap();

async function testeDatabaseConnection() {
  const dataSource = new DataSource(databaseConfig);

  try {
    await dataSource.initialize();
    console.log('Conexão com o banco de dados realizada com sucesso!');
  } catch (error) {
    console.error('Erro ao tentar conectar com o banco de dados:', error);
  } finally {
    await dataSource.destroy();
  }
}