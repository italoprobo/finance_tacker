import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';

@Controller('protected')
export class ProtectedController {
  @Get()
  @UseGuards(JwtAuthGuard)  
  getProtectedData() {
    return { message: 'Você tem acesso à rota protegida!' }; 
  }
}
