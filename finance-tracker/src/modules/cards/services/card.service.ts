import { Injectable, NotFoundException, UnauthorizedException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Card } from "../entities/card.entity";
import { CreateCardDto } from "../dtos/create-card.dto";
import { UpdateCardDto } from "../dtos/update-card.dto";
import { User } from "src/modules/user/entities/user.entity";
import { Transaction } from "src/modules/transactions/entities/transaction.entity";
import { Between } from "typeorm";

@Injectable()
export class CardService {

    constructor(
        @InjectRepository(Card)
        private readonly cardRepository: Repository<Card>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        @InjectRepository(Transaction)
        private readonly transactionRepository: Repository<Transaction>,
    ) {}

    async create(createCardDto: CreateCardDto): Promise<Card> {
        const card = this.cardRepository.create({
            ...createCardDto,
            closingDay: createCardDto.closingDay,
            dueDay: createCardDto.dueDay,
            user: { id: createCardDto.userId }
        });
        return this.cardRepository.save(card);
    }

    async findAll(userId: string): Promise<Card[]> {
        return this.cardRepository.find({ 
            where: { user: { id: userId } },
            relations: ['user']
        });
    }

    async findOne(id: string, userId: string): Promise<Card> {
        const card = await this.cardRepository.findOne({
            where: { id, user: { id: userId } },
            relations: ['user'],
        });
        
        if (!card) {
            throw new NotFoundException('Cartão não encontrado');
        }
        
        return card;
    }

    async update(id: string, updateCardDto: UpdateCardDto): Promise<Card> {
        const card = await this.cardRepository.findOne({ 
            where: { 
                id,
                user: { id: updateCardDto.userId }
            } 
        });

        if (!card) {
            throw new NotFoundException('Cartão não encontrado ou não pertence ao usuário');
        }

        Object.assign(card, {
            ...updateCardDto,
            closingDay: updateCardDto.closingDay,
            dueDay: updateCardDto.dueDay,
            user: { id: updateCardDto.userId }
        });

        return this.cardRepository.save(card);
    }

    async remove(id: string, userId: string): Promise<void> {
        const card = await this.findOne(id, userId);
        
        if (card.user.id !== userId) {
            throw new UnauthorizedException('Você não tem permissão para remover este cartão');
        }

        const result = await this.cardRepository.delete(id);
        if (result.affected === 0) {
            throw new NotFoundException('Cartão não encontrado');
        }
    }

    async getCardBalance(id: string, userId: string): Promise<number> {
        const card = await this.findOne(id, userId);
        
        const transactions = await this.transactionRepository.find({
            where: {
                card: { id },
                user: { id: userId },
                paymentMethod: 'debit'
            }
        });

        let balance = card.salary || 0;
        transactions.forEach(transaction => {
            if (transaction.type === 'entrada') {
                balance += transaction.amount;
            } else {
                balance -= transaction.amount;
            }
        });

        return balance;
    }

    async getCurrentInvoice(id: string, userId: string): Promise<{
        total: number;
        transactions: Transaction[];
        closingDate: Date;
        dueDate: Date;
    }> {
        const card = await this.findOne(id, userId);
        
        const today = new Date();
        const currentMonth = today.getMonth();
        const currentYear = today.getFullYear();
        
        const closingDate = new Date(currentYear, currentMonth, card.closingDay);
        const dueDate = new Date(currentYear, currentMonth, card.dueDay);
        
        if (today.getDate() > card.closingDay) {
            closingDate.setMonth(closingDate.getMonth() + 1);
            dueDate.setMonth(dueDate.getMonth() + 1);
        }

        const transactions = await this.transactionRepository.find({
            where: {
                card: { id },
                user: { id: userId },
                paymentMethod: 'credit',
                date: Between(
                    new Date(closingDate.getFullYear(), closingDate.getMonth() - 1, card.closingDay + 1),
                    closingDate
                )
            },
            order: { date: 'DESC' }
        });

        const total = transactions.reduce((sum, trans) => sum + trans.amount, 0);

        return {
            total,
            transactions,
            closingDate,
            dueDate
        };
    }

    async linkTransaction(
        cardId: string, 
        transactionId: string, 
        userId: string
    ): Promise<Card> {
        const card = await this.findOne(cardId, userId);
        const transaction = await this.transactionRepository.findOne({
            where: { id: transactionId, user: { id: userId } }
        });

        if (!transaction) {
            throw new NotFoundException('Transação não encontrada');
        }

        transaction.card = card;
        await this.transactionRepository.save(transaction);

        return card;
    }
}