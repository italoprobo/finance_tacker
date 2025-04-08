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
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case ReportPeriod.week:
          // Encontrar o início da semana (segunda-feira)
          final daysToSubtract = now.weekday - 1;
          startDate = DateTime(now.year, now.month, now.day - daysToSubtract);
          endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
          break;
        case ReportPeriod.month:
          startDate = DateTime(now.year, now.month, 1);
          // Último dia do mês atual
          endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          break;
        case ReportPeriod.year:
          startDate = DateTime(now.year, 1, 1);
          endDate = DateTime(now.year, 12, 31, 23, 59, 59);
          break;
      }

      print('Buscando transações de ${startDate.toIso8601String()} até ${endDate.toIso8601String()}');

      final response = await _apiClient.get(
        '/transactions',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'user_id': userId,
        },
      );

      print('Resposta da API: ${response.data}');

      if (response.data is List) {
        final List<dynamic> transactions = response.data;
        return _processTransactions(transactions, period, startDate);
      }

      return [];
    } catch (e) {
      print('Erro ao buscar relatórios: $e');
      throw Exception('Erro ao buscar relatórios: $e');
    }
  }

  List<Report> _processTransactions(List<dynamic> transactions, ReportPeriod period, DateTime baseDate) {
    final Map<String, Report> reportMap = {};

    // Inicializar períodos vazios
    switch (period) {
      case ReportPeriod.day:
        for (int hour = 0; hour < 24; hour++) {
          final date = DateTime(
            baseDate.year,
            baseDate.month,
            baseDate.day,
            hour,
          );
          reportMap[hour.toString()] = Report(
            id: hour.toString(),
            type: 'diario',
            periodStart: date,
            periodEnd: date.add(const Duration(hours: 1)),
            totalIncome: 0,
            totalExpense: 0,
          );
        }
        break;

      case ReportPeriod.week:
        for (int day = 0; day < 7; day++) {
          final date = baseDate.add(Duration(days: day));
          reportMap[date.weekday.toString()] = Report(
            id: date.weekday.toString(),
            type: 'diario',
            periodStart: date,
            periodEnd: date.add(const Duration(days: 1)),
            totalIncome: 0,
            totalExpense: 0,
          );
        }
        break;

      case ReportPeriod.month:
        final daysInMonth = DateTime(baseDate.year, baseDate.month + 1, 0).day;
        for (int day = 1; day <= daysInMonth; day++) {
          final date = DateTime(baseDate.year, baseDate.month, day);
          reportMap[day.toString()] = Report(
            id: day.toString(),
            type: 'mensal',
            periodStart: date,
            periodEnd: date.add(const Duration(days: 1)),
            totalIncome: 0,
            totalExpense: 0,
          );
        }
        break;

      case ReportPeriod.year:
        for (int month = 1; month <= 12; month++) {
          final date = DateTime(baseDate.year, month, 1);
          reportMap[month.toString()] = Report(
            id: month.toString(),
            type: 'anual',
            periodStart: date,
            periodEnd: DateTime(baseDate.year, month + 1, 0),
            totalIncome: 0,
            totalExpense: 0,
          );
        }
        break;
    }

    // Processar transações
    for (var transaction in transactions) {
      try {
        final date = DateTime.parse(transaction['date']);
        String key;

        switch (period) {
          case ReportPeriod.day:
            key = date.hour.toString();
            break;
          case ReportPeriod.week:
            key = date.weekday.toString();
            break;
          case ReportPeriod.month:
            key = date.day.toString();
            break;
          case ReportPeriod.year:
            key = date.month.toString();
            break;
        }

        if (reportMap.containsKey(key)) {
          final amount = double.tryParse(transaction['amount'].toString()) ?? 0;
          final type = transaction['type'].toString().toLowerCase();
          
          if (type == 'income' || type == 'receita') {
            final report = reportMap[key]!;
            final newReport = Report(
              id: report.id,
              type: report.type,
              periodStart: report.periodStart,
              periodEnd: report.periodEnd,
              totalIncome: report.totalIncome + amount,
              totalExpense: report.totalExpense,
            );
            reportMap[key] = newReport;
          } else {
            final report = reportMap[key]!;
            final newReport = Report(
              id: report.id,
              type: report.type,
              periodStart: report.periodStart,
              periodEnd: report.periodEnd,
              totalIncome: report.totalIncome,
              totalExpense: report.totalExpense + amount,
            );
            reportMap[key] = newReport;
          }
        }
      } catch (e) {
        print('Erro ao processar transação: $e');
        continue;
      }
    }

    // Ordenar relatórios por data
    final reports = reportMap.values.toList()
      ..sort((a, b) => a.periodStart!.compareTo(b.periodStart!));

    print('Relatórios processados: ${reports.length}');
    reports.forEach((report) {
      print('Período: ${report.periodStart} - Receita: ${report.totalIncome} - Despesa: ${report.totalExpense}');
    });

    return reports;
  }
}