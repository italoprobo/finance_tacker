import { Injectable, UnauthorizedException } from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import { InjectRepository } from "@nestjs/typeorm";
import { Repository } from "typeorm";
import * as bcrypt from 'bcrypt';
import { User } from "../../user/entities/user.entity";

@Injectable()
export class AuthService {
    constructor(
        @InjectRepository(User)
        private readonly userRepository: Repository<User>,
        private readonly jwtService: JwtService
    ) {}

    async register(name: string, email: string, password: string, confirmPassword: string): Promise<User> {
        const existingUser = await this.userRepository.findOne({ where: { email } });
        if (existingUser) {
            throw new Error('E-mail já está registrado');
        }

        if (password !== confirmPassword) {
            throw new Error('As senhas não coincidem');
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const user = this.userRepository.create({ name, email, password: hashedPassword });
        return this.userRepository.save(user);
    }

    async validadeUser(email: string, password: string): Promise<User | null> {
        const user = await this.userRepository.findOne({ where: { email } });
        if (user && (await bcrypt.compare(password, user.password))) {
            return user;
        }
        return null;
    }

    async login(user: User): Promise<{ accessToken: string }> {
        const payload = { id: user.id, email: user.email };
        return {
            accessToken: this.jwtService.sign(payload),
        };
    }
}