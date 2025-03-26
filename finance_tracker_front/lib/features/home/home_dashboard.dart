// ignore_for_file: deprecated_member_use
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/primary_button.dart';
import 'package:finance_tracker_front/common/widgets/custom_bottom_sheet.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/features/home/widget/balance_card.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> with CustomModalSheetMixin {
  double get textScaleFactor =>
      MediaQuery.of(context).size.width < 360 ? 0.7 : 1.0;
  double get iconSize => MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final transactionCubit = context.read<TransactionCubit>();

      if (authState is AuthSuccess && authState.accessToken.isNotEmpty) {
        transactionCubit.fetchUserTransactions(authState.accessToken);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    return Scaffold(body: BlocBuilder<CardCubit, CardState>(
      builder: (context, state) {
        if (state is CardLoading || state is CardInitial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CardFailure) {
          return Center(child: Text(state.message));
        }

        if (state is CardSuccess) {
        if (state.cards.isEmpty){
          return const Center(child: Text("Nenhum cartão encontrado"));
        } else {
        //double totalBalance = state.cards.fold(0, (sum, card) => sum + (card.currentBalance));
          return Stack(
            children: [
              const AppHeader(),
              Positioned(
                left: 24.w,
                right: 25.w,
                top: 145.h,
                child: BlocBuilder<TransactionCubit, TransactionState>(
                  builder: (context, transactionState) {
                    double totalIncome = 0;
                    double totalExpense = 0;

                    if (transactionState is TransactionsSuccess) {
                      totalIncome = transactionState.transactions
                          .where((t) => t.type == 'entrada')
                          .fold(0, (sum, t) => sum + t.amount);
                      totalExpense = transactionState.transactions
                          .where((t) => t.type == 'saida')
                          .fold(0, (sum, t) => sum + t.amount);
                    }

                    double totalBalanceTransaction = totalIncome - totalExpense;

                    return BalanceCard(
                      totalBalance: totalBalanceTransaction,
                      totalIncome: totalIncome,
                      totalExpense: totalExpense,
                      textScaleFactor: textScaleFactor,
                      iconSize: iconSize,
                    );
                  },
                ),
              ),
              Positioned(
                  top: 410.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionsInitial || state is TransactionsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TransactionsFailure) {
                        return Center(child: Text(state.message));
                      }

                      if (state is TransactionsSuccess) {
                      if (state.transactions.isEmpty) {
                        return const Center(child: Text("Nenhuma transação encontrada."));
                      } else {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Histórico de Transações",
                                    style: AppTextStyles.buttontext
                                        .apply(color: AppColors.black),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.goNamed('transactions');
                                    },
                                    child: Text(
                                      "Ver todas",
                                      style: AppTextStyles.smalltextw400
                                          .apply(color: AppColors.inputcolor),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.zero,
                                itemCount: state.transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = state.transactions[index];
                                  final bool isIncome = transaction.type == 'entrada';
                                  final color = isIncome
                                      ? AppColors.income
                                      : AppColors.expense;
                                  final value = isIncome
                                      ? '+ R\$ ${transaction.amount.toStringAsFixed(2)}'
                                      : '- R\$ ${transaction.amount.toStringAsFixed(2)}';
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    onLongPress: () {
                                      showModalBottomSheet(
                                        context: context,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(24.0),
                                            topRight: Radius.circular(24.0),
                                          ),
                                        ),
                                        builder: (context) => Container(
                                          padding: const EdgeInsets.all(24.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'O que deseja fazer?',
                                                style: AppTextStyles.mediumText20.copyWith(
                                                  color: AppColors.purple,
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      context.pop();
                                                      context.pushNamed('edit-transaction', extra: transaction);
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
                                                  GestureDetector(
                                                    onTap: () {
                                                      context.pop();
                                                      showCustomModalBottomSheet(
                                                        context: context,
                                                        content: 'Deseja realmente excluir esta transação?',
                                                        actions: [
                                                          PrimaryButton(
                                                            text: 'Cancelar',
                                                            onPressed: () => context.pop(),
                                                          ),
                                                          PrimaryButton(
                                                            text: 'Excluir',
                                                            onPressed: () {
                                                              final authState = context.read<AuthCubit>().state;
                                                              if (authState is AuthSuccess) {
                                                                context.read<TransactionCubit>().deleteTransaction(
                                                                  transaction.id,
                                                                  authState.accessToken,
                                                                );
                                                              }
                                                              context.pop();
                                                            },
                                                          ),
                                                        ],
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
                                                          child: const Icon(
                                                            Icons.delete,
                                                            color: AppColors.error,
                                                            size: 24,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 8),
                                                        Text(
                                                          'Excluir',
                                                          style: AppTextStyles.smalltextw400.copyWith(
                                                            color: AppColors.error,
                                                          ),
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
                                    },
                                    leading: Container(
                                      decoration: const BoxDecoration(
                                        color: AppColors.antiFlashWhite,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8.0)),
                                      ),
                                      padding: const EdgeInsets.all(8.0),
                                      child: const Icon(
                                          Icons.monetization_on_outlined),
                                    ),
                                    title: Text(
                                      transaction.description,
                                      style: AppTextStyles.mediumText16w500,
                                    ),
                                    subtitle: Text(
                                      "${transaction.date.day}/${transaction.date.month}/${transaction.date.year}",
                                      style: AppTextStyles.smalltext13,
                                    ),
                                    trailing: Text(
                                      value,
                                      style: AppTextStyles.buttontext
                                          .apply(color: color),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        );
                      }
                      }
                    return const Center(child: Text("Erro desconhecido transaction"));
                    },
                  ))
            ],
          );
        }
      }
    return const Center(child: Text("Erro desconhecido card"));
    }
    ));
  }
}
