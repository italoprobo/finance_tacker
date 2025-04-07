import 'package:dio/dio.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/models/report.dart';

class ReportsRepository {
  final Dio _apiClient;

  ReportsRepository(this._apiClient);

  Future<List<Report>> getReports(ReportPeriod period) async {
    try {
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
        '/reports',
        queryParameters: {
          'start_date': start.toIso8601String(),
          'end_date': end.toIso8601String(),
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => Report.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Erro ao buscar relatórios: $e');
    }
  }
}