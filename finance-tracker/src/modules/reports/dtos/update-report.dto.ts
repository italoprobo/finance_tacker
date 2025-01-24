import { IsOptional, IsEnum, IsDate, IsNumber, IsUUID } from 'class-validator';

export class UpdateReportDto {
    @IsOptional()
    @IsEnum(['mensal', 'anual', 'diario'])
    type?: 'mensal' | 'anual' | 'diario';

    @IsOptional()
    @IsDate()
    period_start?: Date;

    @IsOptional()
    @IsDate()
    period_end?: Date;

    @IsOptional()
    @IsNumber()
    total_income?: number;

    @IsOptional()
    @IsNumber()
    total_expense?: number;

    @IsOptional()
    details?: any;

    @IsOptional()
    @IsUUID()
    userId?: string;
}
