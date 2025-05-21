import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

enum ToastType { success, error, info }

class CustomToast extends StatelessWidget {
  final String message;
  final ToastType type;

  const CustomToast({
    Key? key,
    required this.message,
    this.type = ToastType.info,
  }) : super(key: key);

  Color get _backgroundColor {
    switch (type) {
      case ToastType.success:
        return AppColors.income.withOpacity(0.9);
      case ToastType.error:
        return AppColors.expense.withOpacity(0.9);
      case ToastType.info:
        return AppColors.purple.withOpacity(0.9);
    }
  }

  IconData get _icon {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
    }
  }

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 50,
        width: MediaQuery.of(context).size.width - 32,
        left: 16,
        child: Material(
          color: Colors.transparent,
          child: CustomToast(
            message: message,
            type: type,
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(duration, () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(_icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.smalltextw600.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}