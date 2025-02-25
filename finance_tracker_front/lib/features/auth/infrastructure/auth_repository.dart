import '../../../core/api_cliente.dart';

class AuthRepository {
  final ApiClient apiClient;
  
  AuthRepository({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<String> register(String name, String email, String password, String confirmPassword) async {
    final response = await apiClient.dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });
    return response.data['token'];
  }

  Future<String> login(String email, String password) async {
    final response = await apiClient.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data['token'];
  }
}
