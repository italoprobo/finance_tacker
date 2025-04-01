import 'package:dio/dio.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'dart:convert';

class TransactionsRepository {
  final Dio dio;

  TransactionsRepository(this.dio);

  Future<List<TransactionModel>> fetchUserTransactions(String token) async {
    try {
      print('Buscando transações com token: ${token.substring(0, 20)}...');
      
      // Decodificar o token para validação
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Token inválido: não contém 3 partes');
        throw Exception("Token inválido");
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      final String userId = payloadMap['id'] ?? '';

      print('ID do usuário extraído do token: $userId');

      if (userId.isEmpty) {
        print('ID do usuário não encontrado no token');
        throw Exception("ID do usuário não encontrado no token");
      }

      final response = await dio.get(
        '/transactions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Resposta do servidor: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        if (data.isEmpty) {
          print('Nenhuma transação encontrada');
          return [];
        }
        
        print('Encontradas ${data.length} transações');
        return data.map((e) => TransactionModel.fromJson(e)).toList();
      } else {
        print('Erro ao buscar transações: ${response.statusCode}');
        throw Exception(response.data['message'] ?? "Erro ao buscar transações");
      }
    } catch (e) {
      print('Erro ao buscar transações: $e');
      if (e is DioException) {
        print('Detalhes do erro Dio: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? "Falha na conexão com o servidor");
      }
      throw Exception("Falha na conexão com o servidor");
    }
  }

  Future<TransactionModel> addTransaction(
      String token, Map<String, dynamic> transactionData) async {
    try { 
      print('Tentando criar transação com dados: $transactionData');
      
      // Decodificar o token para obter o ID do usuário
      final parts = token.split('.');
      if (parts.length != 3) {
        print('Token inválido: não contém 3 partes');
        throw Exception("Token inválido");
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);
      final String userId = payloadMap['id'] ?? '';

      print('ID do usuário extraído do token: $userId');

      if (userId.isEmpty) {
        print('ID do usuário não encontrado no token');
        throw Exception("ID do usuário não encontrado no token");
      }

      // Garantir que o userId da transação seja o mesmo do token
      final dataToSend = {
        ...transactionData,
        'userId': userId,
      };
      print('Dados a serem enviados: $dataToSend');

      final response = await dio.post(
        '/transactions',
        data: dataToSend,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Resposta do servidor: ${response.data}');

      if (response.statusCode == 201) {
        final transaction = TransactionModel.fromJson(response.data);
        if (transaction.userId != userId) {
          print('Erro: Transação criada com userId incorreto');
          print('UserId esperado: $userId');
          print('UserId recebido: ${transaction.userId}');
          throw Exception("Transação criada com usuário incorreto");
        }
        return transaction;
      } else {
        print('Erro ao criar transação: ${response.statusCode}');
        throw Exception(response.data['message'] ?? "Erro ao adicionar transação");
      }
    } catch (e) {
      print('Erro ao criar transação: $e');
      if (e is DioException) {
        print('Detalhes do erro Dio: ${e.response?.data}');
        throw Exception(e.response?.data['message'] ?? "Erro ao adicionar transação");
      }
      throw Exception(e.toString());
    }
  }

  Future<void> deleteTransaction(String token, String transactionId) async {
    try {
      await dio.delete(
        '/transactions/$transactionId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
    } catch (e) {
      throw Exception('Erro ao excluir transação');
    }
  }

  Future<void> updateTransaction(String transactionId, String token, Map<String, dynamic> transactionData) async {
    try {
      final response = await dio.patch(
        '/transactions/$transactionId',
        data: transactionData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Erro ao atualizar transação');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar transação');
      }
      throw Exception('Erro ao atualizar transação');
    }
  }
}
