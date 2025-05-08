import { Injectable, NotFoundException, UnauthorizedException } from "@nestjs/common";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import { Card } from "../entities/card.entity";
import { CreateCardDto } from "../dtos/create-card.dto";
import { UpdateCardDto } from "../dtos/update-card.dto";
import { User } from "src/modules/user/entities/user.entity";

@Injectable()
export class CardService {

    constructor(
        @InjectRepository(Card)
        private readonly cardRepository: Repository<Card>,
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
    ) {}

    async create(createCardDto: CreateCardDto): Promise<Card> {
        const card = this.cardRepository.create({
            ...createCardDto,
            closingDay: createCardDto.closingDay,
            dueDay: createCardDto.dueDay,
            user: { id: createCardDto.userId }
        });
        return this.cardRepository.save(card);
    }

    async findAll(userId: string): Promise<Card[]> {
        return this.cardRepository.find({ 
            where: { user: { id: userId } },
            relations: ['user']
        });
    }

    async findOne(id: string, userId: string): Promise<Card> {
        const card = await this.cardRepository.findOne({
            where: { id, user: { id: userId } },
            relations: ['user'],
        });
        
        if (!card) {
            throw new NotFoundException('Cartão não encontrado');
        }
        
        return card;
    }

    async update(id: string, updateCardDto: UpdateCardDto): Promise<Card> {
        const card = await this.cardRepository.findOne({ 
            where: { 
                id,
                user: { id: updateCardDto.userId }
            } 
        });

        if (!card) {
            throw new NotFoundException('Cartão não encontrado ou não pertence ao usuário');
        }

        Object.assign(card, {
            ...updateCardDto,
            closingDay: updateCardDto.closingDay,
            dueDay: updateCardDto.dueDay,
            user: { id: updateCardDto.userId }
        });

        return this.cardRepository.save(card);
    }

    async remove(id: string, userId: string): Promise<void> {
        const card = await this.findOne(id, userId);
        
        if (card.user.id !== userId) {
            throw new UnauthorizedException('Você não tem permissão para remover este cartão');
        }

        const result = await this.cardRepository.delete(id);
        if (result.affected === 0) {
            throw new NotFoundException('Cartão não encontrado');
        }
    }
}