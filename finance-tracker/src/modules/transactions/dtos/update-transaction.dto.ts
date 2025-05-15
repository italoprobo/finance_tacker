import { IsOptional, IsNumber, IsString, IsEnum, IsDateString, IsUUID, IsBoolean } from "class-validator";

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

    @IsOptional()
    @IsUUID()
    clientId?: string;

    @IsOptional()
    @IsBoolean()
    isRecurring?: boolean;

    @IsOptional()
    @IsEnum(['credit', 'debit'])
    paymentMethod?: 'credit' | 'debit';

    @IsOptional()
    @IsUUID()
    cardId?: string;
}
