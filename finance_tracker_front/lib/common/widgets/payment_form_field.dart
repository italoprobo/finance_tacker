import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class PaymentMethodFormField extends StatelessWidget {
  final String value;
  final Function(String) onMethodSelected;
  final EdgeInsetsGeometry? padding;
  final bool showCreditOption;

  const PaymentMethodFormField({
    super.key,
    required this.value,
    required this.onMethodSelected,
    this.padding,
    this.showCreditOption = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FORMA DE PAGAMENTO',
            style: AppTextStyles.inputLabelText.copyWith(color: AppColors.inputcolor),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              _buildOption('Dinheiro', 'dinheiro', Icons.money, context),
              const SizedBox(width: 8.0),
              _buildOption('Débito', 'debito', Icons.credit_card, context),
              const SizedBox(width: 8.0),
              if (showCreditOption)
                _buildOption('Crédito', 'credito', Icons.credit_score, context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String label, String optionValue, IconData icon, BuildContext context) {
    final isSelected = value == optionValue;
    return Expanded(
      child: InkWell(
        onTap: () => onMethodSelected(optionValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.purple.withOpacity(0.1) : AppColors.white,
            border: Border.all(
              color: isSelected ? AppColors.purple : AppColors.inputcolor,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.purple : AppColors.inputcolor,
              ),
              const SizedBox(height: 4.0),
              Text(
                label,
                style: AppTextStyles.smalltextw400.copyWith(
                  color: isSelected ? AppColors.purple : AppColors.inputcolor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}