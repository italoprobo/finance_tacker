import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../infrastructure/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  
  AuthCubit({required this.authRepository}) : super(AuthInitial());
  
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.register(name, email, password, confirmPassword);
      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
  
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final token = await authRepository.login(email, password);
      emit(AuthSuccess(token));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
