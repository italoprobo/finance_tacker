// ignore_for_file: deprecated_member_use
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/extensions/currency_extension.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/common/widgets/custom_bottom_sheet.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/features/home/widget/balance_card.dart';
import 'package:finance_tracker_front/features/home/widget/balance_card_skeleton.dart';
import 'package:finance_tracker_front/features/home/widget/transaction_skeleton.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:finance_tracker_front/features/categories/application/categories_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:finance_tracker_front/features/home/application/home_cubit.dart';
import 'package:finance_tracker_front/features/home/widget/animated_transaction_tile.dart';
import 'package:finance_tracker_front/models/transaction.dart';

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
                    if (transactionState is TransactionsLoading) {
                      return const BalanceCardSkeleton();
                    }

                    double totalIncome = 0;
                    double totalExpense = 0;

                    if (transactionState is TransactionsSuccess) {
                      totalIncome = transactionState.transactions
                          .where((t) => t.type == 'entrada')
                          .fold(0, (sum, t) => sum + t.amount);
                      totalExpense = transactionState.transactions
                          .where((t) => t.type == 'saida')
                          .fold(0, (sum, t) => sum + t.amount.abs());
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
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: const TransactionSkeleton(),
                            );
                          },
                        );
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
                              padding: EdgeInsets.symmetric(horizontal: 8.w),
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
                                      context.read<HomeCubit>().changePage(2);
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
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                itemCount: state.transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = state.transactions[index];
                                  final bool isIncome = transaction.type == 'entrada';
                                  final color = isIncome
                                      ? AppColors.income
                                      : AppColors.expense;
                                  final value = isIncome
                                      ? transaction.amount.toCurrencyWithSign()
                                      : transaction.amount.abs().toCurrency();
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: AnimatedTransactionTile(
                                      transaction: Transaction.fromModel(transaction),
                                      isIncome: isIncome,
                                      value: value,
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
                                                        context.pushNamed(
                                                          'edit-transaction',
                                                          extra: transaction,
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
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) => AlertDialog(
                                                            title: Text(
                                                              'Confirmar exclusão',
                                                              style: AppTextStyles.mediumText20.copyWith(
                                                                color: AppColors.purple,
                                                              ),
                                                            ),
                                                            content: const Text(
                                                              'Tem certeza que deseja excluir esta transação?',
                                                              style: AppTextStyles.smalltextw400,
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () => context.pop(),
                                                                child: Text(
                                                                  'Cancelar',
                                                                  style: AppTextStyles.smalltextw400.copyWith(
                                                                    color: AppColors.inputcolor,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  context.pop();
                                                                  final authState = context.read<AuthCubit>().state;
                                                                  if (authState is AuthSuccess) {
                                                                    context.read<TransactionCubit>().deleteTransaction(
                                                                      authState.accessToken,
                                                                      transaction.id,
                                                                    );
                                                                  }
                                                                },
                                                                child: Text(
                                                                  'Excluir',
                                                                  style: AppTextStyles.smalltextw400.copyWith(
                                                                    color: AppColors.expense,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
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
                                                              color: AppColors.expense,
                                                              size: 24,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            'Excluir',
                                                            style: AppTextStyles.smalltextw400.copyWith(
                                                              color: AppColors.expense,
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
