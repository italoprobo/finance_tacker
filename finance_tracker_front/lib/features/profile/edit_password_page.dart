import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/password_form_field.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/common/widgets/custom_snackbar.dart';
import 'package:finance_tracker_front/common/utils/validator.dart';
import 'package:go_router/go_router.dart';

class EditPasswordPage extends StatefulWidget {
  const EditPasswordPage({super.key});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> with CustomSnackBar {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    showCustomSnackBar(
      context: context,
      text: message,
      type: SnackBarType.error,
    );
  }

  void _showSuccessSnackBar() {
    showCustomSnackBar(
      context: context,
      text: 'Senha atualizada com sucesso!',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AppHeader(
            title: "Alterar Senha",
          ),
          Positioned(
            top: 115.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 24.h),
                    PasswordFormField(
                      padding: EdgeInsets.zero,
                      controller: _currentPasswordController,
                      labelText: 'SENHA ATUAL',
                      hintText: '********',
                      validator: (value) {
                        if (value == null) {
                          return 'Digite sua senha atual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    PasswordFormField(
                      padding: EdgeInsets.zero,
                      controller: _newPasswordController,
                      labelText: 'NOVA SENHA',
                      hintText: '********',
                      validator: Validator.validatePassword,
                    ),
                    const SizedBox(height: 16.0),
                    PasswordFormField(
                      padding: EdgeInsets.zero,
                      controller: _confirmPasswordController,
                      labelText: 'CONFIRMAR NOVA SENHA',
                      hintText: '********',
                      validator: (value) => Validator.confirmPassword(
                        value,
                        _newPasswordController.text,
                      ),
                    ),
                    const SizedBox(height: 26.0),
                    BlocListener<AuthCubit, AuthState>(
                      listener: (context, state) {
                        if (state is AuthLoading) {
                          setState(() => _isLoading = true);
                        } else if (state is AuthSuccess) {
                          if (_isLoading) {
                            setState(() => _isLoading = false);
                            _showSuccessSnackBar();
                            context.goNamed('profile');
                          }
                        } else if (state is AuthFailure) {
                          setState(() => _isLoading = false);
                          _showErrorSnackBar(state.message);
                        }
                      },
                      child: PrimaryButton(
                        text: 'Salvar',
                        onPressed: _isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  final authState = context.read<AuthCubit>().state;
                                  if (authState is AuthSuccess) {
                                    context.read<AuthCubit>().updateUser(
                                      authState.accessToken,
                                      authState.id,
                                      {
                                        'currentPassword': _currentPasswordController.text,
                                        'password': _newPasswordController.text,
                                        'confirmPassword': _confirmPasswordController.text,
                                      },
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}