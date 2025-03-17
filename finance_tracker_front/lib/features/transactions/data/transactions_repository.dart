import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';

class TransactionsRepository {
  final Dio dio;

  TransactionsRepository(this.dio);

  Future<List<TransactionModel>> fetchUserTransactions(String token) async {
    try {
      print('📡 Buscando transações do usuário...');
      print('🔑 Token enviado: $token');

      final response = await dio.get(
        '/transactions',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      print('📩 Resposta do servidor: ${response.statusCode}');
      print('📊 Dados recebidos: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        if (data.isEmpty) {
          print('⚠️ Nenhuma transação encontrada.');
          return [];
        }

        List<TransactionModel> transactions =
            data.map((e) => TransactionModel.fromJson(e)).toList();
        print('✅ Transações carregadas com sucesso!');
        return transactions;
      } else {
        print('❌ Erro ao buscar transações. Status code: ${response.statusCode}');
        throw Exception("Erro ao buscar transações");
      }
    } catch (e) {
      print('❌ Falha na conexão com o servidor: $e');
      throw Exception("Falha na conexão com o servidor");
    }
  }

  Future<void> addTransaction(
      String token, Map<String, dynamic> transactionData) async {
    try { 
      log('📝 Adicionando nova transação...');
      log('🔑 Token enviado: $token');
      log('📊 Dados enviados: $transactionData');

      final response = await dio.post(
        '/transactions',
        data: transactionData,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      log('📩 Resposta do servidor: ${response.statusCode}');
      log('📊 Dados recebidos: ${response.data}');

      if (response.statusCode == 201) {
        log('✅ Transação adicionada com sucesso!');
      } else {
        log('❌ Erro ao adicionar transação. Status code: ${response.statusCode}');
        throw Exception("Erro ao adicionar transação");
      }
    } catch (e) {
      log('❌ Falha ao adicionar transação: $e');
      throw Exception("Erro ao adicionar transação");
    }
  }
}
