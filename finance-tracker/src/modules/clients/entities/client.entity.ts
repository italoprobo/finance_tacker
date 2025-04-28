import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn, OneToMany } from "typeorm";
import { User } from "../../user/entities/user.entity";
import { Transaction } from "../../transactions/entities/transaction.entity";

@Entity('clients')
export class Client {
    @PrimaryGeneratedColumn('uuid')
    id: string;

    @Column()
    name: string;

    @Column({ nullable: true })
    email: string;

    @Column({ nullable: true })
    phone: string;

    @Column({ nullable: true })
    address: string;

    @Column({ nullable: true })
    company: string;

    @Column({ nullable: true })
    notes: string;

    @Column({ default: 'ativo' })
    status: string; // ativo, inativo, potencial

    @Column('decimal', { precision: 10, scale: 2, default: 0 })
    monthly_payment: number;

    @Column({ nullable: true })
    payment_day: number; // Dia do mês em que o pagamento é feito

    @Column({ type: 'date', nullable: true })
    contract_start: Date;

    @Column({ type: 'date', nullable: true })
    contract_end: Date;

    @ManyToOne(() => User, (user) => user.clients)
    @JoinColumn({ name: 'user_id' })
    user: User;

    @OneToMany(() => Transaction, (transaction) => transaction.client)
    transactions: Transaction[];

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
    created_at: Date;

    @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP', onUpdate: 'CURRENT_TIMESTAMP' })
    updated_at: Date;
}
