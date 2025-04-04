import { IsString, IsOptional, MinLength } from 'class-validator';

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;

  @IsOptional()
  @IsString()
  currentPassword?: string;

  @IsOptional()
  @IsString()
  confirmPassword?: string;
}

