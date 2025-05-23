import 'package:finance_tracker_front/common/mixin/swipeable_page_mixin.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/models/creditcard.dart';
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
import 'package:finance_tracker_front/common/widgets/custom_modal_bottom_sheet.dart';
import 'package:finance_tracker_front/common/widgets/quick_actions_sheet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> with SingleTickerProviderStateMixin, SwipeablePageMixin {
  late TabController _tabController;
  String? _selectedCategory;
  DateTime? _selectedDate;
  final bool _isLoading = false;

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
        transactionCubit.initialize(authState.accessToken, authState.id);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    final filtered = transactions.where((transaction) {
      bool matchesCategory = _selectedCategory == null || 
                           transaction.categoryId == _selectedCategory;
      bool matchesDate = _selectedDate == null ||
                        transaction.date.year == _selectedDate!.year &&
                        transaction.date.month == _selectedDate!.month &&
                        transaction.date.day == _selectedDate!.day;
      return matchesCategory && matchesDate;
    }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => const QuickActionsSheet(),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: GestureDetector(
        onHorizontalDragEnd: handleSwipe,
        child: Stack(
          children: [
            AppHeader(
              title: 'Carteira',
              hasOptions: true,
              onOptionsPressed: _showQuickActions,
              onBackPressed: () => context.goNamed('home'),
            ),
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
                      padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 0),
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
                                    final filteredTransactions = _filterTransactions(state.transactions);
                                    totalBalance = filteredTransactions.fold(
                                      0,
                                      (sum, t) {
                                        return sum + (t.type == 'entrada' ? t.amount : -t.amount.abs());
                                      },
                                    );
                                    // Arredonda para 2 casas decimais para evitar problemas de precisão
                                    totalBalance = double.parse(totalBalance.toStringAsFixed(2));
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
                          //const SizedBox(height: 4),
                          // TransactionFilters(
                          //   selectedCategory: _selectedCategory,
                          //   selectedDate: _selectedDate,
                          //   onCategoryChanged: (category) {
                          //     setState(() {
                          //       _selectedCategory = category;
                          //     });
                          //   },
                          //   onDateChanged: (date) {
                          //     setState(() {
                          //       _selectedDate = date;
                          //     });
                          //   },
                          // ),
                          //const SizedBox(height: 16),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const _TransactionsList(),
                          _buildCreditCardsList(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreditCardsList() {
    return BlocBuilder<CardCubit, CardState>(
      builder: (context, state) {
        if (state is CardInitial || state is CardLoading) {
          return Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meus Cartões',
                      style: AppTextStyles.buttontext.apply(color: AppColors.black),
                    ),
                    Container(
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
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Lista de Cartões com Loading
              Expanded(
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 9.h),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Logo do cartão
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.antiFlashWhite,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppColors.purple,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Detalhes do cartão
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Carregando...',
                                  style: AppTextStyles.mediumText16w600,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '••••',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Indicador de carregamento
                          Container(
                            width: 24,
                            height: 24,
                            margin: const EdgeInsets.only(left: 12),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.expense),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is CardFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.expense,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar cartões:\n${state.message}',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.smalltextw400,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final authState = context.read<AuthCubit>().state;
                    if (authState is AuthSuccess) {
                      context.read<CardCubit>().fetchUserCards(authState.accessToken);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Tentar novamente',
                    style: AppTextStyles.smalltextw400.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is CardSuccess) {
          if (state.cards.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.credit_card_off,
                    color: AppColors.grey,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhum cartão de crédito cadastrado',
                    style: AppTextStyles.smalltextw400,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.pushNamed('add-card');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Adicionar cartão',
                      style: AppTextStyles.smalltextw400.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                await context.read<CardCubit>().fetchUserCards(authState.accessToken);
              }
            },
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Meus Cartões',
                        style: AppTextStyles.buttontext.apply(color: AppColors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.pushNamed('add-card');
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
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: state.cards.length,
                    itemBuilder: (context, index) {
                      final card = state.cards[index];
                      return CreditCardItem(
                        card: card,
                        isPending: false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text("Erro desconhecido"));
      },
    );
  }
}

class _TransactionsList extends StatelessWidget {
  final String? selectedCategory;
  final DateTime? selectedDate;

  const _TransactionsList({
    this.selectedCategory,
    this.selectedDate,
  });

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    return transactions.where((transaction) {
      bool matchesCategory = selectedCategory == null || 
                           transaction.categoryId == selectedCategory;
      bool matchesDate = selectedDate == null ||
                        transaction.date.year == selectedDate!.year &&
                        transaction.date.month == selectedDate!.month &&
                        transaction.date.day == selectedDate!.day;
      return matchesCategory && matchesDate;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        if (state is TransactionsInitial || state is TransactionsLoading) {
          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 5.w),
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
          final filteredTransactions = _filterTransactions(state.transactions);
          
          if (filteredTransactions.isEmpty) {
            return const Center(child: Text("Nenhuma transação encontrada."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              final authState = context.read<AuthCubit>().state;
              if (authState is AuthSuccess) {
                await context.read<TransactionCubit>().fetchUserTransactions(authState.accessToken);
              }
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                final bool isIncome = transaction.type == 'entrada';
                final value = isIncome
                    ? transaction.amount.toCurrencyWithSign()
                    : '- ${transaction.amount.abs().toCurrency()}';

                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.pushNamed(
                          'transaction-details',
                          extra: Transaction.fromModel(transaction),
                        );
                      },
                      child: AnimatedTransactionTile(
                        transaction: Transaction.fromModel(transaction),
                        isIncome: isIncome,
                        value: value,
                        onTap: () {
                          context.pushNamed(
                            'transaction-details',
                            extra: Transaction.fromModel(transaction),
                          );
                        },
                        onLongPress: () {
                          showCustomModalBottomSheet(
                            context: context,
                            title: 'O que deseja fazer?',
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                        showCustomModalBottomSheet(
                                          context: context,
                                          title: 'Confirmar exclusão',
                                          content: const Text(
                                            'Tem certeza que deseja excluir esta transação?',
                                            style: AppTextStyles.smalltextw400,
                                            textAlign: TextAlign.center,
                                          ),
                                          buttonText: 'Excluir',
                                          buttonColor: AppColors.expense,
                                          onPressed: () async {
                                            try {
                                              final authState = context.read<AuthCubit>().state;
                                              if (authState is AuthSuccess) {
                                                await context.read<TransactionCubit>().deleteTransaction(
                                                  authState.accessToken,
                                                  transaction.id,
                                                );
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Erro ao excluir transação'),
                                                    backgroundColor: AppColors.expense,
                                                  ),
                                                );
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
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text("Erro desconhecido"));
      },
    );
  }
}

class OperationFeedback extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final VoidCallback onRetry;

  const OperationFeedback({
    Key? key,
    required this.isSuccess,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSuccess ? AppColors.income.withOpacity(0.1) : AppColors.expense.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: isSuccess ? AppColors.income : AppColors.expense,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.mediumText16w500.copyWith(
              color: isSuccess ? AppColors.income : AppColors.expense,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Tentar novamente',
              style: AppTextStyles.mediumText16w500.copyWith(
                color: isSuccess ? AppColors.income : AppColors.expense,
              ),
            ),
          ),
        ],
      ),
    );
  }
}