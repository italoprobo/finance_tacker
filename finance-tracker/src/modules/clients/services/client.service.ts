import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Client } from '../entities/client.entity';
import { User } from '../../user/entities/user.entity';
import { CreateClientDto } from '../dtos/create-client.dto';
import { UpdateClientDto } from '../dtos/update-client.dto';
import { TransactionsService } from '../../transactions/services/transaction.service';
import { Category } from '../../categories/entities/categories.entity';

@Injectable()
export class ClientService {
    constructor(
        @InjectRepository(Client)
        private readonly clientRepository: Repository<Client>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        @InjectRepository(Category)
        private readonly categoryRepository: Repository<Category>,
        private readonly transactionService: TransactionsService,
    ) {}

    async create(createClientDto: CreateClientDto): Promise<Client> {
        const user = await this.userRepository.findOneBy({ id: createClientDto.userId });
        if (!user) {
            throw new NotFoundException('Usuário não encontrado');
        }

        const client = this.clientRepository.create({
            ...createClientDto,
            user,
        });

        return this.clientRepository.save(client);
    }

    async findAll(userId: string): Promise<Client[]> {
        return this.clientRepository.find({ 
            where: { user: { id: userId } },
            order: { name: 'ASC' } 
        });
    }

    async findOne(id: string): Promise<Client> {
        const client = await this.clientRepository.findOne({
            where: { id },
            relations: ['transactions', 'user'],
        });

        if (!client) {
            throw new NotFoundException('Cliente não encontrado');
        }

        return client;
    }

    async update(id: string, updateClientDto: UpdateClientDto): Promise<Client> {
        const client = await this.clientRepository.preload({
            id,
            ...updateClientDto,
        });

        if (!client) {
            throw new NotFoundException('Cliente não encontrado');
        }

        return this.clientRepository.save(client);
    }

    async remove(id: string): Promise<void> {
        const result = await this.clientRepository.delete(id);
        if (result.affected === 0) {
            throw new NotFoundException('Cliente não encontrado');
        }
    }

    async generateMonthlyPayment(clientId: string, month: number, year: number): Promise<void> {
        const client = await this.findOne(clientId);
        
        if (!client.monthly_payment || client.monthly_payment <= 0) {
            return; 
        }
        
        if (client.status !== 'ativo') {
            return;
        }

        const existingTransaction = await this.transactionService.findClientMonthlyPayment(
            client.user.id,
            clientId,
            month,
            year
        );

        if (existingTransaction) {
            return; // Se já existe, não cria outra
        }

        // Determina a data do pagamento
        const paymentDay = client.payment_day || 1; // Dia padrão é 1 se não definido
        const paymentDate = new Date(year, month - 1, paymentDay);

        // Buscar ou criar uma categoria para pagamentos de clientes
        const category = await this.findOrCreateClientCategory(client.user.id);

        // Cria uma transação de entrada
        await this.transactionService.create({
            userId: client.user.id,
            amount: client.monthly_payment,
            type: 'entrada',
            date: paymentDate,
            description: `Pagamento mensal - ${client.name}`,
            categoryId: category.id,
            isRecurring: true,
            clientId: client.id
        });
    }

    async generateAllMonthlyPayments(userId: string, month: number, year: number): Promise<void> {
        const clients = await this.findAll(userId);
        
        for (const client of clients) {
            if (client.status === 'ativo' && client.monthly_payment > 0) {
                await this.generateMonthlyPayment(client.id, month, year);
            }
        }
    }

    // Método para encontrar ou criar uma categoria para pagamentos de clientes
    private async findOrCreateClientCategory(userId: string): Promise<Category> {
        const categoryName = 'Honorários de Clientes';
        
        // Buscar se já existe uma categoria com este nome para o usuário
        const categories = await this.categoryRepository.find({
            where: { name: categoryName },
            relations: ['transactions']
        });
        
        // Como não temos a relação com usuário na entidade Category, vamos buscar todas as transações
        // e filtrar pelo userId depois
        const transactions = await this.transactionService.findAll(userId);
        const userCategoryIds = transactions
            .map(t => t.category?.id)
            .filter(id => id !== undefined);
        
        // Procurar entre as categorias encontradas se alguma já está sendo usada pelo usuário
        const category = categories.find(cat => userCategoryIds.includes(cat.id));
        
        if (category) {
            return category;
        }

        // Se não encontrou, criar uma nova categoria
        const newCategory = this.categoryRepository.create({
            name: categoryName,
            description: 'Pagamentos recebidos de clientes'
        });

        return this.categoryRepository.save(newCategory);
    }
}
