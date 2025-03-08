import 'dart:math';

import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/utils/validator.dart';
import 'package:finance_tracker_front/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/widgets/password_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../common/utils/uppercase_text_formatter.dart';
import '../../widgets/primary_button.dart';

class SingUpPage extends StatefulWidget {
  const SingUpPage({super.key});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {

  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _passwordController = TextEditingController();

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
                const SizedBox(height: 32.0),
                Text('Guarde Seu', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                Text('Dinheiro!', style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                Image.asset('assets/images/singuppageimg.png'),
                Form(
                  key: _formKey,
                  child: Column(
                  children: [
                    CustomTextFormField(
                      labelText: "seu nome",
                      hintText: "ÍTALO PROBO",
                      inputFormatters: [
                        UpperCaseTextInputFormatter(),
                      ],
                      validator: Validator.validateName,
                    ),
                    const CustomTextFormField(
                      labelText: "seu email",
                      hintText: "italoprobo@gmail.com",
                      validator: Validator.validateEmail,
                    ),
                    PasswordFormField(
                      labelText: "escolha sua senha",
                      hintText: "********",
                      controller: _passwordController,
                      validator: Validator.validatePassword,
                    ),
                    PasswordFormField(
                      labelText: "confirme sua senha",
                      hintText: "********",
                      validator: (value) => Validator.confirmPassword(value, _passwordController.text),
                    ),
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
                    onPressed: () {
                      final valid = _formKey.currentState!.validate();
                      if(valid){
                        log("Continuar lógica de login" as num);
                      }
                    },
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
