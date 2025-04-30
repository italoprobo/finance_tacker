import { Get, Controller, Post, Patch, Delete, Body, Param, UseGuards, Request, UnauthorizedException } from '@nestjs/common';
import { TransactionsService } from '../services/transaction.service';
import { CreateTransactionDto } from '../dtos/create-transaction.dto';
import { UpdateTransactionDto } from '../dtos/update-transaction.dto';
import { Transaction } from '../entities/transaction.entity';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@Controller('transactions')
@UseGuards(JwtAuthGuard)
export class TransactionsController {
    constructor(private readonly transactionService: TransactionsService) {}

    @Post()
    async create(@Request() req, @Body() createTransactionDto: CreateTransactionDto): Promise<Transaction> {
        console.log('Criando transação para o usuário:', createTransactionDto.userId);
        console.log('Token recebido:', req.headers.authorization);
        return this.transactionService.create(createTransactionDto);
    }

    @Get()
    async findAll(@Request() req): Promise<Transaction[]> {
        console.log('Buscando transações para o usuário:', req.user?.id);
        if (!req.user?.id) {
            throw new UnauthorizedException('Usuário não autenticado');
        }
        return this.transactionService.findAll(req.user.id);
    }

    @Get(':id')
    async findOne(@Request() req, @Param('id') id: string): Promise<Transaction> {
        return this.transactionService.findOne(id, req.user.id);
    }

    @Patch(':id')
    async update(
        @Request() req,
        @Param('id') id: string,
        @Body() updateTransactionDto: UpdateTransactionDto
    ): Promise<Transaction> {
        return this.transactionService.update(id, req.user.id, updateTransactionDto);
    }

    @Delete(':id')
    async delete(@Request() req, @Param('id') id: string): Promise<void> {
        return this.transactionService.delete(id, req.user.id);
    }

    @Get('by-client/:clientId')
    async findByClient(
        @Request() req,
        @Param('clientId') clientId: string
    ): Promise<Transaction[]> {
        return this.transactionService.findByClient(req.user.id, clientId);
    }
}