import 'package:flutter/material.dart';

enum BottomAppBarItem { home, stats, wallet, profile }

extension PageControllerExt on PageController {
  static int _selectedIndex = 0;

  int get selectedBottomAppBarItemIndex {
    final newIndex = hasClients && page != null ? page!.toInt() : _selectedIndex;
    if (newIndex > 1) {
      return (newIndex + 1);
    }
    return newIndex;
  }

  set setBottomAppBarItemIndex(int newIndex) {
    _selectedIndex = newIndex;
  }

  void navigateTo(BottomAppBarItem item) {
    if (!hasClients) return; // Evita erro se o PageController ainda não estiver inicializado

    switch (item) {
      case BottomAppBarItem.home:
        jumpToPage(BottomAppBarItem.home.index);
        break;
      case BottomAppBarItem.stats:
        jumpToPage(BottomAppBarItem.stats.index);
        break;
      case BottomAppBarItem.wallet:
        jumpToPage(BottomAppBarItem.wallet.index);
        break;
      case BottomAppBarItem.profile:
        jumpToPage(BottomAppBarItem.profile.index);
        break;
    }
  }
}
