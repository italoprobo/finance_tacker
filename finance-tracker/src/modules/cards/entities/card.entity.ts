import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from "typeorm";
import { User } from "../../user/entities/user.entity";

@Entity('cards')
export class Card {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column({ type: 'simple-array' }) 
    cardType: string[]; // ["credito"], ["debito"] ou ["credito", "debito"]

    @Column('decimal', { precision: 10, scale: 2 , nullable: true})
    limit: number;

    @Column('decimal', { precision: 10, scale: 2 })
    current_balance: number;

    @Column({ type: 'date' , nullable: true })
    closingDate: Date; 

    @Column({ type: 'date' , nullable: true })
    dueDate: Date; 

    @Column()
    lastDigits: string;

    @ManyToOne(() => User, (user) => user.transactions)
    @JoinColumn({ name: 'user_id' })
    user: User;
}
