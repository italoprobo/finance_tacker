import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:go_router/go_router.dart';

class CardDetailsPage extends StatelessWidget {
  final CardModel card;

  const CardDetailsPage({
    super.key,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          AppHeader(
            title: "Detalhes do Cartão",
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
                      title: const Text('Editar cartão'),
                      onTap: () {
                        context.pop();
                        context.pushNamed('edit-card', extra: card);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete, color: AppColors.expense),
                      title: const Text('Excluir cartão'),
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
                    _buildCardHeader(),
                    const SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCardDetails(),
                          const SizedBox(height: 24),
                          _buildCardLimits(),
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

  Widget _buildCardHeader() {
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.asset(
              _getCardIconPath(card.name),
              width: 80,
              height: 80,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.credit_card,
                  color: AppColors.purple,
                  size: 40,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          card.name,
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
            '•••• ${card.lastDigits}',
            style: AppTextStyles.smalltextw600.copyWith(
              color: AppColors.purple,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'R\$ ${card.limit.toStringAsFixed(2)}',
          style: AppTextStyles.mediumText24.copyWith(
            color: AppColors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Detalhes do Cartão',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Tipo',
          card.cardType.map((type) => type.toUpperCase()).join(', '),
        ),
        if (card.closingDay != null)
          _buildDetailItem(
            'Dia de Fechamento',
            card.closingDay.toString(),
          ),
        if (card.dueDay != null)
          _buildDetailItem(
            'Dia de Vencimento',
            card.dueDay.toString(),
          ),
      ],
    );
  }

  Widget _buildCardLimits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Limites',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Limite Total',
          'R\$ ${card.limit.toStringAsFixed(2)}',
        ),
        _buildDetailItem(
          'Saldo Atual',
          'R\$ ${card.currentBalance.toStringAsFixed(2)}',
        ),
        _buildDetailItem(
          'Limite Disponível',
          'R\$ ${(card.limit - card.currentBalance).toStringAsFixed(2)}',
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

  String _getCardIconPath(String cardName) {
    cardName = cardName.toLowerCase();
    if (cardName.contains('nubank')) return 'images/nubank_logo.png';
    if (cardName.contains('inter')) return 'assets/images/inter_logo.png';
    if (cardName.contains('itau')) return 'assets/images/itau_logo.png';
    if (cardName.contains('santander')) return 'assets/images/santander_logo.png';
    if (cardName.contains('bradesco')) return 'assets/images/bradesco_logo.png';
    if (cardName.contains('caixa')) return 'assets/images/caixa_logo.png';
    if (cardName.contains('bb')) return 'assets/images/bb_logo.png';
    return 'assets/images/credit_card.png';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cartão'),
        content: const Text('Tem certeza que deseja excluir este cartão?'),
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
