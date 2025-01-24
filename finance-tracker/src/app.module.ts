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

@Module({
  imports: [
    TypeOrmModule.forRoot(databaseConfig),
    AuthModule,
    CardModule,
    UserModule,
    CategoriesModule,
    TransactionsModule,
    ReportsModule,
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
