import { Inject, Injectable, NotFoundException } from "@nestjs/common";
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

        const user = await this.userRepository.findOneBy({ id: createCardDto.userId });
        if (!user) {
            throw new NotFoundException('Usuário não encontrado');
        }

        const card = this.cardRepository.create({...createCardDto, user});
        return this.cardRepository.save(card);
    }

    async findAll(): Promise<Card[]> {
        return this.cardRepository.find({ relations: ['user'] });
    }

    async findOne(id: string): Promise<Card> {
        const card = await this.cardRepository.findOne({where: {id}, relations: ['user']});
        if (!card) {
            throw new NotFoundException('Cartão não encontrado');
        }
        return card;
    }

    async update(id: string, updateCardDto: UpdateCardDto): Promise<Card> {
        const card = await this.cardRepository.preload({
          id,
          ...updateCardDto,
        });
    
        if (!card) {
          throw new NotFoundException('Cartão não encontrado');
        }
    
        return this.cardRepository.save(card);
    }

    async remove(id: string): Promise<void> {
        const result = await this.cardRepository.delete(id);
        if (result.affected === 0) {
          throw new NotFoundException('Card not found');
        }
    }
}