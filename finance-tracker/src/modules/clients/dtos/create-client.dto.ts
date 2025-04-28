import { IsNotEmpty, IsEmail, IsOptional, IsNumber, IsDateString, IsUUID } from 'class-validator';

export class CreateClientDto {
    @IsNotEmpty()
    name: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsOptional()
    phone?: string;

    @IsOptional()
    address?: string;

    @IsOptional()
    company?: string;

    @IsOptional()
    notes?: string;

    @IsOptional()
    status?: string;

    @IsOptional()
    @IsNumber()
    monthly_payment?: number;

    @IsOptional()
    @IsNumber()
    payment_day?: number;

    @IsOptional()
    @IsDateString()
    contract_start?: string;

    @IsOptional()
    @IsDateString()
    contract_end?: string;

    @IsUUID()
    userId: string;
}
