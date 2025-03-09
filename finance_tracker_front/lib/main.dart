import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api_cliente.dart';
import 'features/auth/application/auth_cubit.dart';
import 'app_router.dart';

void main() {
  final apiClient = ApiClient(); 
  runApp(MyApp(apiClient: apiClient));
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient; 

  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(apiClient.dio), 
      child: MaterialApp.router(
        title: 'Finance AI',
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

