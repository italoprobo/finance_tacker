import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { TransactionsService } from "./services/transaction.service";
import { TransactionsController } from "./controllers/transaction.controller";
import { Transaction } from "./entities/transaction.entity";
import { User } from "../user/entities/user.entity";
import { Category } from "../categories/entities/categories.entity";
import { Client } from "../clients/entities/client.entity";

@Module({
    imports: [TypeOrmModule.forFeature([Transaction, User, Category, Client])],
    controllers: [TransactionsController],
    providers: [TransactionsService],
    exports: [TransactionsService]
})
export class TransactionsModule {}