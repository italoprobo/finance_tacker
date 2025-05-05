import 'package:finance_tracker_front/common/utils/dialogs_helper.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        await context.read<AuthCubit>().updateProfileImage(image);
      }
    } catch (e) {
      if (!mounted) return;
      DialogsHelper.showErrorBottomSheet(
        context, 
        'Erro ao atualizar imagem de perfil: ${e.toString()}'
      );
    }
  }

  Widget _buildProfileImage(AuthSuccess state) {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.white,
            backgroundImage: (state.profileImage != null && state.profileImage!.isNotEmpty)
                ? NetworkImage('http://localhost:3000/uploads/profile-images/${state.profileImage}', scale: 1.0)
                : null,
            child: (state.profileImage == null || state.profileImage!.isEmpty)
                ? const Icon(Icons.person, size: 40, color: AppColors.purple)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is AuthLoading) {
            DialogsHelper.showLoadingDialog(context);
          } else {
            DialogsHelper.hideLoadingDialog(context);
          }

          if (state is AuthInitial) {
            context.goNamed('login');
          } else if (state is AuthFailure) {
            DialogsHelper.showErrorBottomSheet(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthSuccess) {
            return Stack(
              children: [
                const AppHeader(title: "Perfil", hasOptions: false),
                Positioned(
                  top: 115.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          _buildProfileImage(state),
                          SizedBox(height: 12.h),
                          // Nome do usuário
                          Text(
                            state.name,
                            style: AppTextStyles.mediumText16w500.copyWith(
                              color: AppColors.white,
                              fontSize: 16
                            ),
                          ),
                          SizedBox(height: 4.h),
                          // Email do usuário
                          Text(
                            state.email,
                            style: AppTextStyles.smalltext.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                              fontSize: 12
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Lista de opções
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          decoration: const BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(32),
                              topRight: Radius.circular(32),
                            ),
                          ),
                          child: ListView(
                            children: [
                              SizedBox(height: 24.h),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.person_outline, color: AppColors.purple, size: 20),
                                title: const Text('Alterar nome', style: AppTextStyles.mediumText16w500),
                                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.purple, size: 16),
                                onTap: () {
                                  context.pushNamed(
                                    'edit-name',
                                    extra: state.name,
                                  );
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.lock_outline, color: AppColors.purple, size: 20),
                                title: const Text('Alterar senha', style: AppTextStyles.mediumText16w500),
                                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.purple, size: 16),
                                onTap: () {
                                  context.pushNamed('edit-password');
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.people_outline, color: AppColors.purple, size: 20),
                                title: const Text('Meus Clientes', style: AppTextStyles.mediumText16w500),
                                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.purple, size: 16),
                                onTap: () {
                                  context.pushNamed('clients');
                                },
                              ),
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.logout, color: AppColors.expense, size: 20),
                                title: Text('Sair', style: AppTextStyles.mediumText16w500.copyWith(color: AppColors.expense)),
                                onTap: () {
                                  context.read<AuthCubit>().logout();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}