import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { User } from "../../user/entities/user.entity";
import { Category } from "../../categories/entities/categories.entity";
import { Client } from "../../clients/entities/client.entity";

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

    @ManyToOne(() => User, (user) => user.transactions)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @Column({ type: 'boolean', default: false  })
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
