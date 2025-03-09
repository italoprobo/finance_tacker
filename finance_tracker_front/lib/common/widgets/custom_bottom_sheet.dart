import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'primary_button.dart';

mixin CustomModalSheetMixin<T extends StatefulWidget> on State<T> {
  Future<bool?> showCustomModalBottomSheet({
    required BuildContext context,
    required String content,
    String? buttonText,
    VoidCallback? onPressed,
    List<Widget>? actions,
    bool isDismissible = true,
  }) {
    assert(buttonText != null || actions != null);

    return showModalBottomSheet(
      isDismissible: isDismissible,
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity, 
          height: 250, 
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                content,
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumText20.copyWith(
                  color: AppColors.purple,
                ),
              ),
              const SizedBox(height: 20),
              if (actions != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: actions,
                )
              else
                PrimaryButton(
                  text: buttonText!,
                  onPressed: onPressed ?? () => Navigator.pop(context),
                ),
            ],
          ),
        );
      },
    );
  }
}
