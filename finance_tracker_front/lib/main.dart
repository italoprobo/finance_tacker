import 'package:finance_tracker_front/features/home/application/home_cubit.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api_cliente.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/transactions/data/transactions_repository.dart'; // ✅ Importa o TransactionsRepository
import 'app_router.dart';

void main() {
  final apiClient = ApiClient(); 
  final transactionsRepository = TransactionsRepository(apiClient.dio); 

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(apiClient.dio)),
        BlocProvider(create: (context) => HomeCubit()),
        BlocProvider(create: (context) => CardCubit(apiClient.dio)),
        BlocProvider(create: (context) => TransactionCubit(transactionsRepository)), 
      ],
      child: MyApp(apiClient: apiClient, transactionsRepository: transactionsRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final TransactionsRepository transactionsRepository; 

  const MyApp({super.key, required this.apiClient, required this.transactionsRepository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finance AI',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
