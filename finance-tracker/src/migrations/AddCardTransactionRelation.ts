import { MigrationInterface, QueryRunner, TableColumn, TableForeignKey } from "typeorm";

export class AddCardTransactionRelation1710890400000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Adicionando novos campos na tabela cards
        await queryRunner.addColumns('cards', [
            new TableColumn({
                name: 'salary',
                type: 'decimal',
                precision: 10,
                scale: 2,
                isNullable: true,
            }),
            new TableColumn({
                name: 'invoice_transactions',
                type: 'jsonb',
                isNullable: true,
            }),
        ]);

        // Adicionando novos campos na tabela transactions
        await queryRunner.addColumns('transactions', [
            new TableColumn({
                name: 'payment_method',
                type: 'enum',
                enum: ['credit', 'debit'],
                isNullable: true,
            }),
            new TableColumn({
                name: 'card_id',
                type: 'uuid',
                isNullable: true,
            }),
        ]);

        // Adicionando foreign key para relacionar transaction com card
        await queryRunner.createForeignKey('transactions', new TableForeignKey({
            name: 'FK_transaction_card',
            columnNames: ['card_id'],
            referencedColumnNames: ['id'],
            referencedTableName: 'cards',
            onDelete: 'SET NULL',
            onUpdate: 'CASCADE',
        }));
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Removendo foreign key
        await queryRunner.dropForeignKey('transactions', 'FK_transaction_card');

        // Removendo colunas da tabela transactions
        await queryRunner.dropColumns('transactions', [
            'payment_method',
            'card_id',
        ]);

        // Removendo colunas da tabela cards
        await queryRunner.dropColumns('cards', [
            'salary',
            'invoice_transactions',
        ]);
    }
}
