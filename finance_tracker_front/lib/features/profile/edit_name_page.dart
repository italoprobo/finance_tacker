import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/custom_text_form_field.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/common/widgets/custom_snackbar.dart';
import 'package:go_router/go_router.dart';

class EditNamePage extends StatefulWidget {
  final String currentName;

  const EditNamePage({
    super.key,
    required this.currentName,
  });

  @override
  State<EditNamePage> createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> with CustomSnackBar {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.currentName;
  }

  @override
  void dispose() {
    _nameController.dispose();
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
      text: 'Nome atualizado com sucesso!',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AppHeader(
            title: "Alterar Nome",
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
                    CustomTextFormField(
                      padding: EdgeInsets.zero,
                      controller: _nameController,
                      labelText: 'NOME',
                      hintText: 'Digite seu nome',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Este campo não pode estar vazio';
                        }
                        return null;
                      },
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
                        isLoading: _isLoading,
                        onPressed: _isLoading 
                          ? null 
                          : () {
                              if (_formKey.currentState!.validate()) {
                                final authState = context.read<AuthCubit>().state;
                                if (authState is AuthSuccess) {
                                  final newName = _nameController.text.trim();
                                  context.read<AuthCubit>().updateUser(
                                    authState.accessToken,
                                    authState.id,
                                    {'name': newName},
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