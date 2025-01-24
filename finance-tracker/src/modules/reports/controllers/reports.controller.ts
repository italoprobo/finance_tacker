import { Controller, Get, Post, Patch, Delete, Body, Param } from '@nestjs/common';
import { Report } from '../entities/reports.entity';
import { ReportsService } from '../services/reports.services';
import { CreateReportDto } from '../dtos/create-report.dto';
import { UpdateReportDto } from '../dtos/update-report.dto';


@Controller('reports')
export class ReportsController {
    constructor(private readonly reportsService: ReportsService) {}

    @Post()
    async create(@Body() createReportDto: CreateReportDto): Promise<Report> {
        return this.reportsService.create(createReportDto);
    }

    @Get()
    async findAll(): Promise<Report[]> {
        return this.reportsService.findAll();
    }

    @Get(':id')
    async findOne(@Param('id') id: string): Promise<Report> {
        return this.reportsService.findOne(id);
    }

    @Patch(':id')
    async update(
        @Param('id') id: string,
        @Body() updateReportDto: UpdateReportDto
    ): Promise<Report> {
        return this.reportsService.update(id, updateReportDto);
    }

    @Delete(':id')
    async delete(@Param('id') id: string): Promise<void> {
        return this.reportsService.delete(id);
    }
}
