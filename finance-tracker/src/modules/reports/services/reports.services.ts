import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Report } from '../entities/reports.entity';
import { CreateReportDto } from '../dtos/create-report.dto';
import { UpdateReportDto } from '../dtos/update-report.dto';
import { User } from '../../user/entities/user.entity';
import { DataSource } from 'typeorm';
import { differenceInDays, startOfDay, endOfDay, startOfWeek, endOfWeek, startOfMonth, endOfMonth, startOfYear, endOfYear } from 'date-fns';

@Injectable()
export class ReportsService {
    constructor(
        @InjectRepository(Report)
        private readonly reportRepository: Repository<Report>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private readonly dataSource: DataSource
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
        
        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) throw new NotFoundException('Usuário não encontrado');

        const start = new Date(startDate);
        const end = new Date(endDate);
        
        // Buscar transações
        const transactions = await this.dataSource
            .createQueryBuilder()
            .select([
                'transaction.id',
                'transaction.amount',
                'transaction.type',
                'transaction.date',
            ])
            .from('transactions', 'transaction')
            .where('transaction.user_id = :userId', { userId })
            .andWhere('transaction.date >= :startDate', { startDate: start })
            .andWhere('transaction.date <= :endDate', { endDate: end })
            .orderBy('transaction.date', 'ASC')
            .getRawMany();

        // Determinar o tipo de período baseado na diferença de dias
        const diffDays = differenceInDays(end, start);
        const reportMap = new Map<string, any>();

        // Inicializar períodos vazios
        if (diffDays <= 1) {
            // Diário - 24 horas
            for (let hour = 0; hour < 24; hour++) {
                const key = hour.toString();
                reportMap.set(key, this.createEmptyReport(key, 'diario', start, user));
            }
        } else if (diffDays <= 7) {
            // Semanal - 7 dias
            for (let day = 1; day <= 7; day++) {
                const key = day.toString();
                reportMap.set(key, this.createEmptyReport(key, 'diario', start, user));
            }
        } else if (diffDays <= 31) {
            // Mensal - até 31 dias
            const daysInMonth = new Date(start.getFullYear(), start.getMonth() + 1, 0).getDate();
            for (let day = 1; day <= daysInMonth; day++) {
                const key = day.toString();
                reportMap.set(key, this.createEmptyReport(key, 'mensal', start, user));
            }
        } else {
            // Anual - 12 meses
            for (let month = 1; month <= 12; month++) {
                const key = month.toString();
                reportMap.set(key, this.createEmptyReport(key, 'anual', start, user));
            }
        }

        // Processar transações
        for (const transaction of transactions) {
            const date = new Date(transaction.date);
            let key: string;

            if (diffDays <= 1) {
                key = date.getHours().toString();
            } else if (diffDays <= 7) {
                const dayOfWeek = date.getDay();
                key = dayOfWeek === 0 ? '7' : dayOfWeek.toString();
            } else if (diffDays <= 31) {
                key = date.getDate().toString();
            } else {
                key = (date.getMonth() + 1).toString();
            }

            const report = reportMap.get(key);
            if (report) {
                const amount = Number(transaction.amount);
                if (transaction.type.toLowerCase() === 'income' || 
                    transaction.type.toLowerCase() === 'receita') {
                    report.total_income += amount;
                } else {
                    report.total_expense += amount;
                }
            }
        }

        // Converter para array e ordenar
        return Array.from(reportMap.values())
            .sort((a, b) => a.period_start.getTime() - b.period_start.getTime());
    }

    private createEmptyReport(key: string, type: 'diario' | 'mensal' | 'anual', baseDate: Date, user: User): Report {
        const report = new Report();
        report.id = key;
        report.type = type;
        report.total_income = 0;
        report.total_expense = 0;
        report.user = user;

        // Definir period_start e period_end baseado no tipo
        switch (type) {
            case 'diario':
                const hour = parseInt(key);
                report.period_start = new Date(baseDate.setHours(hour, 0, 0, 0));
                report.period_end = new Date(baseDate.setHours(hour, 59, 59, 999));
                break;
            case 'mensal':
                const day = parseInt(key);
                report.period_start = new Date(baseDate.getFullYear(), baseDate.getMonth(), day);
                report.period_end = new Date(baseDate.getFullYear(), baseDate.getMonth(), day, 23, 59, 59, 999);
                break;
            case 'anual':
                const month = parseInt(key) - 1;
                report.period_start = new Date(baseDate.getFullYear(), month, 1);
                report.period_end = new Date(baseDate.getFullYear(), month + 1, 0, 23, 59, 59, 999);
                break;
        }

        return report;
    }
}
