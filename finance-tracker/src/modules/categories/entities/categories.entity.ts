import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { Transaction } from "../../transactions/entities/transaction.entity";

@Entity('categories')
export class Category {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    name: string;

    @Column({ nullable: true })
    description?: string; // opcional 

    @OneToMany(() => Transaction, (transaction) => transaction.category)
    transactions: Transaction[];
}
