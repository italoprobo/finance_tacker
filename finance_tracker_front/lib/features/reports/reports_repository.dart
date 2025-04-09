import 'package:dio/dio.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/models/report.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportsRepository {
  final Dio _apiClient;

  ReportsRepository(this._apiClient);

  Future<List<Report>> getReports(ReportPeriod period) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      final userId = prefs.getString('userId');
      
      print('=== Iniciando busca de relatórios ===');
      print('Token: ${token?.substring(0, 10)}...'); 
      print('UserId: $userId');

      if (token == null || userId == null) {
        throw Exception('Usuário não autenticado');
      }

      _apiClient.options.headers['Authorization'] = 'Bearer $token';

      // Calcular datas baseado no período
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      switch (period) {
        case ReportPeriod.day:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
          break;
        case ReportPeriod.week:
          // Encontrar o início da semana (segunda-feira)
          startDate = DateTime(now.year, now.month, now.day - now.weekday + 1);
          endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case ReportPeriod.month:
          startDate = DateTime(now.year, now.month, 1);
          // Último dia do mês atual
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
          break;
        case ReportPeriod.year:
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999);
          break;
      }

      print('Buscando transações:');
      print('Período: ${period.toString()}');
      print('Data início: ${startDate.toIso8601String()}');
      print('Data fim: ${endDate.toIso8601String()}');

      final response = await _apiClient.get(
        '/reports/by-period',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'user_id': userId,
        },
      );

      print('Resposta da API: ${response.data}');

      if (response.data is List) {
        final List<dynamic> transactions = response.data;
        if (transactions.isEmpty) {
          print('Nenhuma transação encontrada para o período');
        } else {
          print('Encontradas ${transactions.length} transações');
        }
        return _processTransactions(transactions, period, startDate);
      }

      return [];
    } catch (e) {
      print('Erro detalhado:');
      if (e is DioException) {
        print('Status code: ${e.response?.statusCode}');
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
      }
      throw Exception('Erro ao buscar relatórios: $e');
    }
  }

  List<Report> _processTransactions(List<dynamic> data, ReportPeriod period, DateTime baseDate) {
    final reports = <Report>[];
    
    print('Processando dados recebidos...'); 

    for (var reportData in data) {
        try {
            final report = Report(
                id: reportData['id'],
                type: reportData['type'],
                periodStart: DateTime.parse(reportData['period_start']),
                periodEnd: DateTime.parse(reportData['period_end']),
                totalIncome: (reportData['total_income'] ?? 0).toDouble(),
                totalExpense: (reportData['total_expense'] ?? 0).toDouble(),
            );
            
            print('Report processado: id=${report.id}, income=${report.totalIncome}, expense=${report.totalExpense}');
            reports.add(report);
        } catch (e) {
            print('Erro ao processar report: $e');
            print('Dados do report: $reportData'); 
            continue;
        }
    }

    // Ordenar por data
    reports.sort((a, b) => a.periodStart!.compareTo(b.periodStart!));
    
    print('Total de reports processados: ${reports.length}');
    return reports;
  }
}