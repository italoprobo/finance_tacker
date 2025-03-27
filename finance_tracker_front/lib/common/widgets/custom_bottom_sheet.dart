import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'primary_button.dart';

mixin CustomModalSheetMixin<T extends StatefulWidget> on State<T> {
  Future<bool?> showCustomModalBottomSheet({
    required BuildContext context,
    required String content,
    required String buttonText,
    required VoidCallback onPressed,
    bool isDismissible = true,
  }) {
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
              Stack(
                children: [
                  // Botão X para fechar
                  Positioned(
                    left: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.error,
                        size: 24,
                      ),
                    ),
                  ),
                  // Conteúdo centralizado
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 30.0),
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.mediumText20.copyWith(
                        color: AppColors.purple,
                      ),
                    ),
                  ),
                ],
              ),
              PrimaryButton(
                text: buttonText,
                onPressed: onPressed,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
