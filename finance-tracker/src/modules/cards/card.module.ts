import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CardService } from "./services/card.service";
import { CardController } from "./controllers/card.controller";
import { Card } from "./entities/card.entity";
import { User } from "../user/entities/user.entity";
import { AuthModule } from "../auth/auth.module";
import { Transaction } from "../transactions/entities/transaction.entity";

@Module({
    imports: [
        TypeOrmModule.forFeature([Card, User, Transaction]),
        AuthModule,
    ],
    controllers: [CardController],
    providers: [CardService],
    exports: [CardService],
})
export class CardModule {}