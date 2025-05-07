import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/widgets/custom_modal_bottom_sheet.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreditCardItem extends StatelessWidget {
  final CardModel card;
  final bool isPending;

  const CreditCardItem({
    Key? key,
    required this.card,
    this.isPending = true,
  }) : super(key: key);

  String _getCardIconPath(String cardName) {
    cardName = cardName.toLowerCase();
    if (cardName.contains('nubank')) return 'images/nubank_logo.png';
    if (cardName.contains('inter')) return 'assets/images/inter_logo.png';
    if (cardName.contains('itau')) return 'assets/images/itau_logo.png';
    if (cardName.contains('santander')) return 'assets/images/santander_logo.png';
    if (cardName.contains('bradesco')) return 'assets/images/bradesco_logo.png';
    if (cardName.contains('caixa')) return 'assets/images/caixa_logo.png';
    if (cardName.contains('bb')) return 'assets/images/bb_logo.png';
    // Imagem padrão caso não encontre o banco
    return 'assets/images/credit_card.png';
  }

  String _formatDueDate() {
    if (card.dueDate == null) return 'Não definido';
    return '${card.dueDate!.day.toString().padLeft(2, '0')}/${card.dueDate!.month.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed('card-details', extra: card);
      },
      onLongPress: () {
        showCustomModalBottomSheet(
          context: context,
          title: 'O que deseja fazer?',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      context.pop();
                      context.pushNamed('edit-card', extra: card);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.iceWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: AppColors.purple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Editar',
                          style: AppTextStyles.smalltextw400.copyWith(
                            color: AppColors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.pop();
                      _showDeleteConfirmation(context);
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.iceWhite,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: AppColors.expense,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Excluir',
                          style: AppTextStyles.smalltextw400.copyWith(
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        child: Row(
          children: [
            // Logo do cartão
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                _getCardIconPath(card.name),
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback para um ícone genérico
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
            const SizedBox(width: 9),
            // Detalhes do cartão
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        card.name,
                        style: AppTextStyles.mediumText16w600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•••• ${card.lastDigits}',
                        style: AppTextStyles.smalltextw600.copyWith(
                          color: const Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _formatDueDate(),
                    style: AppTextStyles.smalltext13.copyWith(
                      color: const Color(0xFF666666),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Valor da fatura
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- R\$ ${card.currentBalance.toStringAsFixed(2)}',
                  style: AppTextStyles.mediumText16w600.copyWith(
                    color: AppColors.expense,
                  ),
                ),
                if (isPending)
                  Text(
                    'pendente',
                    style: AppTextStyles.smalltextw400.copyWith(
                      color: const Color(0xFF666666),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
