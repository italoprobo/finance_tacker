import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../user/entities/user.entity';

@Entity('reports')
export class Report {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar'})
  type: string;

  @Column({ type: 'timestamp', nullable: true })
  period_start: Date;

  @Column({ type: 'timestamp', nullable: true })
  period_end: Date;

  @Column('decimal', { precision: 10, scale: 2 })
  total_income: number;

  @Column('decimal', { precision: 10, scale: 2 })
  total_expense: number;

  @Column({ type: 'jsonb', nullable: true, default: {} })
  details: Record<string,any>; 

  @ManyToOne(() => User)
  @JoinColumn({ name: 'user_id' })
  user: User;
}