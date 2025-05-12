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

  Future<void> updateClient(String token, String clientId, Map<String, dynamic> clientData) async {
    final response = await dio.patch(
      '/clients/$clientId',
      data: clientData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar cliente');
    }
  }

  Future<Client> fetchClientDetails(String token, String clientId) async {
    final response = await dio.get(
      '/clients/$clientId',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode == 200) {
      return Client.fromJson(response.data);
    } else {
      throw Exception('Falha ao buscar detalhes do cliente');
    }
  }

  Future<void> deleteClient(String token, String clientId) async {
    try {
      final response = await dio.delete(
        '/clients/$clientId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Falha ao excluir cliente');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 400) {
        throw Exception('Não é possível excluir um cliente que possui transações vinculadas');
      }
      throw Exception('Erro ao excluir cliente: ${e.toString()}');
    }
  }

  Future<void> inactivateClient(String token, String clientId) async {
    final response = await dio.patch(
      '/clients/$clientId',
      data: {
        'status': 'inativo'
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao inativar cliente');
    }
  }

  Future<void> activateClient(String token, String clientId) async {
  final response = await dio.patch(
    '/clients/$clientId',
    data: {
      'status': 'ativo'
    },
    options: Options(
      headers: {
        'Authorization': 'Bearer $token',
      },
    ),
  );

  if (response.statusCode != 200) {
      throw Exception('Falha ao ativar cliente');
    }
  }
}
