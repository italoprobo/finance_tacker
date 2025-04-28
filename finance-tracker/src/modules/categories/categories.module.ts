import { Module } from "@nestjs/common";
import { TypeOrmModule } from "@nestjs/typeorm";
import { CategoriesController } from "./controllers/categories.controller";
import { CategoryService } from "./services/caregories.service";
import { Category } from "./entities/categories.entity";

@Module({
    imports: [TypeOrmModule.forFeature([Category])],
    controllers: [CategoriesController],
    providers: [CategoryService],
    exports: [TypeOrmModule.forFeature([Category]), CategoryService],
})

export class CategoriesModule {}

