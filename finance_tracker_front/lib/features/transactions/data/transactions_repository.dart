import 'package:dio/dio.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';

class TransactionsRepository {
  final Dio dio;

  TransactionsRepository(this.dio);

  Future<List<TransactionModel>> fetchUserTransactions(String token) async {
    try {
      final response = await dio.get(
        '/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        if (data.isEmpty) {
          return [];
        }

        List<TransactionModel> transactions =
        data.map((e) => TransactionModel.fromJson(e)).toList();
        return transactions;
      } else {
        throw Exception("Erro ao buscar transações");
      }
    } catch (e) {
      throw Exception("Falha na conexão com o servidor");
    }
  }

  Future<void> addTransaction(
      String token, Map<String, dynamic> transactionData) async {
    try { 
      final response = await dio.post(
        '/transactions',
        data: transactionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 201) {
      } else {
        throw Exception("Erro ao adicionar transação");
      }
    } catch (e) {
      throw Exception("Erro ao adicionar transação");
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
