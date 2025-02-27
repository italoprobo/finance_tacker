import 'package:flutter/painting.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle bigText = const TextStyle(
          fontFamily: 'Inter',
          fontSize: 45.0,
          );
  static const TextStyle mediumText = TextStyle(
          fontFamily: 'Inter',
          fontSize: 36.0,
          fontWeight: FontWeight.w700,
          );
  static const TextStyle smalltext = TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.0,
          fontWeight: FontWeight.w500,
          );
  static const TextStyle buttontext = TextStyle(
          fontFamily: 'Inter',
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          );
}