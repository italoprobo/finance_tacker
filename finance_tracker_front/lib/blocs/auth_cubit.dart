import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated, loading, error }

class AuthCubit extends Cubit<AuthStatus> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthStatus.unauthenticated);

  Future<void> login(String email, String password) async {
    print('Iniciando login para o email: $email');
    emit(AuthStatus.loading);

    try {
      await _authRepository.login(email, password);
      print('Login realizado com sucesso!');
      emit(AuthStatus.authenticated);
    } catch (e) {
      print('Erro no login: $e');
      emit(AuthStatus.error);
    }
  }

  Future<void> logout() async {
    print('Deslogando...');
    await _authRepository.logout();
    emit(AuthStatus.unauthenticated);
    print('Logout realizado com sucesso.');
  }

  Future<void> checkLogin() async {
    print('Verificando login...');
    final isLogged = await _authRepository.isLogged();
    print('Usuário está logado? $isLogged');
    if (isLogged) {
      emit(AuthStatus.authenticated);
    } else {
      emit(AuthStatus.unauthenticated);
    }
  }
}
