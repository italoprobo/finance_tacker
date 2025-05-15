import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { User } from "../../user/entities/user.entity";
import { Category } from "../../categories/entities/categories.entity";
import { Client } from "../../clients/entities/client.entity";
import { Card } from "../../cards/entities/card.entity";

@Entity('transactions')
export class Transaction {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    description: string;

    @Column('decimal', { precision: 10, scale: 2 })
    amount: number;

    @Column({ type: 'enum', enum: ['entrada', 'saida'] })
    type: 'entrada' | 'saida';

    @Column({ type: 'timestamp' })
    date: Date;

    @Column({ type: 'enum', enum: ['credit', 'debit'], nullable: true })
    paymentMethod: 'credit' | 'debit' | null;

    @ManyToOne(() => Card, card => card.transactions, { nullable: true })
    @JoinColumn({ name: 'card_id' })
    card: Card;

    @Column({ nullable: true })
    card_id: string;

    @ManyToOne(() => User, (user) => user.transactions)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @Column({ type: 'boolean', default: false })
    isRecurring: boolean;

    @ManyToOne(() => Category, (category) => category.transactions)
    @JoinColumn({ name: 'category_id' })
    category: Category;

    @ManyToOne(() => Client, (client) => client.transactions, { nullable: true })
    @JoinColumn({ name: 'client_id' })
    client: Client;

    @Column({ nullable: true })
    client_id: string;
}
