import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from '../user/entities/user.entity';
import { Report } from './entities/reports.entity';
import { ReportsController } from './controllers/reports.controller';
import { ReportsService } from './services/reports.services';

@Module({
    imports: [TypeOrmModule.forFeature([Report, User])],
    controllers: [ReportsController],
    providers: [ReportsService],
})
export class ReportsModule {}
