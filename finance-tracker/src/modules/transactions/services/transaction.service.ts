import { Injectable, NotFoundException, BadRequestException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Transaction } from "../entities/transaction.entity";
import { CreateTransactionDto } from "../dtos/create-transaction.dto";
import { UpdateTransactionDto } from "../dtos/update-transaction.dto";
import { User } from "src/modules/user/entities/user.entity";
import { Category } from "src/modules/categories/entities/categories.entity";
import { Between } from "typeorm";
import { Client } from "src/modules/clients/entities/client.entity";

@Injectable()
export class TransactionsService {
    constructor(
        @InjectRepository(Transaction)
        private readonly transactionRepository: Repository<Transaction>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        @InjectRepository(Category)
        private readonly categoryRepository: Repository<Category>,
        @InjectRepository(Client)
        private readonly clientRepository: Repository<Client>
    ) {}

    async create(createTransactionDto: CreateTransactionDto): Promise<Transaction> {
        console.log('Criando transação com dados:', createTransactionDto);
        const { userId, categoryId, clientId, isRecurring, ...data } = createTransactionDto;
        console.log('UserId recebido:', userId);

        const user = await this.userRepository.findOne({ where: { id: userId } });
        console.log('Usuário encontrado:', user);
        if (!user) throw new NotFoundException('Usuário não encontrado');

        const category = await this.categoryRepository.findOne({ where: { id: categoryId } });
        console.log('Categoria encontrada:', category);
        if (!category) throw new NotFoundException('Categoria não encontrada');

        let client = null;
        if (clientId) {
            client = await this.clientRepository.findOne({ where: { id: clientId } });
            if (!client) throw new NotFoundException('Cliente não encontrado');

            // Validação do valor para transações recorrentes
            if (isRecurring && client.monthly_payment) {
                const monthlyPayment = parseFloat(client.monthly_payment.toString());
                const transactionAmount = parseFloat(data.amount.toString());

                if (transactionAmount !== monthlyPayment) {
                    throw new BadRequestException(
                        `O valor da transação recorrente (${transactionAmount}) deve ser igual ao pagamento mensal do cliente (${monthlyPayment})`
                    );
                }
            }
        }

        const transaction = this.transactionRepository.create({
            ...data,
            user,
            category,
            client,
            client_id: clientId,
            isRecurring
        });
        console.log('Transação criada:', transaction);

        const savedTransaction = await this.transactionRepository.save(transaction);
        console.log('Transação salva:', savedTransaction);
        return savedTransaction;
    }

    async findAll(userId: string): Promise<Transaction[]> {
        console.log('Buscando transações para o usuário:', userId);
        const transactions = await this.transactionRepository.find({ 
            where: { 
                user: { 
                    id: userId 
                } 
            },
            relations: ['user', 'category', 'client'],
            order: { date: 'DESC' }
        });
        console.log('Transações encontradas:', transactions);
        return transactions;
    }

    async findOne(id: string, userId: string): Promise<Transaction> {
        const transaction = await this.transactionRepository.findOne({
            where: { id, user: { id: userId } },
            relations: ['user', 'category', 'client'],
        });
        if (!transaction) throw new NotFoundException('Transação não encontrada');
        return transaction;
    }

    async update(id: string, userId: string, updateTransactionDto: UpdateTransactionDto): Promise<Transaction> {
        const transaction = await this.findOne(id, userId);
        Object.assign(transaction, updateTransactionDto);
        return this.transactionRepository.save(transaction);
    }

    async delete(id: string, userId: string): Promise<void> {
        const transaction = await this.findOne(id, userId);
        await this.transactionRepository.remove(transaction);
    }

    async findClientMonthlyPayment(
        userId: string,
        clientId: string,
        month: number,
        year: number
    ): Promise<Transaction | null> {
        // Criar datas de início e fim do mês
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0);
        
        const transaction = await this.transactionRepository.findOne({
            where: {
                user: { id: userId },
                client: { id: clientId },
                type: 'entrada',
                date: Between(startDate, endDate),
            },
        });
        
        return transaction;
    }

    async findByClient(userId: string, clientId: string): Promise<Transaction[]> {
        const client = await this.clientRepository.findOne({ 
            where: { 
                id: clientId,
                user: { id: userId }
            }
        });
        
        if (!client) {
            throw new NotFoundException('Cliente não encontrado');
        }

        const transactions = await this.transactionRepository.find({
            where: {
                user: { id: userId },
                client: { id: clientId }
            },
            relations: ['user', 'category', 'client'],
            order: { date: 'DESC' }
        });

        return transactions;
    }
}