import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/utils/dialogs_helper.dart';
import 'package:finance_tracker_front/common/utils/validator.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/password_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.icewhite,
      body: Align(
        alignment: Alignment.center,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              DialogsHelper.showLoadingDialog(context);
            } else {
              DialogsHelper.hideLoadingDialog(context);
            }
            if (state is AuthSuccess) {
              context.goNamed('home');
              // ver com o chat como posso fazer para ele poder ir e voltar no app
              // com essa opção gonamed quando eu clico no botao de voltar no celular ele sai do app
            } else if (state is AuthFailure) {
              DialogsHelper.showErrorBottomSheet(context, state.message);
            }
          },
          builder: (context, state) {
            return ListView(
              shrinkWrap: true,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Bem-vindo!', textAlign: TextAlign.center, style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                    const SizedBox(height: 34.0),
                    Image.asset('assets/images/loginpageimg.png'),
                    const SizedBox(height: 34.0),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            labelText: "Seu Email",
                            hintText: "italo@gmail.com",
                            controller: _emailController,
                            validator: Validator.validateEmail,
                          ),
                          PasswordFormField(
                            labelText: "Digite sua Senha",
                            hintText: "********",
                            controller: _passwordController,
                            validator: Validator.validatePassword,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 32.0,
                        right: 32.0,
                        top: 26.0,
                        bottom: 18.0,
                      ),
                      child: PrimaryButton(
                        text: "Login",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              _emailController.text,
                              _passwordController.text,
                            );
                          }
                        },
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'Já tem uma conta? ', style: AppTextStyles.smalltext.copyWith(color: AppColors.grey)),
                          TextSpan(
                            text: 'Registre-se',
                            style: AppTextStyles.smalltext.copyWith(color: AppColors.purpleligth),
                            recognizer: TapGestureRecognizer()..onTap = () => context.goNamed('sign-up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
