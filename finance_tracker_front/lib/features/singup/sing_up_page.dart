import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/primary_button.dart';

class SingUpPage extends StatelessWidget {
  const SingUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align( 
        alignment: Alignment.topCenter,
        child: ListView(
          shrinkWrap: true,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center, 
              children: [
                Text('Ganhe Controle', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                Text('Planeje Melhor', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                Image.asset('assets/images/singuppageimg.png'),
                Form(child: Column(
                  children: [
                    CustomTextFormField(),
                  ],
                )),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 32.0,
                    right: 32.0,
                    top: 26.0,
                    bottom: 18.0,
                  ),
                  child: PrimaryButton(
                    key: const Key('onboardingGetStartedButton'),
                    text: 'Registrar',
                    onPressed: () => context.goNamed('/register'),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'Já tem uma conta? ', style: AppTextStyles.smalltext.copyWith(color: AppColors.grey)),
                      TextSpan(
                        text: 'Faça Login',
                        style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
                        recognizer: TapGestureRecognizer()..onTap = () => context.goNamed('/login'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {

  final defaultBorder = const OutlineInputBorder();

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Nome',
        border: defaultBorder,
        focusedBorder: defaultBorder.copyWith(borderSide: BorderSide(color: Colors.red)),
        errorBorder: defaultBorder,
        focusedErrorBorder: defaultBorder,
        enabledBorder: defaultBorder,
        disabledBorder: defaultBorder,
      ),
    );
  }
}
