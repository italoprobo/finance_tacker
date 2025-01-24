import { Body, Controller, Post, UnauthorizedException } from "@nestjs/common";
import { AuthService } from "../services/auth.service";
import { User } from "../../user/entities/user.entity";

@Controller('auth')
export class AuthController {
    constructor(private readonly authService: AuthService) {}

    @Post('register')
    async register(@Body('email') email: string, @Body('password') password: string): Promise<User> {
        return this.authService.register(email, password);
    } 

    @Post('login')
    async login(
        @Body('email') email: string,
        @Body('password') password: string
    ): Promise<{ acessToken: string }> {
        const user = await this.authService.validadeUser(email, password);
        if (!user) {
            throw new UnauthorizedException('Email ou senha inválidos');
        }
        return this.authService.login(user);
    }
}