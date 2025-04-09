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
    
    for (var report in reports) {
        // Calcular o valor líquido (receitas - despesas)
        final value = report.totalIncome - report.totalExpense;
        
        double x;
        switch (_selectedPeriod) {
            case ReportPeriod.day:
                x = report.periodStart!.hour.toDouble();
                break;
            case ReportPeriod.week:
                x = report.periodStart!.weekday.toDouble() - 1;
                break;
            case ReportPeriod.month:
                x = report.periodStart!.day.toDouble() - 1;
                break;
            case ReportPeriod.year:
                x = report.periodStart!.month.toDouble() - 1;
                break;
        }
        
        print('Adicionando spot: x=$x, value=$value, date=${report.periodStart}');
        spots.add(FlSpot(x, value));
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