import { IsNotEmpty, IsNumber, IsString, IsEnum, IsDateString, IsUUID, IsOptional, IsBoolean } from "class-validator";

export class CreateTransactionDto {
    @IsNotEmpty()
    @IsString()
    description: string;

    @IsNotEmpty()
    @IsNumber()
    amount: number;

    @IsNotEmpty()
    @IsEnum(['entrada', 'saida'])
    type: 'entrada' | 'saida';

    @IsNotEmpty()
    @IsDateString()
    date: Date;

    @IsOptional()
    @IsEnum(['credit', 'debit'])
    paymentMethod?: 'credit' | 'debit';

    @IsOptional()
    @IsUUID()
    cardId?: string;

    @IsNotEmpty()
    @IsUUID()
    userId: string;

    @IsNotEmpty()
    @IsUUID()
    categoryId: string;

    @IsOptional()
    @IsUUID()
    clientId?: string;

    @IsOptional() 
    @IsBoolean()
    isRecurring?: boolean = false;  // padrão
}
