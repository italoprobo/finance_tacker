import { IsString, IsNumber, IsDateString, IsUUID } from 'class-validator';

export class CreateCardDto {
    @IsString()
    name: string;

    @IsNumber()
    limit: number;

    @IsNumber()
    current_balance: number;

    @IsDateString()
    closingDate: Date;

    @IsDateString()
    dueDate: Date;

    @IsUUID()
    userId: string;
}