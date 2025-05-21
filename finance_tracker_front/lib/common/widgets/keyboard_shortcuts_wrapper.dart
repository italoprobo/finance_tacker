import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class KeyboardShortcutsWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardShortcutsWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyT): 
            const NavigationIntent('add-transaction'),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyC): 
            const NavigationIntent('add-card'),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyU): 
            const NavigationIntent('add-client'),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit1): 
            const NavigationIntent('home'),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit2): 
            const NavigationIntent('wallet'),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.digit3): 
            const NavigationIntent('clients'),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          NavigationIntent: NavigationAction(context),
        },
        child: child,
      ),
    );
  }
}

class NavigationIntent extends Intent {
  final String routeName;
  const NavigationIntent(this.routeName);
}

class NavigationAction extends Action<NavigationIntent> {
  final BuildContext context;
  NavigationAction(this.context);

  @override
  void invoke(NavigationIntent intent) {
    context.pushNamed(intent.routeName);
  }
}