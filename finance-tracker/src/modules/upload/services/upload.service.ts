import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../../../modules/user/entities/user.entity';

@Injectable()
export class UploadService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  async updateUserProfileImage(userId: string, file: Express.Multer.File) {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }

    user.profileImage = file.filename;
    await this.userRepository.save(user);

    return {
      message: 'Imagem de perfil atualizada com sucesso',
      filename: file.filename,
    };
  }
}