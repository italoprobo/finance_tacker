import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        child: Column(children: [
          const SizedBox(height: 60.0,),
          Expanded(
          flex: 2,
          child: Container(
            color: AppColors.icewhite,
            child: Image.asset('assets/images/onboardingimg.png'),
            )
          ),
          Text('Ganhe Controle', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
          Text('Planeje Melhor', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
          Container(
            alignment: Alignment.center,
            height: 56.0,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.gradient)
            ),
            child: Text('Começar', style: AppTextStyles.buttontext.copyWith(color: AppColors.white),),
          ),
          Text('Já tem uma conta? Faça Login', style: AppTextStyles.smalltext.copyWith(color: AppColors.grey)),
          const SizedBox(height: 80.0,),
         ],
        ),
      ),
    );
  }
}