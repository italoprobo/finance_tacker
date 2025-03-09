import 'dart:async';

import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/widgets/custom_circular_progress_indicator.dart';
import 'package:finance_tracker_front/features/onboarding/onboarding_page.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Timer init(){
    return Timer(const Duration(seconds: 2), 
    navigateToOnBoarding);
  }

  // resolver essa questao com o chat depois uso mesmo esse navigate? 
  //o bloc e o cubit e o gorouter entram nessa parte ou nao precisa?
  void navigateToOnBoarding() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.gradient,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
            'finance ai', 
            style: AppTextStyles.bigText50.copyWith(
              color: AppColors.white,)
              ),
              Text(
                'Sincronizando seus dados...',
                style: AppTextStyles.smalltext13.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16.0),
              const CustomCircularProgressIndicator(
                color: AppColors.white,
              ),
          ],
        ),
    ),
    );
  }
}