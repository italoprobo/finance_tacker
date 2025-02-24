import { Body, Controller, Post, UnauthorizedException } from "@nestjs/common";
import { AuthService } from "../services/auth.service";
import { User } from "../../user/entities/user.entity";

@Controller('auth')
export class AuthController {
    constructor(private readonly authService: AuthService) {}

    @Post('register')
    async register(
        @Body('name') name: string,
        @Body('email') email: string,
        @Body('password') password: string,
        @Body('confirmPassword') confirmPassword: string
    ): Promise<User> {
        return this.authService.register(name, email, password, confirmPassword);
    }

    @Post('login')
    async login(
        @Body('email') email: string,
        @Body('password') password: string
    ): Promise<{ accessToken: string }> {
        const user = await this.authService.validadeUser(email, password);
        if (!user) {
            throw new UnauthorizedException('Email ou senha inválidos');
        }
        return this.authService.login(user);
    }
}
