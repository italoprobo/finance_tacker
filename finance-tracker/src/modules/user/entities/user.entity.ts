import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from "typeorm";
import { Transaction } from "../../transactions/entities/transaction.entity";
import { Report } from "../../reports/entities/reports.entity";
import { Client } from "src/modules/clients/entities/client.entity";

@Entity('users')
export class User{

    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column({ unique: true })
    email: string;

    @Column()
    name: string;

    @Column()
    password: string;

    @Column({ nullable: true })
    profileImage: string;

    @OneToMany(() => Transaction, (transaction) => transaction.user)
    transactions: Transaction[];

    @OneToMany(() => Report, (report) => report.user)
    reports: Report[];

    @OneToMany(() => Client, (client) => client.user)
    clients: Client[];
}