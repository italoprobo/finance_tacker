import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
 import 'package:flutter/material.dart';


class SingUpPage extends StatelessWidget {
  const SingUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Ganhe Controle', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
          Text('Planeje Melhor', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
        ],
      ),
    );
  }
}