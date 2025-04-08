import 'package:dio/dio.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportsRepository {
  final Dio _apiClient;

  ReportsRepository(this._apiClient);

  Future<List<Report>> getReports(ReportPeriod period) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      String? token = prefs.getString('accessToken');
      
      if (token == null) {
        print("Token é nulo!");
        throw Exception('Usuário não autenticado');
      }
      
      // Extrair userId do token JWT
      String userId = '';
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          final Map<String, dynamic> data = json.decode(decoded);
          userId = data['id'] as String;
        }
      } catch (e) {
        print('Erro específico ao extrair userId do token: $e');
      }
      
      if (userId.isEmpty) {
        // Tente obter do SharedPreferences como fallback
        userId = prefs.getString('userId') ?? '';
        if (userId.isEmpty) {
          throw Exception('UserId não pode ser determinado');
        }
      }
      
      // Configurar o token de autenticação
      _apiClient.options.headers['Authorization'] = 'Bearer $token';
      
      DateTime start;
      DateTime end;
      DateTime currentDate = DateTime.now();

      switch (period) {
        case ReportPeriod.day:
          start = DateTime(
              currentDate.year, currentDate.month, currentDate.day, 0, 0, 0);
          end = DateTime(
              currentDate.year, currentDate.month, currentDate.day, 23, 59, 59);
          break;
        case ReportPeriod.week:
          start = currentDate.subtract(Duration(days: currentDate.weekday - 1));
          start = DateTime(start.year, start.month, start.day, 0, 0, 0);
          end = start
              .add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case ReportPeriod.month:
          start = DateTime(currentDate.year, currentDate.month, 1, 0, 0, 0);
          end = DateTime(currentDate.year, currentDate.month + 1, 0, 23, 59, 59);
          break;
        case ReportPeriod.year:
          start = DateTime(currentDate.year, 1, 1, 0, 0, 0);
          end = DateTime(currentDate.year, 12, 31, 23, 59, 59);
          break;
      }

      final response = await _apiClient.get(
        '/transactions', 
        queryParameters: {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
        },
      );

      if (response.data is List) {
        final transactions = (response.data as List);
        
        final Map<String, Report> reportMap = {};
        
        for (var transaction in transactions) {
          final date = DateTime.parse(transaction['date']);
          String key;
          
          switch (period) {
            case ReportPeriod.day:
              key = '${date.hour}';
              break;
            case ReportPeriod.week:
              key = '${date.weekday}';
              break;
            case ReportPeriod.month:
              key = '${date.day}';
              break;
            case ReportPeriod.year:
              key = '${date.month}';
              break;
          }
          
          if (!reportMap.containsKey(key)) {
            reportMap[key] = Report(
              id: key,
              type: period.name,
              periodStart: date,
              periodEnd: date,
              totalIncome: 0,
              totalExpense: 0,
            );
          }
          
          double amount = 0.0;
          try {
            if (transaction['amount'] is double) {
              amount = transaction['amount'];
            } else if (transaction['amount'] is int) {
              amount = transaction['amount'].toDouble();
            } else if (transaction['amount'] is String) {
              amount = double.tryParse(transaction['amount']) ?? 0.0;
            }
          } catch (e) {
            amount = 0.0;
          }
          
          final transactionType = transaction['type']?.toString().toLowerCase() ?? '';
          
          reportMap[key] = Report(
            id: reportMap[key]!.id,
            type: reportMap[key]!.type,
            periodStart: reportMap[key]!.periodStart,
            periodEnd: reportMap[key]!.periodEnd,
            totalIncome: (transactionType == 'income' || transactionType == 'receita') 
              ? reportMap[key]!.totalIncome + amount
              : reportMap[key]!.totalIncome,
            totalExpense: (transactionType == 'expense' || transactionType == 'despesa')
              ? reportMap[key]!.totalExpense + amount 
              : reportMap[key]!.totalExpense,
            details: reportMap[key]!.details,
          );
        }
        
        return reportMap.values.toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erro ao buscar relatórios: $e');
    }
  }
}