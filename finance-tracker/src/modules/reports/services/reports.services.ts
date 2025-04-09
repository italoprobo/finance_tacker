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
        try {
            console.log('=== Iniciando getReportsByPeriod ===');
            console.log('Parâmetros:', { startDate, endDate, userId });

            if (!userId) throw new NotFoundException('ID do usuário é obrigatório');
            
            const user = await this.userRepository.findOne({ where: { id: userId } });
            console.log('Usuário encontrado:', user?.id);
            
            if (!user) throw new NotFoundException('Usuário não encontrado');

            const start = new Date(startDate);
            const end = new Date(endDate);
            
            // Corrigindo a query para incluir o filtro de data
            const transactions = await this.dataSource
                .createQueryBuilder()
                .select([
                    'transaction.id',
                    'transaction.amount',
                    'transaction.type',
                    'transaction.date',
                    'transaction.user_id'
                ])
                .from('transactions', 'transaction')
                .where('transaction.user_id = :userId', { userId })
                .andWhere('transaction.date >= :startDate', { startDate: start })
                .andWhere('transaction.date <= :endDate', { endDate: end })
                .orderBy('transaction.date', 'ASC')
                .getRawMany();

            console.log('Datas da busca:', {
                start: start.toISOString(),
                end: end.toISOString()
            });
            console.log('Transações encontradas:', transactions.length);
            console.log('Exemplo de transação:', transactions[0]);
            
            return this.processTransactions(transactions, start, end, userId);
        } catch (error) {
            console.error('Erro detalhado em getReportsByPeriod:', error);
            throw error;
        }
    }

    private processTransactions(transactions: any[], startDate: Date, endDate: Date, userId: string): Report[] {
        const reportMap = new Map<string, Report>();

        transactions.forEach(transaction => {
            try {
                // Corrigindo a forma de obter a data
                const transactionDate = new Date(transaction.transaction_date);
                
                // Formatando a chave manualmente sem usar toISOString
                const key = `${transactionDate.getFullYear()}-${String(transactionDate.getMonth() + 1).padStart(2, '0')}-${String(transactionDate.getDate()).padStart(2, '0')}`;

                if (!reportMap.has(key)) {
                    const report = new Report();
                    report.id = key;
                    report.type = 'diario';
                    report.period_start = transactionDate;
                    // Criando uma nova data para o final do dia
                    report.period_end = new Date(
                        transactionDate.getFullYear(),
                        transactionDate.getMonth(),
                        transactionDate.getDate(),
                        23, 59, 59, 999
                    );
                    report.total_income = 0;
                    report.total_expense = 0;
                    report.user = { id: userId } as User;
                    reportMap.set(key, report);
                }

                const report = reportMap.get(key)!;
                // Usando o campo correto da transação (transaction_amount em vez de amount)
                const amount = Math.abs(Number(transaction.transaction_amount));

                // Usando o campo correto da transação (transaction_type em vez de type)
                if (transaction.transaction_type.toLowerCase() === 'entrada') {
                    report.total_income += amount;
                } else if (transaction.transaction_type.toLowerCase() === 'saida') {
                    report.total_expense += amount;
                }
            } catch (e) {
                console.error('Erro ao processar transação:', e, 'Transação:', transaction);
            }
        });

        const reports = Array.from(reportMap.values());
        
        // Ordenando por data
        reports.sort((a, b) => {
            if (!a.period_start || !b.period_start) return 0;
            return a.period_start.getTime() - b.period_start.getTime();
        });

        return reports;
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
