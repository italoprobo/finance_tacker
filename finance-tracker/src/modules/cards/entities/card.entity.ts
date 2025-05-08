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

    @Column({ type: 'int', nullable: true })
    closingDay: number; 

    @Column({ type: 'int', nullable: true })
    dueDay: number; 

    @Column()
    lastDigits: string;

    @ManyToOne(() => User)
    @JoinColumn({ name: 'user_id' })
    user: User;
}
