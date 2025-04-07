import 'package:finance_tracker_front/common/widgets/custom_bottom_sheet.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class DialogsHelper {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static bool _isDialogShowing = false;

  static void showLoadingDialog(BuildContext context) {
    if (!_isDialogShowing) {
      _isDialogShowing = true;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
    }
  }

  static void hideLoadingDialog(BuildContext context) {
    if (_isDialogShowing) {
      _isDialogShowing = false;
      Navigator.of(context, rootNavigator: true).pop();
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
          Navigator.of(context).pushNamed('login');
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

  static Future<void> showLoginErrorBottomSheet(
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
        String title = "Ops! Algo deu errado.";
        String buttonText = "Tentar novamente";
        
        if (errorMessage.contains("Email ou senha incorretos")) {
          title = "Credenciais inválidas";
        } else if (errorMessage.contains("conexão")) {
          title = "Erro de conexão";
        }

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
                title,
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
                  text: buttonText,
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
