import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../user/entities/user.entity';

@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  type: 'mensal' | 'anual' | 'diario';

  @Column({ type: 'date', nullable: true })
  period_start: Date;

  @Column({ type: 'date', nullable: true })
  period_end: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  total_income: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total_expense: number;

  @Column({ type: 'jsonb', nullable: true })
  details: any; // Pode armazenar detalhes como categorias ou transações.

  @ManyToOne(() => User, (user) => user.transactions)
  @JoinColumn({ name: 'user_id' })
  user: User;
}