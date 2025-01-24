import { TypeOrmModuleOptions } from "@nestjs/typeorm";
import { Card } from "src/modules/cards/entities/card.entity";
import { Category } from "src/modules/categories/entities/categories.entity";
import { Report } from "src/modules/reports/entities/reports.entity";
import { Transaction } from "src/modules/transactions/entities/transaction.entity";
import { User } from "src/modules/user/entities/user.entity";
import { DataSourceOptions } from "typeorm";
import * as dotenv from 'dotenv';

dotenv.config()

console.log('Database Configuration:', {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
});

export const databaseConfig: DataSourceOptions = {
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT),
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: [User, Transaction, Category, Card, Report],
  synchronize: true,
  logging: true,
};