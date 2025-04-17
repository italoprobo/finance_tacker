import { Controller, Get, Post, Patch, Delete, Body, Param, Query } from '@nestjs/common';
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

    @Get('by-period')
    async getReportsByPeriod(
        @Query('start_date') startDate: string,
        @Query('end_date') endDate: string,
        @Query('user_id') userId: string
    ): Promise<Report[]> {
        console.log('=== Recebendo requisição em /reports/by-period ===');
        console.log('Parâmetros recebidos:', { startDate, endDate, userId });
        
        try {
            const reports = await this.reportsService.getReportsByPeriod(startDate, endDate, userId);
            console.log('Reports gerados com sucesso:', reports.length);
            return reports;
        } catch (error) {
            console.error('Erro no controller:', error);
            throw error;
        }
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
