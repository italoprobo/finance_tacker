import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class OperationFeedback extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback? onRetry;

  const OperationFeedback({
    super.key,
    required this.isSuccess,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.income.withOpacity(0.1) : AppColors.expense.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.income : AppColors.expense,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.mediumText16w500.copyWith(
                color: isSuccess ? AppColors.income : AppColors.expense,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Tentar novamente',
                style: AppTextStyles.mediumText16w500.copyWith(
                  color: AppColors.purple,
                ),
              ),
            ),
        ],
      ),
    );
  }
} 