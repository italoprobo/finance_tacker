import 'dart:developer';

import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/widgets/greetings.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
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

class _HomeDashboardState extends State<HomeDashboard> {
  double get textScaleFactor =>
      MediaQuery.of(context).size.width < 360 ? 0.7 : 1.0;
  double get iconSize => MediaQuery.of(context).size.width < 360 ? 16.0 : 24.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthCubit>().state;
      final transactionCubit = context.read<TransactionCubit>();

      log("🔍 Estado inicial do TransactionCubit: ${transactionCubit.state}");

      if (authState is AuthSuccess && authState.accessToken.isNotEmpty) {
        log('✅ Usuário autenticado! Token: ${authState.accessToken}');
        log('📡 Buscando cartões...');
        transactionCubit.fetchUserTransactions(authState.accessToken);
        log('📡 Buscando transações...');
      } else {
        log('⚠️ Token não encontrado, usuário precisa estar autenticado.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Sizes.init(context);
    return Scaffold(body: BlocBuilder<CardCubit, CardState>(
      builder: (context, state) {
        print('🔎 Estado do CardCubit: ${state.runtimeType}');
        if (state is CardLoading || state is CardInitial) {
          print('⏳ Carregando cartões...');
          return const Center(child: CircularProgressIndicator());
        }

        if (state is CardFailure) {
          print('❌ Erro ao buscar cartões: ${state.message}');
          return Center(child: Text(state.message));
        }

        if (state is CardSuccess) {
        if (state.cards.isEmpty){
          return const Center(child: Text("Nenhum cartão encontrado"));
        } else {
        print('✅ Cartões carregados com sucesso! Quantidade: ${state.cards.length}');
        double totalBalance =
            state.cards.fold(0, (sum, card) => sum + (card.currentBalance));

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: AppColors.gradient,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(500, 30),
                      bottomRight: Radius.elliptical(500, 30),
                    ),
                  ),
                  height: 300.h,
                ),
              ),
              Positioned(
                left: 24.0,
                right: 24.0,
                top: 60.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const GreetingsWidget(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8.h,
                        horizontal: 8.h,
                      ),
                      decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4.0)),
                          // ignore: deprecated_member_use
                          color: AppColors.white.withOpacity(0.06)),
                      child: Stack(
                        alignment: const AlignmentDirectional(0.5, -0.5),
                        children: [
                          const Icon(
                            Icons.notifications_none_outlined,
                            color: AppColors.white,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.notification,
                                borderRadius: BorderRadius.circular(4.0)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                left: 24.w,
                right: 25.w,
                top: 140.h,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 23.w, vertical: 32.h),
                  decoration: const BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.all(Radius.circular(16.0))),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saldo Total',
                                  textScaleFactor: textScaleFactor,
                                  style: AppTextStyles.mediumText22
                                      .apply(color: AppColors.white),
                                ),
                                Text(
                                  'R\$ ${totalBalance.toStringAsFixed(2)}',
                                  textScaleFactor: textScaleFactor,
                                  style: AppTextStyles.mediumText28
                                      .apply(color: AppColors.white),
                                )
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => log('options'),
                            child: PopupMenuButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                Icons.more_horiz,
                                color: AppColors.white,
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  height: 24.0,
                                  child: Text("Item 1"),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 36.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.06),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0))),
                                child: Icon(
                                  Icons.arrow_upward,
                                  color: AppColors.white,
                                  size: iconSize,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Entradas",
                                    textScaleFactor: textScaleFactor,
                                    style: AppTextStyles.mediumText16w500.apply(
                                        color: AppColors.incomesndexpenses),
                                  ),
                                  Text(
                                    "R\$ 1,840.00",
                                    textScaleFactor: textScaleFactor,
                                    style: AppTextStyles.mediumText18
                                        .apply(color: AppColors.white),
                                  )
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                    color: AppColors.white.withOpacity(0.06),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(16.0))),
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: AppColors.white,
                                  size: iconSize,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Saidas",
                                    textScaleFactor: textScaleFactor,
                                    style: AppTextStyles.mediumText16w500.apply(
                                        color: AppColors.incomesndexpenses),
                                  ),
                                  Text(
                                    "R\$ 240.00",
                                    textScaleFactor: textScaleFactor,
                                    style: AppTextStyles.mediumText18
                                        .apply(color: AppColors.white),
                                  )
                                ],
                              )
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: 420.h,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: BlocBuilder<TransactionCubit, TransactionState>(
                    builder: (context, state) {
                      print('🔎 Estado do TransactionCubit: ${state.runtimeType}');

                      if (state is TransactionsInitial || state is TransactionsLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is TransactionsFailure) {
                        print('❌ Erro ao buscar transações: ${state.message}');
                        return Center(child: Text(state.message));
                      }

                      if (state is TransactionsSuccess) {
                      if (state.transactions.isEmpty) {
                        print('⚠️ Nenhuma transação encontrada.');
                        return const Center(child: Text("Nenhuma transação encontrada."));
                      } else {
                      print('✅ Transações carregadas! Quantidade: ${state.transactions.length}');
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
