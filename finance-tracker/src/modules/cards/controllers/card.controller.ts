import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Request } from "@nestjs/common";
import { CardService } from "../services/card.service";
import { CreateCardDto } from "../dtos/create-card.dto";
import { UpdateCardDto } from "../dtos/update-card.dto";
import { JwtAuthGuard } from "../../auth/guards/jwt-auth.guard";

@Controller('card')
@UseGuards(JwtAuthGuard)
export class CardController {
    constructor(private readonly cardService: CardService) {}

    @Post()
    create(@Body() createCardDto: CreateCardDto, @Request() req) {
        createCardDto.userId = req.user.id;
        return this.cardService.create(createCardDto);
    }

    @Get()
    findAll(@Request() req) {
        return this.cardService.findAll(req.user.id);
    }

    @Get(':id')
    findOne(@Param('id') id: string, @Request() req) {
        return this.cardService.findOne(id, req.user.id);
    }

    @Patch(':id')
    update(@Param('id') id: string, @Body() updateCardDto: UpdateCardDto, @Request() req) {
        return this.cardService.update(id, updateCardDto, req.user.id);
    }

    @Delete(':id')
    remove(@Param('id') id: string, @Request() req) {
        return this.cardService.remove(id, req.user.id);
    }
}
