import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { CreateUserDto } from '../dtos/create-user.dto';
import { UpdateUserDto } from '../dtos/update-user.dto';
import * as bcrypt from 'bcrypt';


@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /*async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.userRepository.create(createUserDto);
    return this.userRepository.save(user);
  }*/

  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  async findOne(id: string): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`Usuário com ID ${id} não encontrado`);
    }
    return user;
  }

  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.findOne(id);

    if (updateUserDto.password) {
      if (!updateUserDto.currentPassword) {
        throw new UnauthorizedException('Senha atual é obrigatória');
      }

      const isPasswordValid = await bcrypt.compare(
        updateUserDto.currentPassword,
        user.password
      );

      if (!isPasswordValid) {
        throw new UnauthorizedException('Senha atual inválida');
      }

      if (updateUserDto.password !== updateUserDto.confirmPassword) {
        throw new UnauthorizedException('As senhas não coincidem');
      }

      updateUserDto.password = await bcrypt.hash(updateUserDto.password, 10);
    }

    delete updateUserDto.currentPassword;
    delete updateUserDto.confirmPassword;

    Object.assign(user, updateUserDto);
    return this.userRepository.save(user);
  }

  async remove(id: string): Promise<void> {
    const user = await this.findOne(id);
    await this.userRepository.remove(user);
  }
}
