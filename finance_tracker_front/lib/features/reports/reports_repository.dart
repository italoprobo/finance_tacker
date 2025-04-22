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
          startDate = DateTime(now.year, now.month, now.day).toUtc();
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999).toUtc();
          break;
        case ReportPeriod.week:
          startDate = DateTime(now.year, now.month, now.day - now.weekday + 1).toUtc();
          endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)).toUtc();
          break;
        case ReportPeriod.month:
          startDate = DateTime(now.year, now.month, 1).toUtc();
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999).toUtc();
          break;
        case ReportPeriod.year:
          startDate = DateTime(now.year, 1, 1).toUtc();
          endDate = DateTime(now.year, 12, 31, 23, 59, 59, 999).toUtc();
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

      print('Status code: ${response.statusCode}');
      print('Resposta da API: ${response.data}');

      // Verificar se a resposta é válida
      if (response.data == null) {
        throw Exception('Resposta vazia do servidor');
      }

      if (response.data is List) {
        final List<dynamic> reports = response.data;
        if (reports.isEmpty) {
          print('Nenhuma transação encontrada para o período');
        } else {
          print('Encontradas ${reports.length} transações');
        }
        return _processTransactions(reports, period, startDate);
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
        // Garantir que as datas são interpretadas como UTC antes de converter para local
        final periodStart = reportData['period_start'] != null 
          ? DateTime.parse(reportData['period_start']).toUtc().toLocal()
          : null;
        final periodEnd = reportData['period_end'] != null 
          ? DateTime.parse(reportData['period_end']).toUtc().toLocal()
          : null;

        final report = Report(
          id: reportData['id'],
          type: reportData['type'],
          periodStart: periodStart,
          periodEnd: periodEnd,
          totalIncome: (reportData['total_income'] ?? 0).toDouble(),
          totalExpense: (reportData['total_expense'] ?? 0).toDouble(),
          details: reportData['details'],
        );
        
        print('Report processado: id=${report.id}, data=${report.periodStart}, income=${report.totalIncome}, expense=${report.totalExpense}');
        if (report.details != null) {
          print('Transactions: ${(report.details!['transactions'] as List?)?.length ?? 0}');
        }
        reports.add(report);
      } catch (e) {
        print('Erro ao processar report: $e');
        print('Dados do report: $reportData'); 
        continue;
      }
    }

    reports.sort((a, b) => a.periodStart!.compareTo(b.periodStart!));
    
    print('Total de reports processados: ${reports.length}');
    return reports;
  }
}