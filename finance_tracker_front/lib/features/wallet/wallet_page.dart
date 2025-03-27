import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/extensions/currency_extension.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:finance_tracker_front/features/home/widget/transaction_skeleton.dart';
import 'package:finance_tracker_front/features/home/widget/animated_transaction_tile.dart';
import 'package:finance_tracker_front/models/transaction.dart';
import 'package:go_router/go_router.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    _tabController.addListener(() {
      setState(() {});
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final transactionCubit = context.read<TransactionCubit>();

      if (authState is AuthSuccess && authState.accessToken.isNotEmpty) {
        transactionCubit.fetchUserTransactions(authState.accessToken);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: Stack(
        children: [
          const AppHeader(title: 'Carteira'),
          Positioned(
            top: 164.h,
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
                  Padding(
                    padding: EdgeInsets.fromLTRB(28.w, 32.h, 28.w, 0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Valor Total',
                              style: AppTextStyles.mediumText16w500.copyWith(
                                color: const Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 4),
                            BlocBuilder<TransactionCubit, TransactionState>(
                              builder: (context, state) {
                                if (state is TransactionsLoading) {
                                  return Container(
                                    width: 200.w,
                                    height: 40.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.antiFlashWhite,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  );
                                }

                                double totalBalance = 0;
                                if (state is TransactionsSuccess) {
                                  totalBalance = state.transactions.fold(
                                    0,
                                    (sum, t) => sum + (t.type == 'entrada' ? t.amount : -t.amount),
                                  );
                                }
                                return Text(
                                  totalBalance.toCurrency(),
                                  style: AppTextStyles.mediumText30.copyWith(
                                    color: const Color(0xFF222222),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: Colors.transparent,
                            dividerColor: Colors.transparent,
                            labelColor: AppColors.darkGrey,
                            unselectedLabelColor: AppColors.darkGrey,
                            tabs: [
                              Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 0
                                        ? AppColors.antiFlashWhite
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text('Transações'),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _tabController.index == 1
                                        ? AppColors.antiFlashWhite
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Text('Cartões de Crédito'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _TransactionsList(),
                        const Center(child: Text('Em desenvolvimento')),
                      ],
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

class _TransactionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionsInitial || state is TransactionsLoading) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 28.w),
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
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            itemCount: state.transactions.length,
            itemBuilder: (context, index) {
              final transaction = state.transactions[index];
              final bool isIncome = transaction.type == 'entrada';
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
                                        child: Icon(
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
                                        content: Text(
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
                                        child: Icon(
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
          );
        }
        return const Center(child: Text("Erro desconhecido"));
      },
    );
  }
}