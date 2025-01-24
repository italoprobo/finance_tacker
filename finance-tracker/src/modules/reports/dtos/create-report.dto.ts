import { IsNotEmpty, IsEnum, IsDate, IsOptional, IsNumber, IsUUID } from 'class-validator';

export class CreateReportDto {
    @IsNotEmpty()
    @IsEnum(['mensal', 'anual', 'diario'])
    type: 'mensal' | 'anual' | 'diario';

    @IsOptional()
    @IsDate()
    period_start?: Date;

    @IsOptional()
    @IsDate()
    period_end?: Date;

    @IsNotEmpty()
    @IsNumber()
    total_income: number;

    @IsNotEmpty()
    @IsNumber()
    total_expense: number;

    @IsOptional()
    details?: any;

    @IsNotEmpty()
    @IsUUID()
    userId: string;
}
