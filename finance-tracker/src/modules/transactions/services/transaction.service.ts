import { Injectable} from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { NotFoundException } from "@nestjs/common";
import { Transaction } from "../entities/transaction.entity";
import { CreateTransactionDto } from "../dtos/create-transaction.dto";
import { UpdateTransactionDto } from "../dtos/update-transaction.dto";
import { User } from "src/modules/user/entities/user.entity";
import { Category } from "src/modules/categories/entities/categories.entity";

@Injectable()
export class TransactionsService {
    constructor(
        @InjectRepository(Transaction)
        private readonly transactionRepository: Repository<Transaction>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        @InjectRepository(Category)
        private readonly categoryRepository: Repository<Category>
    ) {}

    async create(createTransactionDto: CreateTransactionDto): Promise<Transaction> {
        console.log('Criando transação com dados:', createTransactionDto);
        const { userId, categoryId, ...data } = createTransactionDto;
        console.log('UserId recebido:', userId);

        const user = await this.userRepository.findOne({ where: { id: userId } });
        console.log('Usuário encontrado:', user);
        if (!user) throw new NotFoundException('Usuário não encontrado');

        const category = await this.categoryRepository.findOne({ where: { id: categoryId } });
        console.log('Categoria encontrada:', category);
        if (!category) throw new NotFoundException('Categoria não encontrada');

        const transaction = this.transactionRepository.create({
            ...data,
            user,
            category,
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
            relations: ['user', 'category'],
            order: { date: 'DESC' }
        });
        console.log('Transações encontradas:', transactions);
        return transactions;
    }

    async findOne(id: string, userId: string): Promise<Transaction> {
        const transaction = await this.transactionRepository.findOne({
            where: { id, user: { id: userId } },
            relations: ['user', 'category'],
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
}