import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/transactions/presentation/home_screen.dart';
import 'features/splash/splash_page.dart';
import 'features/onboarding/onboarding_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      name: '/login',
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      name: '/register',
      path: '/register',
      builder: (context, state) => RegisterScreen(),
    ),
    GoRoute(
      name: '/home',
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: '/splash',
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: '/onboarding',
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
  ],
);
