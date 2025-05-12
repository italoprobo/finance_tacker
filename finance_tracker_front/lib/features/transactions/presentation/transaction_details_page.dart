import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/models/transaction.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsPage({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Detalhes da Transação",
            hasOptions: true,
            onBackPressed: () => context.pop(),
            onOptionsPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit, color: AppColors.purple),
                      title: const Text('Editar transação'),
                      onTap: () {
                        context.pop();
                        context.pushNamed('edit-transaction', extra: transaction);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: AppColors.expense),
                      title: const Text('Excluir transação'),
                      onTap: () {
                        context.pop();
                        _showDeleteConfirmation(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 150.h,
            left: 28.w,
            right: 28.w,
            bottom: 0.5.h,
            child: Container(
              width: 358.w,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTransactionHeader(),
                    const SizedBox(height: 24),
                    _buildTransactionDetails(),
                    const SizedBox(height: 24),
                    if (transaction.client != null) _buildClientDetails(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: transaction.type == 'entrada' 
                ? AppColors.income.withOpacity(0.1)
                : AppColors.expense.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            transaction.type == 'entrada' ? Icons.arrow_upward : Icons.arrow_downward,
            color: transaction.type == 'entrada' ? AppColors.income : AppColors.expense,
            size: 30,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'R\$ ${transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.mediumText16w600.copyWith(
                  color: transaction.type == 'entrada' 
                      ? AppColors.income 
                      : AppColors.expense,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.description,
                style: AppTextStyles.smalltextw600.copyWith(
                  color: const Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes da Transação',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Data',
          DateFormat('dd/MM/yyyy').format(transaction.date),
        ),
        _buildDetailItem(
          'Tipo',
          transaction.type == 'entrada' ? 'Receita' : 'Despesa',
        ),
        _buildDetailItem(
          'Categoria',
          transaction.category,
        ),
        _buildDetailItem(
          'Recorrente',
          transaction.isRecurring ? 'Sim' : 'Não',
        ),
      ],
    );
  }

  Widget _buildClientDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Cliente',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Nome',
          transaction.client!.name,
        ),
        if (transaction.client!.company != null)
          _buildDetailItem(
            'Empresa',
            transaction.client!.company!,
          ),
        _buildDetailItem(
          'Status',
          transaction.client!.status == 'ativo' ? 'Ativo' : 'Inativo',
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.smalltextw400.copyWith(
              color: const Color(0xFF666666),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.smalltextw600,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Implementar lógica de exclusão
              Navigator.pop(context);
            },
            child: const Text(
              'Excluir',
              style: TextStyle(color: AppColors.expense),
            ),
          ),
        ],
      ),
    );
  }
}
