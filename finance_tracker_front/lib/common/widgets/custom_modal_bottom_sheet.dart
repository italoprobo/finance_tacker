import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';

class CustomModalBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final String? buttonText;
  final Color? buttonColor;
  final Future<void> Function()? onPressed;

  const CustomModalBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.buttonText,
    this.buttonColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.antiFlashWhite,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: AppColors.inputcolor,
              ),
            ],
          ),
          Text(
            title,
            style: AppTextStyles.mediumText20.copyWith(
              color: AppColors.purple,
            ),
          ),
          SizedBox(height: 24.h),
          content,
          if (buttonText != null && onPressed != null) ...[
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await onPressed!();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ?? AppColors.purple,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonText!,
                  style: AppTextStyles.mediumText16w500.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void showCustomModalBottomSheet({
  required BuildContext context,
  required String title,
  required Widget content,
  String? buttonText,
  Color? buttonColor,
  Future<void> Function()? onPressed,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => CustomModalBottomSheet(
      title: title,
      content: content,
      buttonText: buttonText,
      buttonColor: buttonColor,
      onPressed: onPressed,
    ),
  );
} 