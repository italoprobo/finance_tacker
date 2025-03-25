import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

class BalanceCard extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpense;
  final double textScaleFactor;
  final double iconSize;

  const BalanceCard({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.textScaleFactor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 23.w, vertical: 32.h),
      decoration: const BoxDecoration(
        color: AppColors.purple,
        borderRadius: BorderRadius.all(Radius.circular(16.0)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          SizedBox(height: 36.h),
          _buildBalanceDetails(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo Total',
                textScaleFactor: textScaleFactor,
                style: AppTextStyles.mediumText22.apply(color: AppColors.white),
              ),
              Text(
                'R\$ ${totalBalance.toStringAsFixed(2)}',
                textScaleFactor: textScaleFactor,
                style: AppTextStyles.mediumText28.apply(color: AppColors.white),
              )
            ],
          ),
        ),
        _buildOptionsMenu(),
      ],
    );
  }

  Widget _buildBalanceDetails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BalanceItem(
          icon: Icons.arrow_upward,
          label: "Entradas",
          value: totalIncome,
          textScaleFactor: textScaleFactor,
          iconSize: iconSize,
        ),
        _BalanceItem(
          icon: Icons.arrow_downward,
          label: "Saidas",
          value: totalExpense,
          textScaleFactor: textScaleFactor,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildOptionsMenu() {
    return PopupMenuButton(
      padding: EdgeInsets.zero,
      child: const Icon(
        Icons.more_horiz,
        color: AppColors.white,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          height: 24.0,
          child: Text("Item 1"),
        )
      ],
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double textScaleFactor;
  final double iconSize;

  const _BalanceItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.textScaleFactor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    // Determina se é uma saída baseado no label
    final bool isExpense = label == "Saidas";
    // Formata o valor com sinal negativo se for saída
    final String formattedValue = isExpense 
        ? "R\$ -${value.toStringAsFixed(2)}"
        : "R\$ ${value.toStringAsFixed(2)}";

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.06),
            borderRadius: const BorderRadius.all(Radius.circular(16.0)),
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 4.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              textScaleFactor: textScaleFactor,
              style: AppTextStyles.mediumText16w500
                  .apply(color: AppColors.incomesndexpenses),
            ),
            Text(
              formattedValue,
              textScaleFactor: textScaleFactor,
              style: AppTextStyles.mediumText18.apply(color: AppColors.white),
            )
          ],
        )
      ],
    );
  }
}