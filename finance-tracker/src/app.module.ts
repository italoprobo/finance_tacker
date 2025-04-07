import { Injectable, MiddlewareConsumer, Module, NestMiddleware, RequestMethod } from '@nestjs/common';
import { TypeOrmModule } from "@nestjs/typeorm";
import { databaseConfig } from './config/database.config';
import { AuthModule } from './modules/auth/auth.module';
import { ProtectedController } from './modules/auth/protected/protected.controller';
import { CardModule } from './modules/cards/card.module';
import { UserModule } from './modules/user/user.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { TransactionsModule } from './modules/transactions/transaction.module';
import { ReportsModule } from './modules/reports/reports.module';
import { CorsMiddleware } from './modules/middleware/middleware';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { UploadModule } from './modules/upload/upload.module';

@Module({
  imports: [
    TypeOrmModule.forRoot(databaseConfig),
    AuthModule,
    CardModule,
    UserModule,
    CategoriesModule,
    TransactionsModule,
    ReportsModule,
    UploadModule,
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads',
      exclude: ['/api*'],
      serveStaticOptions: {
        index: false,
        fallthrough: true,
      },
    }),
  ],
  controllers: [ProtectedController],
  providers: [],
})

export class AppModule {
  configure(consumer: MiddlewareConsumer){
    consumer
    .apply(CorsMiddleware)
    .forRoutes({ path: '*', method: RequestMethod.ALL });
  }
}
