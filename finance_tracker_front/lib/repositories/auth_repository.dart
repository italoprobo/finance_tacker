import '../data/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<String> login(String email, String password) async {
    print('Chamando AuthService para login...');
    final result = await _authService.login(email, password);
    final token = result['token'];

    print('Token recebido: $token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);

    print('Token salvo no SharedPreferences.');
    return token;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    print('Removendo token...');
    await prefs.remove('jwt_token');
    print('Token removido.');
  }

  Future<bool> isLogged() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenExists = prefs.containsKey('jwt_token');
    print('Token existe no SharedPreferences? $tokenExists');
    return tokenExists;
  }
}
