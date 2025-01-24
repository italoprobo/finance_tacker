import { IsNotEmpty, IsNumber, IsString, IsEnum, IsDateString, IsUUID } from "class-validator";

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

    @IsNotEmpty()
    @IsUUID()
    userId: string;

    @IsNotEmpty()
    @IsUUID()
    categoryId: string;
}
