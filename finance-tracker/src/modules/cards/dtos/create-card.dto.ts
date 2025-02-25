import { IsString, IsNumber, IsDateString, IsUUID, IsOptional, IsArray, ArrayNotEmpty, ArrayUnique, IsIn } from 'class-validator';

export class CreateCardDto {
    @IsString()
    name: string;

    @IsArray()
    @ArrayNotEmpty()
    @ArrayUnique()
    @IsIn(['credito', 'debito'], { each: true }) 
    cardType: string[]; // ["credito"], ["debito"], ou ambos ["credito", "debito"]

    @IsOptional()
    @IsNumber()
    limit?: number; // Opcional para cartões que não são de crédito

    @IsNumber()
    current_balance: number;

    @IsOptional()
    @IsDateString()
    closingDate?: Date; 

    @IsOptional()
    @IsDateString()
    dueDate?: Date;

    @IsString()
    lastDigits: string;

    @IsUUID()
    userId: string;
}
