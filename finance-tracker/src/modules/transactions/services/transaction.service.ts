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
        const { userId, categoryId, ...data } = createTransactionDto;

        const user = await this.userRepository.findOne({ where: { id: userId } });
        if (!user) throw new NotFoundException('Usuário não encontrado');

        const category = await this.categoryRepository.findOne({ where: { id: categoryId } });
        if (!category) throw new NotFoundException('Categoria não encontrada');

        const transaction = this.transactionRepository.create({
            ...data,
            user,
            category,
        });

        return this.transactionRepository.save(transaction);
    }

    async findAll(): Promise<Transaction[]> {
        return this.transactionRepository.find({ relations: ['user', 'category'] });
    }

    async findOne(id: string): Promise<Transaction> {
        const transaction = await this.transactionRepository.findOne({
            where: { id },
            relations: ['user', 'category'],
        });
        if (!transaction) throw new NotFoundException('Transação não encontrada');
        return transaction;
    }

    async update(id: string, updateTransactionDto: UpdateTransactionDto): Promise<Transaction> {
        const transaction = await this.findOne(id);
        const { userId, categoryId, ...data } = updateTransactionDto;

        if (userId) {
            const user = await this.userRepository.findOne({ where: { id: userId } });
            if (!user) throw new NotFoundException('Usuário não encontrado');
            transaction.user = user;
        }

        if (categoryId) {
            const category = await this.categoryRepository.findOne({ where: { id: categoryId } });
            if (!category) throw new NotFoundException('Categoria não encontrada');
            transaction.category = category;
        }

        Object.assign(transaction, data);
        return this.transactionRepository.save(transaction);
    }

    async delete(id: string): Promise<void> {
        const result = await this.transactionRepository.delete(id);
        if (result.affected === 0) {
            throw new NotFoundException('Transação não encontrada');
        }
    }
}