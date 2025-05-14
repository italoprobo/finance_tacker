import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/models/client.dart';
import 'package:go_router/go_router.dart';

class ClientDetailsPage extends StatelessWidget {
  final Client client;

  const ClientDetailsPage({
    super.key,
    required this.client,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Detalhes do Cliente",
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
                      title: const Text('Editar cliente'),
                      onTap: () {
                        context.pop();
                        context.pushNamed('edit-client', extra: client);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: AppColors.expense),
                      title: const Text('Excluir cliente'),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildClientHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildClientDetails(),
                          const SizedBox(height: 24),
                          _buildContractDetails(),
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

  Widget _buildClientHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            Icons.person,
            color: AppColors.purple,
            size: 40,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          client.name,
          style: AppTextStyles.mediumText16w600,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            client.company ?? 'Sem empresa',
            style: AppTextStyles.smalltextw600.copyWith(
              color: AppColors.purple,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'R\$ ${client.monthly_payment.toStringAsFixed(2)}',
          style: AppTextStyles.mediumText24.copyWith(
            color: AppColors.purple,
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
          'Informações do Cliente',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        if (client.email != null)
          _buildDetailItem(
            'Email',
            client.email!,
          ),
        if (client.phone != null)
          _buildDetailItem(
            'Telefone',
            client.phone!,
          ),
        _buildDetailItem(
          'Status',
          client.status == 'ativo' ? 'Ativo' : 'Inativo',
        ),
      ],
    );
  }

  Widget _buildContractDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Contrato',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Mensalidade',
          'R\$ ${client.monthly_payment.toStringAsFixed(2)}',
        ),
        if (client.payment_day != null)
          _buildDetailItem(
            'Dia de Pagamento',
            client.payment_day.toString(),
          ),
        if (client.contract_start != null)
          _buildDetailItem(
            'Início do Contrato',
            '${client.contract_start!.day.toString().padLeft(2, '0')}/${client.contract_start!.month.toString().padLeft(2, '0')}/${client.contract_start!.year}',
          ),
        _buildDetailItem(
          'Fim do Contrato',
          client.contract_end != null 
              ? '${client.contract_end!.day.toString().padLeft(2, '0')}/${client.contract_end!.month.toString().padLeft(2, '0')}/${client.contract_end!.year}'
              : 'Ainda não definido',
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
        title: const Text('Excluir Cliente'),
        content: const Text('Tem certeza que deseja excluir este cliente?'),
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
