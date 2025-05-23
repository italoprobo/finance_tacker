import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
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
        // Só mostra o botão se o usuário estiver logado
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            if (state is AuthSuccess) {
              return const AssistantFloatingButton();
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}