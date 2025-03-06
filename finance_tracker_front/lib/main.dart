import 'package:finance_tracker_front/common/themes/default_theme.dart';
import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finance AI',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      //theme: defaultTheme
    );
  }
}
