import 'package:finance_tracker_front/features/home/home_page.dart';
import 'package:finance_tracker_front/features/login/login.dart';
import 'package:finance_tracker_front/features/profile/profile_page.dart';
import 'package:finance_tracker_front/features/reports/reports_page.dart';
import 'package:finance_tracker_front/features/signup/sign_up_page.dart';
import 'package:finance_tracker_front/features/transactions/transactions_page.dart';
import 'package:finance_tracker_front/features/wallet/wallet_page.dart';
import 'package:finance_tracker_front/features/transactions/presentation/add_transaction_page.dart';
import 'package:go_router/go_router.dart';
import 'features/splash/splash_page.dart';
import 'features/onboarding/onboarding_page.dart'; 

// ver sobre o fluxo de paginas depois com o chat
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash', 
  routes: [
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
      name: 'home', 
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      name: 'reports', 
      path: '/reports',
      builder: (context, state) => const ReportsPage(),
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
    GoRoute(
      name: 'add-transaction', 
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionPage(),
    ),
  ],
);
