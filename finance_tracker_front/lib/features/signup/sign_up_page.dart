import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/utils/dialogs_helper.dart';
import 'package:finance_tracker_front/common/utils/uppercase_text_formatter.dart';
import 'package:finance_tracker_front/common/utils/validator.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/password_form_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.icewhite,
      body: Align(
        alignment: Alignment.topCenter,
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              DialogsHelper.showLoadingDialog(context);
            } else {
              DialogsHelper.hideLoadingDialog(context);
            }
            if (state is AuthSuccess) {
              DialogsHelper.showSuccessBottomSheet(context);
              context.goNamed('/login');
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
                    const SizedBox(height: 32.0),
                    Text('Guarde Seu', textAlign: TextAlign.center, style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                    Text('Dinheiro!',  textAlign: TextAlign.center, style: AppTextStyles.mediumText.copyWith(color: AppColors.purple)),
                    Image.asset('assets/images/singuppageimg.png'),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            labelText: "Seu Nome",
                            hintText: "ÍTALO PROBO",
                            controller: _nameController,
                            inputFormatters: [
                              UpperCaseTextInputFormatter()
                            ],
                            validator: Validator.validateName,
                          ),
                          CustomTextFormField(
                            labelText: "Seu Email",
                            hintText: "italoprobo@gmail.com",
                            controller: _emailController,
                            validator: Validator.validateEmail,
                          ),
                          PasswordFormField(
                            labelText: "Escolha sua Senha",
                            hintText: "********",
                            controller: _passwordController,
                            validator: Validator.validatePassword,
                          ),
                          PasswordFormField(
                            labelText: "Confirme sua Senha",
                            hintText: "********",
                            controller: _confirmPasswordController,
                            validator: (value) => Validator.confirmPassword(value, _passwordController.text),
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
                        text: "Registrar",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().register(
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text,
                              _confirmPasswordController.text,
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
            );
          },
        ),
      ),
    );
  }
}
