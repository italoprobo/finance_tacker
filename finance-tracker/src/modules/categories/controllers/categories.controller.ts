import { Controller, Get, Post, Body, Param, Patch, Delete } from "@nestjs/common";
import { Category } from "../entities/categories.entity";
import { CreateCategoryDto } from "../dtos/create-categories.dto";
import { UpdateCategoryDto } from "../dtos/update-categories.dto";
import { CategoryService } from "../services/caregories.service";

@Controller('categories')
export class CategoriesController {
    constructor(private readonly categoryService: CategoryService) {}

    @Post()
    async create(@Body() createCategoryDto: CreateCategoryDto): Promise<Category> {
        return this.categoryService.create(createCategoryDto);
    }

    @Get()
    async findAll(): Promise<Category[]> {
        return this.categoryService.findAll();
    }

    @Get(':id')
    async findOne(@Param('id') id: string): Promise<Category> {
        return this.categoryService.findOne(id);
    }

    @Patch(':id')
    async update(
        @Param('id') id: string,
        @Body() updateCategoryDto: UpdateCategoryDto,
    ): Promise<Category> {
        return this.categoryService.update(id, updateCategoryDto);
    }

    @Delete(':id')
    async delete(@Param('id') id: string): Promise<void> {
        return this.categoryService.delete(id);
    }
}