import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/auth_cubit.dart';
import '../infrastructure/auth_repository.dart';

class RegisterScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  
  RegisterScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(authRepository: AuthRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Registrar')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthSuccess) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Senha'),
                      obscureText: true,
                    ),
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        final confirmPassword = confirmPasswordController.text;
                        context.read<AuthCubit>().register(name, email, password, confirmPassword);
                      },
                      child: const Text('Registrar'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Já tem conta? Faça login'),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
