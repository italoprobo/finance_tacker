import 'package:bloc/bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker_front/features/reports/reports_repository.dart';
import 'package:finance_tracker_front/features/reports/reports_state.dart';
import 'package:finance_tracker_front/models/report.dart';

enum ReportPeriod { day, week, month, year }

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository repository;

  ReportsCubit(this.repository) : super(ReportsInitial());

  final List<ReportPeriod> periods = ReportPeriod.values;
  ReportPeriod _selectedPeriod = ReportPeriod.month;
  ReportPeriod get selectedPeriod => _selectedPeriod;

  List<FlSpot> _valueSpots = [];
  List<FlSpot> get valueSpots => _valueSpots;

  double get interval {
    switch (selectedPeriod) {
      case ReportPeriod.day:
        return 3;
      case ReportPeriod.week:
        return 1;
      case ReportPeriod.month:
        return 5;
      case ReportPeriod.year:
        return 1;
    }
  }

  Future<void> getReportsByPeriod({ReportPeriod? period}) async {
    try {
      emit(ReportsLoading());
      
      if (period != null) {
        _selectedPeriod = period;
      }

      final reports = await repository.getReports(_selectedPeriod);
      print('Reports recebidos: ${reports.length}');
      reports.forEach((report) {
        print('Report: ${report.periodStart} - Receita: ${report.totalIncome} - Despesa: ${report.totalExpense}');
      });

      _valueSpots = _processChartData(reports);
      print('ValueSpots processados: ${_valueSpots.length}');
      _valueSpots.forEach((spot) {
        print('Spot: (${spot.x}, ${spot.y})');
      });

      final totalIncome = reports.fold(0.0, (sum, report) => sum + report.totalIncome);
      final totalExpense = reports.fold(0.0, (sum, report) => sum + report.totalExpense);

      emit(ReportsSuccess(
        reports: reports,
        valueSpots: _valueSpots,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ));
    } catch (e) {
      print('Erro ao buscar relatórios: $e');
      emit(ReportsFailure(e.toString()));
    }
  }

  List<FlSpot> _processChartData(List<Report> reports) {
    if (reports.isEmpty) return [];

    final spots = <FlSpot>[];
    
    switch (_selectedPeriod) {
      case ReportPeriod.day:
        for (int hour = 0; hour < 24; hour++) {
          final report = reports.firstWhere(
            (r) => r.periodStart?.hour == hour,
            orElse: () => Report(
              id: hour.toString(),
              type: 'diario',
              totalIncome: 0,
              totalExpense: 0,
              periodStart: DateTime.now().copyWith(hour: hour),
            ),
          );
          spots.add(FlSpot(hour.toDouble(), report.totalIncome - report.totalExpense));
        }
        break;
        
      case ReportPeriod.week:
        for (int day = 1; day <= 7; day++) {
          final report = reports.firstWhere(
            (r) => r.periodStart?.weekday == day,
            orElse: () => Report(
              id: day.toString(),
              type: 'diario',
              totalIncome: 0,
              totalExpense: 0,
              periodStart: DateTime.now().add(Duration(days: day - DateTime.now().weekday)),
            ),
          );
          spots.add(FlSpot((day - 1).toDouble(), report.totalIncome - report.totalExpense));
        }
        break;
        
      case ReportPeriod.month:
        final now = DateTime.now();
        final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
        for (int day = 1; day <= daysInMonth; day++) {
          final report = reports.firstWhere(
            (r) => r.periodStart?.day == day,
            orElse: () => Report(
              id: day.toString(),
              type: 'mensal',
              totalIncome: 0,
              totalExpense: 0,
              periodStart: DateTime(now.year, now.month, day),
            ),
          );
          spots.add(FlSpot((day - 1).toDouble(), report.totalIncome - report.totalExpense));
        }
        break;
        
      case ReportPeriod.year:
        for (int month = 1; month <= 12; month++) {
          final report = reports.firstWhere(
            (r) => r.periodStart?.month == month,
            orElse: () => Report(
              id: month.toString(),
              type: 'anual',
              totalIncome: 0,
              totalExpense: 0,
              periodStart: DateTime.now().copyWith(month: month),
            ),
          );
          spots.add(FlSpot((month - 1).toDouble(), report.totalIncome - report.totalExpense));
        }
        break;
    }
    
    return spots;
  }

  String dayName(double value) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final index = value.toInt();
    return days[index >= days.length ? 0 : index];
  }

  String monthName(double value) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final index = value.toInt();
    return months[index >= months.length ? 0 : index];
  }
}