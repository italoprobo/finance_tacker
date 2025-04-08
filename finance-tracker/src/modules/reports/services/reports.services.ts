import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from '../entities/reports.entity';
import { CreateReportDto } from '../dtos/create-report.dto';
import { UpdateReportDto } from '../dtos/update-report.dto';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class ReportsService {
    constructor(
        @InjectRepository(Report)
        private readonly reportRepository: Repository<Report>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>
    ) {}

    async create(createReportDto: CreateReportDto): Promise<Report> {
        const { userId, ...data } = createReportDto;

        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) throw new NotFoundException('Usuário não encontrado');

        const report = this.reportRepository.create({
            ...data,
            user,
        });

        return this.reportRepository.save(report);
    }

    async findAll(): Promise<Report[]> {
        return this.reportRepository.find({ relations: ['user'] });
    }

    async findOne(id: string): Promise<Report> {
        const report = await this.reportRepository.findOne({
            where: { id },
            relations: ['user'],
        });
        if (!report) throw new NotFoundException('Relatório não encontrado');
        return report;
    }

    async update(id: string, updateReportDto: UpdateReportDto): Promise<Report> {
        const report = await this.findOne(id);

        if (updateReportDto.userId) {
            const user = await this.userRepository.findOne({ where: { id: updateReportDto.userId } });
            if (!user) throw new NotFoundException('Usuário não encontrado');
            report.user = user;
        }

        Object.assign(report, updateReportDto);
        return this.reportRepository.save(report);
    }

    async delete(id: string): Promise<void> {
        const result = await this.reportRepository.delete(id);
        if (result.affected === 0) {
            throw new NotFoundException('Relatório não encontrado');
        }
    }

    async getReportsByPeriod(startDate: string, endDate: string, userId: string): Promise<Report[]> {
        if (!userId) throw new NotFoundException('ID do usuário é obrigatório');
        
        // Verificar se o usuário existe
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) throw new NotFoundException('Usuário não encontrado');
        
        // Buscar transações do usuário no período
        const query = this.reportRepository.createQueryBuilder('report')
            .where('report.user_id = :userId', { userId })
            .andWhere('report.period_start >= :startDate', { startDate })
            .andWhere('report.period_end <= :endDate', { endDate })
            .leftJoinAndSelect('report.user', 'user');
        
        const reports = await query.getMany();
        
        // Se não houver relatórios, gerar um relatório vazio para o período
        if (reports.length === 0) {
            const emptyReport = new Report();
            emptyReport.type = 'diario'; // Ou determinar baseado no período
            emptyReport.period_start = new Date(startDate);
            emptyReport.period_end = new Date(endDate);
            emptyReport.total_income = 0;
            emptyReport.total_expense = 0;
            emptyReport.user = user;
            
            // Não salvar no banco, apenas retornar
            return [emptyReport];
        }
        
        return reports;
    }
}
