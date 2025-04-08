import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

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
  final String? profileImage;

  AuthSuccess({
    required this.accessToken,
    required this.name,
    required this.id,
    required this.email,
    this.profileImage,
  });

    AuthSuccess copyWith({
    String? accessToken,
    String? id,
    String? name,
    String? email,
    String? profileImage,
  }) {
    return AuthSuccess(
      accessToken: accessToken ?? this.accessToken,
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
    );
  }
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final name = prefs.getString('name') ?? '';
      final id = prefs.getString('userId') ?? '';
      final email = prefs.getString('userEmail') ?? '';
      final profileImage = prefs.getString('profileImage');

      print('Loading token: $accessToken'); // Debug log

      if (accessToken != null && accessToken.isNotEmpty) {
        emit(AuthSuccess(
          accessToken: accessToken,
          name: name,
          id: id,
          email: email,
          profileImage: profileImage
        ));
      } else {
        emit(AuthInitial());
      }
    } catch (e) {
      print('Erro ao carregar token: $e'); // Debug log
      emit(AuthInitial());
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

          emit(AuthSuccess(accessToken: accessToken, name: name, id: userId, email: userEmail, profileImage: ''));
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
      // Login normal
      final response = await dio.post('/auth/login', data: {
        "email": email,
        "password": password,
      });

      if (response.statusCode == 201) {
        final data = response.data;
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

        // Buscar dados completos do usuário incluindo a imagem
        try {
          final userResponse = await dio.get(
            '/users/$id',
            options: Options(
              headers: {
                'Authorization': 'Bearer $accessToken',
              },
            ),
          );

          if (userResponse.statusCode == 200) {
            final userData = userResponse.data;
            final String? profileImage = userData['profileImage'];

            // Salvar todos os dados nas preferências
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('accessToken', accessToken);
            await prefs.setString('name', name);
            await prefs.setString('userId', id);
            await prefs.setString('userEmail', userEmail);
            if (profileImage != null) {
              await prefs.setString('profileImage', profileImage);
            }

            emit(AuthSuccess(
              accessToken: accessToken,
              name: name,
              id: id,
              email: userEmail,
              profileImage: profileImage,
            ));
          } else {
            // Se falhar em obter os dados completos, ainda fazemos login mas sem a imagem
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('accessToken', accessToken);
            await prefs.setString('name', name);
            await prefs.setString('userId', id);
            await prefs.setString('userEmail', userEmail);

            emit(AuthSuccess(
              accessToken: accessToken,
              name: name,
              id: id,
              email: userEmail,
              profileImage: null,
            ));
          }
        } catch (e) {
          // Se falhar em obter os dados completos, ainda fazemos login mas sem a imagem
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('accessToken', accessToken);
          await prefs.setString('name', name);
          await prefs.setString('userId', id);
          await prefs.setString('userEmail', userEmail);

          emit(AuthSuccess(
            accessToken: accessToken,
            name: name,
            id: id,
            email: userEmail,
            profileImage: null,
          ));
        }
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

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('name');
      await prefs.remove('userId');
      await prefs.remove('userEmail');
      await prefs.remove('profileImage');
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
          profileImage: state is AuthSuccess ? (state as AuthSuccess).profileImage : '',
        ));
      } else {
        emit(AuthFailure("Erro ao atualizar usuário"));
      }
    } catch (e) {
      emit(AuthFailure("Falha na conexão com o servidor"));
    }
  }

  Future<void> updateProfileImage(dynamic image) async {
    try {
      final currentState = state;
      if (currentState is! AuthSuccess) {
        throw Exception('Usuário não autenticado');
      }

      if (currentState.accessToken.isEmpty) {
        throw Exception('Token de autenticação inválido');
      }

      emit(AuthLoading());

      FormData formData;
      if (image is XFile) {
        final bytes = await image.readAsBytes();
        String fileName = image.name;

        formData = FormData.fromMap({
          'image': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        });
      } else {
        throw Exception('Formato de imagem inválido');
      }

      final response = await dio.post(
        '/upload/profile-image',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${currentState.accessToken}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final filename = response.data['filename'];
        
        if (filename == null || filename.isEmpty) {
          throw Exception('Nome do arquivo não recebido do servidor');
        }

        // Salvar o nome da imagem no SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImage', filename);

        final newState = AuthSuccess(
          accessToken: currentState.accessToken,
          name: currentState.name,
          id: currentState.id,
          email: currentState.email,
          profileImage: filename,
        );
        emit(newState);
      } else {
        throw Exception('Erro ao fazer upload da imagem');
      }
    } catch (e) {
      print('Erro durante o upload: $e');
      if (state is AuthSuccess) {
        emit(state);
      }
      rethrow;
    }
  }
}
