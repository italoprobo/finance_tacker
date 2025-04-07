import { Controller, Post, UseInterceptors, UploadedFile, UseGuards, Request } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { UploadService } from '../services/upload.service';

@Controller('upload')
@UseGuards(JwtAuthGuard)
export class UploadController {
  constructor(private readonly uploadService: UploadService) {}

  @Post('profile-image')
  @UseInterceptors(FileInterceptor('image'))
  async uploadProfileImage(
    @UploadedFile() file: Express.Multer.File,
    @Request() req,
  ) {
    return this.uploadService.updateUserProfileImage(req.user.id, file);
  }
}