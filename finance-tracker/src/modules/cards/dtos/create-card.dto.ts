import { IsString, IsNumber, IsUUID, IsOptional, IsArray, ArrayNotEmpty, ArrayUnique, IsIn, Min, Max } from 'class-validator';

export class CreateCardDto {
    @IsString()
    name: string;

    @IsArray()
    @ArrayNotEmpty()
    @ArrayUnique()
    @IsIn(['credito', 'debito'], { each: true }) 
    cardType: string[];

    @IsOptional()
    @IsNumber()
    limit?: number; 

    @IsNumber()
    current_balance: number;

    @IsOptional()
    @IsNumber()
    @Min(1)
    @Max(31)
    closingDay?: number; 

    @IsOptional()
    @IsNumber()
    @Min(1)
    @Max(31)
    dueDay?: number; 

    @IsString()
    lastDigits: string;

    @IsUUID()
    userId: string;
}
