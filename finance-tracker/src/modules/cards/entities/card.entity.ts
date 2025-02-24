import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { User } from "../../user/entities/user.entity";

@Entity('cards')
export class Card {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column('decimal', { precision: 10, scale: 2 })
    limit: number;

    @Column('decimal', { precision: 10, scale: 2 })
    current_balance: number;

    @Column({ type: 'date' })
    closingDate: Date; 

    @Column({ type: 'date' })
    dueDate: Date; 

    @Column()
    lastDigits: string;

    @ManyToOne(() => User, (user) => user.transactions)
    @JoinColumn({ name: 'user_id' })
    user: User;
}