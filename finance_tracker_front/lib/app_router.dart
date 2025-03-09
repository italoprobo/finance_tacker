import 'package:finance_tracker_front/features/signup/sign_up_page.dart';
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
      builder: (context, state) => const SignUpPage(),
    ),
  ],
);
