import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Estados 
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

//Autenticação
class AuthCubit extends Cubit<AuthState> {
  final Dio dio;

  AuthCubit(this.dio) : super(AuthInitial());

  Future<void> register(String name, String email, String password, String confirmPassword) async {
    emit(AuthLoading());
    try {
      final response = await dio.post('/auth/register', data: {
        "name": name,
        "email": email,
        "password": password,
        "confirmPassword": confirmPassword,
      });

      if (response.statusCode == 201) {
        emit(AuthSuccess());
      } else {
        emit(AuthFailure("Erro no cadastro:"));
      }
    } catch (e) {
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }
}
