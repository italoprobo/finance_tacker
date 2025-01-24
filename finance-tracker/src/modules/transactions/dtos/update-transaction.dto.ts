import { IsOptional, IsNumber, IsString, IsEnum, IsDateString, IsUUID } from "class-validator";

export class UpdateTransactionDto {
    @IsOptional()
    @IsString()
    description?: string;

    @IsOptional()
    @IsNumber()
    amount?: number;

    @IsOptional()
    @IsEnum(['entrada', 'saida'])
    type?: 'entrada' | 'saida';

    @IsOptional()
    @IsDateString()
    date?: Date;

    @IsOptional()
    @IsUUID()
    userId?: string;

    @IsOptional()
    @IsUUID()
    categoryId?: string;
}
