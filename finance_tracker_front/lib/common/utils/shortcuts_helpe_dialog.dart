import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class ShortcutsHelpDialog extends StatelessWidget {
  const ShortcutsHelpDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Atalhos do Teclado'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShortcutItem('Ctrl + T', 'Nova Transação'),
          _buildShortcutItem('Ctrl + C', 'Novo Cartão'),
          _buildShortcutItem('Ctrl + U', 'Novo Cliente'),
          _buildShortcutItem('Ctrl + 1', 'Ir para Home'),
          _buildShortcutItem('Ctrl + 2', 'Ir para Carteira'),
          _buildShortcutItem('Ctrl + 3', 'Ir para Clientes'),
          const SizedBox(height: 16),
          const Text(
            'Dica: Use gestos de deslizar para navegar entre as abas',
            style: AppTextStyles.smalltextw400,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildShortcutItem(String shortcut, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.antiFlashWhite,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              shortcut,
              style: AppTextStyles.smalltextw600,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            description,
            style: AppTextStyles.smalltextw400,
          ),
        ],
      ),
    );
  }
}