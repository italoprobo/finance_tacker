import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { User } from "../../user/entities/user.entity";
import { Transaction } from "../../transactions/entities/transaction.entity";

@Entity('cards')
export class Card {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column({ type: 'simple-array' }) 
    cardType: string[]; // ["credito"], ["debito"] ou ["credito", "debito"]

    @Column('decimal', { precision: 10, scale: 2, nullable: true })
    limit: number;

    @Column('decimal', { precision: 10, scale: 2 })
    current_balance: number;

    @Column('decimal', { precision: 10, scale: 2, nullable: true })
    salary: number;

    @Column({ type: 'int', nullable: true })
    closingDay: number;

    @Column({ type: 'int', nullable: true })
    dueDay: number;

    @Column()
    lastDigits: string;

    @OneToMany(() => Transaction, transaction => transaction.card)
    transactions: Transaction[];

    @Column('jsonb', { nullable: true })
    invoiceTransactions: {
        month: number;
        year: number;
        transactions: string[];
    }[];

    @ManyToOne(() => User)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @Column({ name: 'user_id' })
    userId: string;
}
