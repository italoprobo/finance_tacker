import 'package:dio/dio.dart';
import '../../../models/client.dart';

class ClientRepository {
  final Dio dio;

  ClientRepository(this.dio);

  Future<List<Client>> fetchClients(String token) async {
    try {
      final response = await dio.get(
        '/clients',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Client.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar clientes');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<Client> createClient(String token, Map<String, dynamic> clientData) async {
    try {
      final response = await dio.post(
        '/clients',
        data: clientData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 201) {
        return Client.fromJson(response.data);
      } else {
        throw Exception('Falha ao criar cliente');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }
}
