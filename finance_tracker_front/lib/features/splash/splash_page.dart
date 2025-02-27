import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
        child: Text(
        'Finance AI', 
        style: const TextStyle(
          fontSize: 45.0,
          fontWeight: FontWeight.w700).copyWith(color: AppColors.white),
      ),
    ),
    );
  }
}