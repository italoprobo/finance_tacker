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
import { Card } from "src/modules/cards/entities/card.entity";
import { CardService } from "src/modules/cards/services/card.service";

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
        private readonly clientRepository: Repository<Client>,
        @InjectRepository(Card)
        private readonly cardRepository: Repository<Card>,
        private readonly cardService: CardService
    ) {}

    private async updateCardBalance(card: Card, transaction: Transaction): Promise<void> {
        if (!card || !transaction.paymentMethod) return;

        if (transaction.paymentMethod === 'debit') {
            // Atualiza o saldo do cartão de débito
            const amount = transaction.type === 'entrada' 
                ? transaction.amount 
                : -transaction.amount;
            
            card.current_balance = Number(card.current_balance) + amount;
            await this.cardRepository.save(card);
        } else if (transaction.paymentMethod === 'credit') {
            // Atualiza o saldo do cartão de crédito (fatura)
            if (transaction.type === 'saida') {
                card.current_balance = Number(card.current_balance) + transaction.amount;
                await this.cardRepository.save(card);
            }
        }
    }

    async create(createTransactionDto: CreateTransactionDto): Promise<Transaction> {
        console.log('Criando transação com dados:', createTransactionDto);
        const { userId, categoryId, clientId, cardId, paymentMethod, isRecurring, ...data } = createTransactionDto;
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

        let card = null;
        if (cardId) {
            card = await this.cardRepository.findOne({ 
                where: { id: cardId, user: { id: userId } }
            });
            if (!card) throw new NotFoundException('Cartão não encontrado');

            // Validações adicionais para cartões
            if (paymentMethod === 'credit') {
                // Verifica se o cartão aceita crédito
                if (!card.cardType.includes('credito')) {
                    throw new BadRequestException('Este cartão não aceita transações de crédito');
                }

                // Verifica limite disponível
                const currentInvoice = await this.cardService.getCurrentInvoice(cardId, userId);
                if (currentInvoice.total + data.amount > card.limit) {
                    throw new BadRequestException('Limite do cartão excedido');
                }
            } else if (paymentMethod === 'debit') {
                // Verifica se o cartão aceita débito
                if (!card.cardType.includes('debito')) {
                    throw new BadRequestException('Este cartão não aceita transações de débito');
                }

                // Verifica saldo disponível para débito
                const balance = await this.cardService.getCardBalance(cardId, userId);
                if (data.type === 'saida' && data.amount > balance) {
                    throw new BadRequestException('Saldo insuficiente');
                }
            }
        }

        const transaction = this.transactionRepository.create({
            ...data,
            user,
            category,
            client,
            card,
            paymentMethod,
            isRecurring
        });
        console.log('Transação criada:', transaction);

        const savedTransaction = await this.transactionRepository.save(transaction);
        console.log('Transação salva:', savedTransaction);
        
        // Atualiza o saldo do cartão após salvar a transação
        if (card) {
            await this.updateCardBalance(card, savedTransaction);
        }

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
            relations: ['user', 'category', 'client', 'card'],
            order: { date: 'DESC' }
        });
        console.log('Transações encontradas:', transactions);
        return transactions;
    }

    async findOne(id: string, userId: string): Promise<Transaction> {
        const transaction = await this.transactionRepository.findOne({
            where: { id, user: { id: userId } },
            relations: ['user', 'category', 'client', 'card'],
        });
        if (!transaction) throw new NotFoundException('Transação não encontrada');
        return transaction;
    }

    async update(id: string, userId: string, updateTransactionDto: UpdateTransactionDto): Promise<Transaction> {
        const oldTransaction = await this.findOne(id, userId);
        const oldCard = oldTransaction.card;

        // Se tinha cartão antes, desfaz a transação antiga
        if (oldCard) {
            const reversedTransaction: Transaction = {
                ...oldTransaction,
                type: oldTransaction.type === 'entrada' ? 'saida' : 'entrada' as 'entrada' | 'saida'
            };
            await this.updateCardBalance(oldCard, reversedTransaction);
        }

        // Atualiza a transação
        Object.assign(oldTransaction, updateTransactionDto);
        const updatedTransaction = await this.transactionRepository.save(oldTransaction);

        // Se tem cartão novo, aplica a nova transação
        if (updatedTransaction.card) {
            await this.updateCardBalance(updatedTransaction.card, updatedTransaction);
        }

        return updatedTransaction;
    }

    async delete(id: string, userId: string): Promise<void> {
        const transaction = await this.findOne(id, userId);
        
        // Se a transação estava vinculada a um cartão, atualiza o saldo
        if (transaction.card) {
            // Inverte o tipo da transação para desfazer o efeito no saldo
            const reversedTransaction: Transaction = {
                ...transaction,
                type: transaction.type === 'entrada' ? 'saida' : 'entrada' as 'entrada' | 'saida'
            };
            await this.updateCardBalance(transaction.card, reversedTransaction);
        }

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

    async findByCard(userId: string, cardId: string): Promise<Transaction[]> {
        const card = await this.cardRepository.findOne({ 
            where: { 
                id: cardId,
                user: { id: userId }
            }
        });
        
        if (!card) {
            throw new NotFoundException('Cartão não encontrado');
        }

        const transactions = await this.transactionRepository.find({
            where: {
                user: { id: userId },
                card: { id: cardId }
            },
            relations: ['user', 'category', 'client', 'card'],
            order: { date: 'DESC' }
        });

        return transactions;
    }
}