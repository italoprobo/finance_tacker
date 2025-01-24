import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CardService } from "./services/card.service";
import { CardController } from "./controllers/card.controller";
import { Card } from "./entities/card.entity";
import { User } from "../user/entities/user.entity";

@Module({
    imports: [TypeOrmModule.forFeature([Card, User])],
    controllers: [CardController],
    providers: [CardService],
})
export class CardModule {}