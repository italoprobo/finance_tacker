import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Transaction } from './entities/transaction.entity';
import { TransactionsService } from './services/transaction.service';
import { TransactionsController } from './controllers/transaction.controller';
import { User } from '../user/entities/user.entity';
import { Category } from '../categories/entities/categories.entity';
import { Client } from '../clients/entities/client.entity';
import { Card } from '../cards/entities/card.entity';
import { CardModule } from '../cards/card.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Transaction, User, Category, Client, Card]),
    CardModule,
  ],
  controllers: [TransactionsController],
  providers: [TransactionsService],
  exports: [TransactionsService],
})
export class TransactionsModule {}