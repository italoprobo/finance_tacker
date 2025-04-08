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
        return 4;
      case ReportPeriod.week:
        return 1;
      case ReportPeriod.month:
        return 5;
      case ReportPeriod.year:
        return 2;
    }
  }

  Future<void> getReportsByPeriod({ReportPeriod? period}) async {
    try {
      emit(ReportsLoading());
      
      if (period != null) {
        _selectedPeriod = period;
      }

      final reports = await repository.getReports(_selectedPeriod);
      _valueSpots = _processChartData(reports);
      final totalIncome = reports.fold(0.0, (sum, report) => sum + report.totalIncome);
      final totalExpense = reports.fold(0.0, (sum, report) => sum + report.totalExpense);

      emit(ReportsSuccess(
        reports: reports,
        valueSpots: _valueSpots,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      ));
    } catch (e) {
      emit(ReportsFailure(e.toString()));
    }
  }

  List<FlSpot> _processChartData(List<Report> reports) {
    final spots = <FlSpot>[];
    
    switch (_selectedPeriod) {
      case ReportPeriod.day:
        for (int hour = 0; hour < 24; hour++) {
          final reportsInHour = reports.where((r) => 
            r.periodStart?.hour == hour).toList();
          final value = reportsInHour.fold(
            0.0,
            (sum, report) => sum + (report.totalIncome - report.totalExpense),
          );
          spots.add(FlSpot(hour.toDouble(), value));
        }
        break;
        
      case ReportPeriod.week:
        for (int day = 0; day < 7; day++) {
          final reportsInDay = reports.where((r) => 
            r.periodStart?.weekday == day + 1).toList();
          final value = reportsInDay.fold(
            0.0,
            (sum, report) => sum + (report.totalIncome - report.totalExpense),
          );
          spots.add(FlSpot(day.toDouble(), value));
        }
        break;
        
      case ReportPeriod.month:
        final daysInMonth = DateTime.now().month == 2 ? 28 : 31;
        for (int day = 1; day <= daysInMonth; day++) {
          final reportsInDay = reports.where((r) => 
            r.periodStart?.day == day).toList();
          final value = reportsInDay.fold(
            0.0,
            (sum, report) => sum + (report.totalIncome - report.totalExpense),
          );
          spots.add(FlSpot(day.toDouble(), value));
        }
        break;
        
      case ReportPeriod.year:
        for (int month = 0; month < 12; month++) {
          final reportsInMonth = reports.where((r) => 
            r.periodStart?.month == month + 1).toList();
          final value = reportsInMonth.fold(
            0.0,
            (sum, report) => sum + (report.totalIncome - report.totalExpense),
          );
          spots.add(FlSpot(month.toDouble(), value));
        }
        break;
    }
    
    return spots;
  }

  String dayName(double value) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    return days[value.toInt() % 7];
  }

  String monthName(double value) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return months[value.toInt() % 12];
  }
}