import 'package:flutter/material.dart';

mixin SwipeablePageMixin<T extends StatefulWidget> on State<T> {
  late TabController tabController;
  
  void handleSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Deslize para a direita
      if (tabController.index > 0) {
        tabController.animateTo(tabController.index - 1);
      }
    } else if (details.primaryVelocity! < 0) {
      // Deslize para a esquerda
      if (tabController.index < tabController.length - 1) {
        tabController.animateTo(tabController.index + 1);
      }
    }
  }
}