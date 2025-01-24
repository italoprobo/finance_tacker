import { Get, Controller, Post, Patch, Delete, Body, Param } from '@nestjs/common';
import { TransactionsService } from '../services/transaction.service';
import { CreateTransactionDto } from '../dtos/create-transaction.dto';
import { UpdateTransactionDto } from '../dtos/update-transaction.dto';
import { Transaction } from '../entities/transaction.entity';

@Controller('transactions')
export class TransactionsController{
    constructor(private readonly transactionService: TransactionsService) {}

    @Post()
    async create(@Body() createTransactionDto: CreateTransactionDto): Promise<Transaction> {
        return this.transactionService.create(createTransactionDto);
    }

    @Get()
    async findAll(): Promise<Transaction[]> {
        return this.transactionService.findAll()
    }

    @Get(':id')
    async findOne(@Param('id') id: string): Promise<Transaction> {
        return this.transactionService.findOne(id);
    }

    @Patch(':id')
    async update(
        @Param('id') id: string,
        @Body() updateTransactionDto: UpdateTransactionDto
    ): Promise<Transaction> {
        return this.transactionService.update(id, updateTransactionDto)
    }

    @Delete(':id')
    async delete(@Param('id') id: string): Promise<void>{
        return this.transactionService.delete(id);
    }
}