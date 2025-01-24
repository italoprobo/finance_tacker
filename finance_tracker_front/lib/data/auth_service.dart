import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String _baseUrl = 'http://localhost:3000';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');
    print('Enviando POST para $url com email: $email');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    print('Resposta da API: ${response.statusCode}');
    if (response.statusCode == 200) {
      print('Login bem-sucedido. Retorno: ${response.body}');
      return jsonDecode(response.body);
    } else {
      print('Falha no login. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Falha no login');
    }
  }
}
