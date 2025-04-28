import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClientService } from './services/client.service';
import { ClientController } from './controllers/client.controller';
import { Client } from './entities/client.entity';
import { User } from '../user/entities/user.entity';
import { Category } from '../categories/entities/categories.entity';
import { CategoriesModule } from '../categories/categories.module';
import { TransactionsModule } from '../transactions/transaction.module';

@Module({
    imports: [
        TypeOrmModule.forFeature([Client, User, Category]),
        TransactionsModule,
        CategoriesModule,
    ],
    controllers: [ClientController],
    providers: [ClientService],
    exports: [ClientService],
})
export class ClientModule {}
