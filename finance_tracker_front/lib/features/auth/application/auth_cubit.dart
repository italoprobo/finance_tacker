import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estados 
abstract class AuthState extends Equatable {
  @override
  List<Object> get props => [];

}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String accessToken;
  final String name;
  AuthSuccess({required this.accessToken, required this.name});
  @override
  List<Object> get props => [accessToken, name];
}

class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);

  @override
  List<Object> get props => [message];
}

//Autenticação
class AuthCubit extends Cubit<AuthState> {
  final Dio dio;

  AuthCubit(this.dio) : super(AuthInitial()) {
    _loadToken();
  }

    Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final name = prefs.getString('name') ?? '';

    if (accessToken != null && accessToken.isNotEmpty) {
      emit(AuthSuccess(accessToken: accessToken, name: name));
    }
  }

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
        print('Resposta do servidor: ${response.toString()}');
        // o mais correto seria redirecionar o usuário para login ao invés de emitir um AuthSuccess
        emit(AuthSuccess(accessToken: "", name: name)); 
      } else {
        emit(AuthFailure("Erro no cadastro"));
      }
    } catch (e) {
      print('Erro no cadastro: $e');
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }

Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await dio.post('/auth/login', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 201) {
        final data = response.data;
        final String accessToken = data['accessToken']; 
        final String name = data['name']; 

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('name', name);

        emit(AuthSuccess(accessToken: accessToken, name: name)); 
      } else {
        print('Resposta do servidor: ${response.toString()}');
        emit(AuthFailure("Erro no login"));
      }
    } catch (e) {
      print('Erro no login: $e');
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }

}
