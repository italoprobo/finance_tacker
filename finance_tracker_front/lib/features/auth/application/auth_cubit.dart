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
  final String email;

  AuthSuccess({
    required this.accessToken,
    required this.name,
    required this.id,
    required this.email,
  });

  @override
  List<Object> get props => [accessToken, name, id, email];
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
    final email = prefs.getString('userEmail') ?? '';

    if (accessToken != null && accessToken.isNotEmpty) {
      emit(AuthSuccess(accessToken: accessToken, name: name, id: id, email: email));
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
        final loginResponse = await dio.post('/auth/login', data: {
          "email": email,
          "password": password,
        });

        if (loginResponse.statusCode == 201) {
          final loginData = loginResponse.data;
          final String accessToken = loginData['accessToken'];
          
          final String token = accessToken;
          final parts = token.split('.');
          if (parts.length != 3) {
            emit(AuthFailure("Token inválido"));
            return;
          }

          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(decoded);
          
          final String userId = payloadMap['id'] ?? '';
          final String userEmail = payloadMap['email'] ?? '';

          if (userId.isEmpty) {
            emit(AuthFailure("ID do usuário não encontrado"));
            return;
          }
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('name', name);
          await prefs.setString('userId', userId);
          await prefs.setString('userEmail', userEmail);
          await prefs.setString('userName', name);

          emit(AuthSuccess(accessToken: accessToken, name: name, id: userId, email: userEmail));
        } else {
          emit(AuthFailure("Erro ao fazer login após registro"));
        }
      } else {
        emit(AuthFailure("Erro no cadastro"));
      }
    } catch (e) {
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
        final data = response.data;// Debug log

        final String accessToken = data['accessToken'];
        final String name = data['name'];
        
        final String token = accessToken;
        final parts = token.split('.');
        if (parts.length != 3) {
          emit(AuthFailure("Token inválido"));
          return;
        }

        final payload = parts[1];
        final normalized = base64Url.normalize(payload);
        final decoded = utf8.decode(base64Url.decode(normalized));
        final payloadMap = json.decode(decoded);
        
        final String id = payloadMap['id'] ?? '';
        final String userEmail = payloadMap['email'] ?? '';

        if (id.isEmpty) {
          emit(AuthFailure("ID do usuário não encontrado"));
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        await prefs.setString('name', name);
        await prefs.setString('userId', id);
        await prefs.setString('userEmail', userEmail);

        emit(AuthSuccess(accessToken: accessToken, name: name, id: id, email: userEmail));
      } else {
        emit(AuthFailure("Erro no login"));
      }
    } catch (e) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        emit(AuthFailure("Email ou senha incorretos"));
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.connectionError) {
        emit(AuthFailure("Falha na conexão com o servidor. Verifique sua internet."));
      } else if (e.response?.data['message'] != null) {
        emit(AuthFailure(e.response?.data['message']));
      } else {
        emit(AuthFailure("Ocorreu um erro ao fazer login"));
      }
    } else {
      emit(AuthFailure("Ocorreu um erro inesperado"));
    }
  }
}

  Future<void> logout() async {
    emit(AuthLoading());

    try{
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('name');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure("Erro ao fazer logout"));
    }
  }

  Future<void> updateUser(String token, String userId, Map<String, dynamic> userData) async {
    if (state is AuthLoading) return;
    
    emit(AuthLoading());
    try {
      final response = await dio.patch(
        '/users/$userId',
        data: jsonEncode(userData),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String name = data['name'];
        final String email = data['email'];
        final String id = data['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', name);

        emit(AuthSuccess(
          accessToken: token,
          name: name,
          id: id,
          email: email,
        ));
      } else {
        emit(AuthFailure("Erro ao atualizar usuário"));
      }
    } catch (e) {
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }

}
