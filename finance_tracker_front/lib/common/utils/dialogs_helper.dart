import 'package:finance_tracker_front/common/widgets/custom_bottom_sheet.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DialogsHelper {
  static void showLoadingDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void hideLoadingDialog(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  static Future<Future<void>?> showSuccessBottomSheet(
      BuildContext context) async {
    final state = context.findAncestorStateOfType<CustomModalSheetMixin>();
    if (state != null) {
      return state.showCustomModalBottomSheet(
        context: context,
        content: "Cadastro realizado com sucesso!",
        buttonText: "OK",
        onPressed: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed('/login');
        },
      );
    } else {
      return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(38.0),
            topRight: Radius.circular(38.0),
          ),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(38.0),
                topRight: Radius.circular(38.0),
              ),
            ),
            height: 250,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Cadastro Realizado!",
                  textAlign: TextAlign.center,
                  style: AppTextStyles.mediumText20.copyWith(
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 12.0),
                Text(
                  "Agora você pode fazer login na sua conta.",
                  textAlign: TextAlign.center,
                  style:
                      AppTextStyles.smalltext.copyWith(color: AppColors.grey),
                ),
                const SizedBox(height: 20.0),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: "OK",
                    onPressed: () {
                      Navigator.pop(context);
                      context.goNamed('/login');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  static Future<void> showErrorBottomSheet(
      BuildContext context, String errorMessage) async {
    return showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(38.0),
          topRight: Radius.circular(38.0),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(38.0),
              topRight: Radius.circular(38.0),
            ),
          ),
          height: 250,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Ops! Algo deu errado.",
                textAlign: TextAlign.center,
                style: AppTextStyles.mediumText20.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 12.0),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: AppTextStyles.smalltext.copyWith(color: AppColors.grey),
              ),
              const SizedBox(height: 20.0),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: "Tentar novamente",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
