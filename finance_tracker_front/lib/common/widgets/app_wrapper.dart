import 'package:flutter/material.dart';
import 'package:finance_tracker_front/common/widgets/assistant_floating_button.dart';

class AppWrapper extends StatelessWidget {
  final Widget child;

  const AppWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        const AssistantFloatingButton(),
      ],
    );
  }
}