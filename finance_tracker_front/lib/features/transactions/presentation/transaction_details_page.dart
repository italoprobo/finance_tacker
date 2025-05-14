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
            top: 164.h,
            left: 0,
            right: 0,
            bottom: 0.5.h,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildTransactionHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTransactionDetails(),
                          const SizedBox(height: 24),
                          if (transaction.client != null) _buildClientDetails(),
                        ],
                      ),
                    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: transaction.type == 'entrada' 
                ? AppColors.income.withOpacity(0.1)
                : AppColors.expense.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            transaction.type == 'entrada' ? Icons.arrow_upward : Icons.arrow_downward,
            color: transaction.type == 'entrada' ? AppColors.income : AppColors.expense,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          transaction.description,
          style: AppTextStyles.mediumText16w600,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: transaction.type == 'entrada' 
                ? AppColors.income.withOpacity(0.1)
                : AppColors.expense.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            transaction.type == 'entrada' ? 'Entrada' : 'Saída',
            style: AppTextStyles.smalltextw600.copyWith(
              color: transaction.type == 'entrada' 
                  ? AppColors.income 
                  : AppColors.expense,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'R\$ ${transaction.amount.toStringAsFixed(2)}',
          style: AppTextStyles.mediumText24.copyWith(
            color: transaction.type == 'entrada' 
                ? AppColors.income 
                : AppColors.expense,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes da Transação',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Status',
          transaction.type == 'entrada' ? 'Entrada' : 'Saída',
          color: transaction.type == 'entrada' ? AppColors.income : AppColors.expense,
        ),
        _buildDetailItem(
          'Tempo',
          DateFormat('HH:mm').format(transaction.date),
        ),
        _buildDetailItem(
          'Data',
          DateFormat('dd/MM/yyyy').format(transaction.date),
        ),
        _buildDetailItem(
          'Gasto',
          'R\$ ${transaction.amount.toStringAsFixed(2)}',
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(
              color: const Color(0xFF611BF8),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                // Implementar download do recibo
              },
              child: Center(
                child: Text(
                  'Baixar Recibo (TESTE)',
                  style: AppTextStyles.mediumText18.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF611BF8),
                  ),
                ),
              ),
            ),
          ),
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

  Widget _buildDetailItem(String label, String value, {Color? color}) {
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
            style: AppTextStyles.smalltextw600.copyWith(
              color: color,
            ),
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
