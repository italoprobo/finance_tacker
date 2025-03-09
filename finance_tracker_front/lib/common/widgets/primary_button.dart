import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'custom_circular_progress_indicator.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading; 

  const PrimaryButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
  });

  final BorderRadius _borderRadius = const BorderRadius.all(Radius.circular(24.0));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        height: 48.0,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: onPressed != null
                ? AppColors.gradient
                : AppColors.greyGradient,
          ),
        ),
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: isLoading ? null : onPressed, 
          child: Center(
            child: isLoading
                ? const CustomCircularProgressIndicator() 
                : Text(
                    text,
                    style: AppTextStyles.buttontext.copyWith(
                      color: AppColors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
