import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CardService } from "./services/card.service";
import { CardController } from "./controllers/card.controller";
import { Card } from "./entities/card.entity";
import { User } from "../user/entities/user.entity";
import { AuthModule } from "../auth/auth.module";

@Module({
    imports: [
        TypeOrmModule.forFeature([Card, User]),
        AuthModule,
    ],
    controllers: [CardController],
    providers: [CardService],
})
export class CardModule {}