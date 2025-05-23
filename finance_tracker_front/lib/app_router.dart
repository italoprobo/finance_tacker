import 'package:finance_tracker_front/common/di/di.dart';
import 'package:finance_tracker_front/features/assistant/presentation/assistant_page.dart';
import 'package:finance_tracker_front/features/clients/presentation/add_clients_page.dart';
import 'package:finance_tracker_front/features/home/home_page.dart';
import 'package:finance_tracker_front/features/login/login.dart';
import 'package:finance_tracker_front/features/profile/edit_password_page.dart';
import 'package:finance_tracker_front/features/profile/profile_page.dart';
import 'package:finance_tracker_front/features/profile/edit_name_page.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/features/reports/reports_page.dart';
import 'package:finance_tracker_front/features/signup/sign_up_page.dart';
import 'package:finance_tracker_front/features/transactions/transactions_page.dart';
import 'package:finance_tracker_front/features/wallet/wallet_page.dart';
import 'package:finance_tracker_front/features/transactions/presentation/add_transaction_page.dart';
import 'package:finance_tracker_front/features/transactions/presentation/edit_transaction_page.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';
import 'package:finance_tracker_front/models/client.dart';
import 'package:finance_tracker_front/models/transaction.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/application/auth_cubit.dart';
import 'features/splash/splash_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/home/home_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker_front/features/clients/presentation/clients_page.dart';
import 'package:finance_tracker_front/features/clients/application/client_cubit.dart';
import 'package:finance_tracker_front/features/clients/data/client_repository.dart';
import 'package:finance_tracker_front/features/wallet/presentation/add_card_page.dart';
import 'package:finance_tracker_front/features/wallet/presentation/card_details_page.dart';
import 'package:finance_tracker_front/features/wallet/presentation/edit_card_page.dart';
import 'package:finance_tracker_front/features/clients/presentation/client_details_page.dart';
import 'package:finance_tracker_front/features/clients/presentation/edit_client_page.dart';
import 'package:finance_tracker_front/features/transactions/presentation/transaction_details_page.dart';

// Chaves de navegação separadas
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ver sobre o fluxo de paginas depois com o chat
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Rotas fora do ShellRoute (sem barra de navegação)
    GoRoute(
      name: 'splash',
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: 'onboarding',
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      name: 'sign-up',
      path: '/sign-up',
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      name: 'login',
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      name: 'add-transaction',
      path: '/add-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ClientCubit(
              getIt<ClientRepository>(),
            )..loadClients(
                (context.read<AuthCubit>().state as AuthSuccess).accessToken,
              ),
          ),
          BlocProvider(
            create: (context) => getIt<CardCubit>(),
          ),
        ],
        child: const AddTransactionPage(),
      ),
    ),
    GoRoute(
      name: 'edit-transaction',
      path: '/edit-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => BlocProvider(
        create: (context) => ClientCubit(
          getIt<ClientRepository>(),
        )..loadClients(
            (context.read<AuthCubit>().state as AuthSuccess).accessToken,
          ),
        child: EditTransactionPage(
          transaction: state.extra as TransactionModel,
        ),
      ),
    ),
    GoRoute(
      name: 'edit-name',
      path: '/edit-name',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => EditNamePage(
        currentName: state.extra as String,
      ),
    ),
    GoRoute(
      name: 'edit-password',
      path: '/edit-password',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EditPasswordPage(),
    ),
    GoRoute(
      path: '/clients',
      name: 'clients',
      builder: (context, state) => BlocProvider(
        create: (context) => ClientCubit(
          getIt<ClientRepository>(),
        )..loadClients(
            (context.read<AuthCubit>().state as AuthSuccess).accessToken,
          ),
        child: const ClientsPage(),
      ),
    ),
    GoRoute(
      name: 'add-client',
      path: '/add-client',
      builder: (context, state) => BlocProvider(
        create: (context) => ClientCubit(
          getIt<ClientRepository>(),
        ),
        child: const AddClientPage(),
      ),
    ),
    GoRoute(
      name: 'add-card',
      path: '/add-card',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AddCardPage(),
    ),
    GoRoute(
      path: '/card-details',
      name: 'card-details',
      builder: (context, state) => CardDetailsPage(
        card: state.extra as CardModel,
      ),
    ),
    GoRoute(
      path: '/edit-card',
      name: 'edit-card',
      builder: (context, state) => EditCardPage(
        card: state.extra as CardModel,
      ),
    ),
    GoRoute(
      name: 'client-details',
      path: '/client-details',
      builder: (context, state) => BlocProvider(
        create: (context) => ClientCubit(
          getIt<ClientRepository>(),
        ),
        child: ClientDetailsPage(
          client: state.extra as Client,
        ),
      ),
    ),
    GoRoute(
      name: 'edit-client',
      path: '/edit-client',
      builder: (context, state) => BlocProvider(
        create: (context) => ClientCubit(
          getIt<ClientRepository>(),
        ),
        child: EditClientPage(
          client: state.extra as Client,
        ),
      ),
    ),
    GoRoute(
      name: 'transaction-details',
      path: '/transaction-details',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => TransactionDetailsPage(
        transaction: state.extra as Transaction,
      ),
    ),
    GoRoute(
      name: 'assistant',
      path: '/assistant',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AssistantPage(),
    ),
    
    // Rotas dentro do ShellRoute (com barra de navegação)
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => HomePage(child: child),
      routes: [
        GoRoute(
          name: 'home',
          path: '/home',
          builder: (context, state) => const HomeDashboard(),
        ),
        GoRoute(
          name: 'reports',
          path: '/reports',
          builder: (context, state) => BlocProvider(
            create: (context) => getIt<ReportsCubit>(),
            child: const ReportsPage(),
          ),
        ),
        GoRoute(
          name: 'wallet',
          path: '/wallet',
          builder: (context, state) => const WalletPage(),
        ),
        GoRoute(
          name: 'profile',
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          name: 'transactions',
          path: '/transactions',
          builder: (context, state) => const TransactionsPage(),
        ),
      ],
    ),
  ],
);

void navigateToAssistant(BuildContext context) {
  _rootNavigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (contextNav) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<AuthCubit>()),
          BlocProvider.value(value: context.read<CardCubit>()),
          BlocProvider.value(value: context.read<TransactionCubit>()),
        ],
        child: const AssistantPage(),
      ),
      fullscreenDialog: true,
    ),
  );
}
