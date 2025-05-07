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
                    _buildCardHeader(),
                    const SizedBox(height: 24),
                    _buildCardDetails(),
                    const SizedBox(height: 24),
                    _buildCardLimits(),
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
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            _getCardIconPath(card.name),
            width: 50,
            height: 50,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: AppColors.antiFlashWhite,
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.purple,
                  size: 30,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.name,
                style: AppTextStyles.mediumText16w600,
              ),
              const SizedBox(height: 4),
              Text(
                '•••• ${card.lastDigits}',
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

  Widget _buildCardDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalhes do Cartão',
          style: AppTextStyles.mediumText16w600,
        ),
        const SizedBox(height: 16),
        _buildDetailItem(
          'Tipo',
          card.cardType.map((type) => type.toUpperCase()).join(', '),
        ),
        if (card.closingDate != null)
          _buildDetailItem(
            'Data de Fechamento',
            '${card.closingDate!.day}/${card.closingDate!.month}',
          ),
        if (card.dueDate != null)
          _buildDetailItem(
            'Data de Vencimento',
            '${card.dueDate!.day}/${card.dueDate!.month}',
          ),
      ],
    );
  }

  Widget _buildCardLimits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
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
