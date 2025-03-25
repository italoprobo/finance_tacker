import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
  final String id;

  AuthSuccess({
    required this.accessToken,
    required this.name,
    required this.id,
  });

  @override
  List<Object> get props => [accessToken, name, id];
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
    final id = prefs.getString('userId') ?? '';

    if (accessToken != null && accessToken.isNotEmpty) {
      emit(AuthSuccess(accessToken: accessToken, name: name, id: id));
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
        final data = response.data;
        print('Register Response: $data'); // Debug log

        final String accessToken = data['accessToken'];
        
        // Decodificar o token JWT para pegar o ID do usuário
        final String token = accessToken;
        final parts = token.split('.');
        if (parts.length != 3) {
          emit(AuthFailure("Token inválido"));
          return;
        }

        // Decodificar a parte do payload do token
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(decoded);
        
        final String userId = payloadMap['id'] ?? '';

        print('Token: $accessToken'); // Debug log
        print('ID from token: $userId'); // Debug log

        if (userId.isEmpty) {
          emit(AuthFailure("ID do usuário não encontrado"));
          return;
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('name', name);
        await prefs.setString('userId', userId);

        emit(AuthSuccess(accessToken: accessToken, name: name, id: userId));
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
        print('Login Response: $data'); // Debug log

        final String accessToken = data['accessToken'];
        final String name = data['name'];
        
        // Decodificar o token JWT para pegar o ID do usuário
        final String token = accessToken;
        final parts = token.split('.');
        if (parts.length != 3) {
          emit(AuthFailure("Token inválido"));
          return;
        }

        // Decodificar a parte do payload do token
        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(decoded);
        
        final String id = payloadMap['id'] ?? '';
        
        print('Token: $accessToken'); // Debug log
        print('Name: $name'); // Debug log
        print('ID from token: $id'); // Debug log

        if (id.isEmpty) {
          emit(AuthFailure("ID do usuário não encontrado"));
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('name', name);
        await prefs.setString('userId', id);

        emit(AuthSuccess(accessToken: accessToken, name: name, id: id));
      } else {
        emit(AuthFailure("Erro no login"));
      }
    } catch (e) {
      print('Erro no login: $e');
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());

    try{
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('name');
      await prefs.remove('userId');
      emit(AuthInitial());
    } catch (e) {
      print("Erro ao fazer logout: $e");
      emit(AuthFailure("Erro ao fazer logout"));
    }
  }

}
