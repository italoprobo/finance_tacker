import 'package:finance_tracker_front/common/widgets/custom_modal_bottom_sheet.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:go_router/go_router.dart';
import '../application/client_cubit.dart';


class ClientsPage extends StatelessWidget {
  const ClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: Stack(
        children: [
          AppHeader(
            title: "Meus Clientes",
            hasOptions: false,
            onBackPressed: () => context.pop(),
          ),
          Positioned(
            top: 150.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 24.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lista de Clientes',
                          style: AppTextStyles.buttontext.apply(color: AppColors.black),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.pushNamed('add-client');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.antiFlashWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: AppColors.purple,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: BlocBuilder<ClientCubit, ClientState>(
                      builder: (context, state) {
                        if (state is ClientLoading) {
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 8.h),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 8.h,
                                    ),
                                    title: Container(
                                      width: 120.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.antiFlashWhite,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 4.h),
                                        Container(
                                          width: 180.w,
                                          height: 16.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.antiFlashWhite,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        Container(
                                          width: 60.w,
                                          height: 16.h,
                                          decoration: BoxDecoration(
                                            color: AppColors.antiFlashWhite,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    trailing: Container(
                                      width: 24.w,
                                      height: 24.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.antiFlashWhite,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        if (state is ClientSuccess) {
                          if (state.clients.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    color: AppColors.grey,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16.h),
                                  const Text(
                                    'Nenhum cliente cadastrado',
                                    style: AppTextStyles.smalltextw400,
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            itemCount: state.clients.length,
                            itemBuilder: (context, index) {
                              final client = state.clients[index];
                              return Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    context.pushNamed('client-details', extra: client);
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(bottom: 8.h),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.2),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      title: Text(
                                        client.name,
                                        style: AppTextStyles.mediumText16w500,
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 4.h),
                                          Text(
                                            'Mensalidade: R\$ ${client.monthly_payment.toStringAsFixed(2)}',
                                            style: AppTextStyles.smalltextw400,
                                          ),
                                          SizedBox(height: 4.h),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8.w,
                                              vertical: 2.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: client.status == 'ativo'
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              client.status == 'ativo' ? 'Ativo' : 'Inativo',
                                              style: AppTextStyles.smalltext13.copyWith(
                                                color: client.status == 'ativo'
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: AppColors.purple,
                                        ),
                                        onPressed: () {
                                          showCustomModalBottomSheet(
                                            context: context,
                                            title: 'O que deseja fazer?',
                                            content: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Botão Editar
                                                GestureDetector(
                                                  onTap: () {
                                                    context.pop();
                                                    context.pushNamed('edit-client', extra: client);
                                                  },
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.iceWhite,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          color: AppColors.purple,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        'Editar',
                                                        style: AppTextStyles.smalltextw400.copyWith(
                                                          color: AppColors.purple,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Botão Ativar/Inativar
                                                GestureDetector(
                                                  onTap: () {
                                                    context.pop();
                                                    showCustomModalBottomSheet(
                                                      context: context,
                                                      title: client.status == 'ativo' ? 'Inativar cliente?' : 'Ativar cliente?',
                                                      content: Text(
                                                        client.status == 'ativo' 
                                                          ? 'O cliente será marcado como inativo e não aparecerá em novas transações, mas seu histórico será mantido.'
                                                          : 'O cliente será reativado e poderá ser incluído em novas transações.',
                                                        style: AppTextStyles.smalltextw400,
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      buttonText: client.status == 'ativo' ? 'Inativar' : 'Ativar',
                                                      buttonColor: client.status == 'ativo' ? AppColors.expense : AppColors.income,
                                                      onPressed: () async {
                                                        final authState = context.read<AuthCubit>().state;
                                                        if (authState is AuthSuccess) {
                                                          try {
                                                            if (client.status == 'ativo') {
                                                              await context.read<ClientCubit>().inactivateClient(
                                                                authState.accessToken,
                                                                client.id,
                                                              );
                                                            } else {
                                                              await context.read<ClientCubit>().activateClient(
                                                                authState.accessToken,
                                                                client.id,
                                                              );
                                                            }
                                                            
                                                            if (context.mounted) {
                                                              Navigator.of(context, rootNavigator: false).pop();
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    client.status == 'ativo' 
                                                                      ? 'Cliente inativado com sucesso!'
                                                                      : 'Cliente ativado com sucesso!'
                                                                  ),
                                                                  backgroundColor: AppColors.purple,
                                                                ),
                                                              );
                                                            }
                                                          } catch (e) {
                                                            if (context.mounted) {
                                                              Navigator.of(context).pop();
                                                              ScaffoldMessenger.of(context).showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                    client.status == 'ativo' 
                                                                      ? 'Erro ao inativar cliente'
                                                                      : 'Erro ao ativar cliente'
                                                                  ),
                                                                  backgroundColor: AppColors.expense,
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        }
                                                      },
                                                    );
                                                  },
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.all(12),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.iceWhite,
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Icon(
                                                          client.status == 'ativo' ? Icons.person_off : Icons.person,
                                                          color: client.status == 'ativo' ? AppColors.expense : AppColors.income,
                                                          size: 24,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 8),
                                                      Text(
                                                        client.status == 'ativo' ? 'Inativar' : 'Ativar',
                                                        style: AppTextStyles.smalltextw400.copyWith(
                                                          color: client.status == 'ativo' ? AppColors.expense : AppColors.income,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        if (state is ClientFailure) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: AppColors.expense,
                                  size: 48,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'Erro ao carregar clientes:\n${state.message}',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.smalltextw400,
                                ),
                              ],
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
