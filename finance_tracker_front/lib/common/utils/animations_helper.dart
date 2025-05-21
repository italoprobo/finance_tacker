import 'package:flutter/material.dart';

class AnimationsHelper {
  // Duração padrão para animações
  static const Duration defaultDuration = Duration(milliseconds: 300);
  
  // Curva padrão para animações
  static const Curve defaultCurve = Curves.easeInOut;

  // Animação de fade para widgets
  static Widget fadeTransition({
    required Widget child,
    required Animation<double> animation,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  // Animação de slide
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    final Offset begin = direction == SlideDirection.right
        ? const Offset(-1.0, 0.0)
        : const Offset(1.0, 0.0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: defaultCurve,
      )),
      child: child,
    );
  }
}

enum SlideDirection { left, right }