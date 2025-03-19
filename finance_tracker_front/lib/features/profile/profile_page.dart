import 'package:finance_tracker_front/common/utils/dialogs_helper.dart';
import 'package:finance_tracker_front/features/auth/application/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: 
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthLoading) {
              DialogsHelper.showLoadingDialog(context);
            } else {
              DialogsHelper.hideLoadingDialog(context);
            }

            if (state is AuthInitial) {
              context.goNamed('login');
            } else if (state is AuthFailure) {
              DialogsHelper.showErrorBottomSheet(context, state.message);
            }
          },
          builder: (context, state) {
          return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Page'),
            TextButton(onPressed: () async {
              await context.read<AuthCubit>().logout();
            }, child: const Text("Logout"))
          ],
        );
          },
        )
      ),
    );
  }
}