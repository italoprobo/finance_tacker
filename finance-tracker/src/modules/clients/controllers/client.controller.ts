import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from '@nestjs/common';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { ClientService } from '../services/client.service';
import { CreateClientDto } from '../dtos/create-client.dto';
import { UpdateClientDto } from '../dtos/update-client.dto';

@Controller('clients')
@UseGuards(JwtAuthGuard)
export class ClientController {
    constructor(private readonly clientService: ClientService) {}

    @Post()
    create(@Body() createClientDto: CreateClientDto, @Request() req) {
        createClientDto.userId = req.user.id;
        return this.clientService.create(createClientDto);
    }

    @Get()
    findAll(@Request() req) {
        return this.clientService.findAll(req.user.id);
    }

    @Get(':id')
    findOne(@Param('id') id: string, @Request() req) {
        return this.clientService.findOne(id);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() updateClientDto: UpdateClientDto) {
        return this.clientService.update(id, updateClientDto);
    }

    @Delete(':id')
    remove(@Param('id') id: string) {
        return this.clientService.remove(id);
    }

    @Post(':id/generate-payment')
    generatePayment(@Param('id') id: string, @Body() data: { month: number, year: number }) {
        return this.clientService.generateMonthlyPayment(id, data.month, data.year);
    }

    @Post('generate-all-payments')
    generateAllPayments(@Body() data: { month: number, year: number }, @Request() req) {
        return this.clientService.generateAllMonthlyPayments(req.user.id, data.month, data.year);
    }
}
