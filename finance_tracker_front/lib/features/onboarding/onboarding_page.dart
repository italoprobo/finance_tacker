import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/widgets/primary_button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.icewhite,
      body: Align(
        child: Column(children: [
          const SizedBox(height: 48.0,),
          Expanded(
          flex: 2,
          child: Image.asset('assets/images/onboardingimg.png')
          ),
          Text('Ganhe Controle', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
          Text('Planeje Melhor', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
          Padding(
            padding: const EdgeInsets.only(
              left: 32.0,
              right: 32.0,
              top: 26.0,
              bottom: 18.0,
            ),
            child: PrimaryButton(
              key: const Key('onboardingGetStartedButton'),
              text: 'Começar',
              onPressed: () => {
                context.goNamed('/register')
              },
            ),
          ),
          RichText(text: TextSpan( 
            children: [
              TextSpan(text: 'Já tem uma conta? ', style: AppTextStyles.smalltext.copyWith(color: AppColors.grey)),
              TextSpan(
                text: 'Faça Login',
                style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
                recognizer: TapGestureRecognizer()..onTap = () => context.goNamed('/login'),
              ),
            ],
            ),),
          const SizedBox(height: 48.0,),
         ],
        ),
      ),
    );
  }
}