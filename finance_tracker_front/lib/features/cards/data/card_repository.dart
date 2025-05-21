import 'package:dio/dio.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';

class CardRepository {
  final Dio dio;

  CardRepository(this.dio);

  Future<void> updateCardBalance(String token, String cardId, double amount) async {
    try {
      final response = await dio.put(
        '/card/$cardId/balance',
        data: {
          'amount': amount,
          'operation': 'credit_purchase',
          'updateLimit': true,
          'updateInvoice': true,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Erro ao atualizar saldo do cartão');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(e.response?.data['message'] ?? 'Erro ao atualizar saldo do cartão');
      }
      throw Exception('Erro ao atualizar saldo do cartão');
    }
  }
} 