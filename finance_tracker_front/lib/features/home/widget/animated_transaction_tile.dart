import 'package:finance_tracker_front/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:intl/intl.dart';

class AnimatedTransactionTile extends StatelessWidget {
  final Transaction transaction;
  final bool isIncome;
  final String value;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AnimatedTransactionTile({
    Key? key,
    required this.transaction,
    required this.isIncome,
    required this.value,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isIncome ? AppColors.income.withOpacity(0.1) : AppColors.expense.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isIncome ? Icons.arrow_upward : Icons.arrow_downward,
              color: isIncome ? AppColors.income : AppColors.expense,
              size: 20,
            ),
          ),
          title: Text(
            transaction.description,
            style: AppTextStyles.mediumText16w500,
          ),
          subtitle: Text(
            _formatDate(transaction.date),
            style: AppTextStyles.smalltextw400.copyWith(
              color: AppColors.inputcolor,
            ),
          ),
          trailing: Text(
            value,
            style: AppTextStyles.mediumText16w600.copyWith(
              color: isIncome ? AppColors.income : AppColors.expense,
            ),
          ),
        ),
      ),
    );
  }
} 