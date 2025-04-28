import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:finance_tracker_front/features/reports/chartconfig.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker_front/features/reports/reports_repository.dart';
import 'package:finance_tracker_front/features/reports/reports_state.dart';
import 'package:finance_tracker_front/models/report.dart';

enum ReportPeriod { day, week, month, year }

extension ReportPeriodExtension on ReportPeriod {
  String get displayName {
    switch (this) {
      case ReportPeriod.day:
        return 'Diário';
      case ReportPeriod.week:
        return 'Semanal';
      case ReportPeriod.month:
        return 'Mensal';
      case ReportPeriod.year:
        return 'Anual';
    }
  }
}

class ReportsCubit extends Cubit<ReportsState> {
  final ReportsRepository repository;
  late final Map<ReportPeriod, ChartConfig> _chartConfigs;

  ReportsCubit(this.repository) : super(ReportsInitial()) {
    _chartConfigs = {
      ReportPeriod.day: DailyChartConfig(),
      ReportPeriod.week: WeeklyChartConfig(),
      ReportPeriod.month: MonthlyChartConfig(),
      ReportPeriod.year: YearlyChartConfig(),
    };
  }

  final List<ReportPeriod> periods = ReportPeriod.values;
  ReportPeriod _selectedPeriod = ReportPeriod.month;
  ReportPeriod get selectedPeriod => _selectedPeriod;

  List<FlSpot> _valueSpots = [];
  List<FlSpot> get valueSpots => _valueSpots;

  ChartConfig get currentConfig => _chartConfigs[_selectedPeriod]!;

  double get interval => currentConfig.getInterval();
  double get minX => currentConfig.getMinX();
  double get maxX => currentConfig.getMaxX();
  String formatLabel(double value) => currentConfig.formatLabel(value);

  Future<void> getReportsByPeriod({ReportPeriod? period}) async {
    try {
      emit(ReportsLoading());
      
      if (period != null) {
        _selectedPeriod = period;
      }

      print('\n=== Início da Busca de Relatórios ===');
      print('Período selecionado: $_selectedPeriod');

      final reports = await repository.getReports(_selectedPeriod);
      print('\n=== Reports Recebidos ===');
      print('Quantidade total: ${reports.length}');
      print('Detalhes dos reports:');
      for (var report in reports) {
        print('- Data: ${report.periodStart}, Receita: ${report.totalIncome}, Despesa: ${report.totalExpense}, Saldo: ${report.totalIncome - report.totalExpense}');
      }

      _valueSpots = _processChartData(reports);
      
      print('\n=== Spots Processados ===');
      print('Quantidade de spots: ${_valueSpots.length}');
      print('Spots ordenados por X:');
      for (var spot in _valueSpots) {
        String label = formatLabel(spot.x);
        print('- $label: (x: ${spot.x}, y: ${spot.y})');
      }

      emit(ReportsSuccess(
        reports: reports,
        valueSpots: _valueSpots,
        totalIncome: reports.fold(0.0, (sum, report) => sum + report.totalIncome),
        totalExpense: reports.fold(0.0, (sum, report) => sum + report.totalExpense),
      ));
      
      print('\n=== Estado Final ===');
      print('Período: $_selectedPeriod');
      print('Spots gerados: ${_valueSpots.length}');
      print('Reports processados: ${reports.length}');
      
    } catch (e) {
      print('\n=== Erro na Busca de Relatórios ===');
      print('Tipo do erro: ${e.runtimeType}');
      print('Mensagem: $e');
      emit(ReportsFailure(e.toString()));
    }
  }

  List<FlSpot> _processChartData(List<Report> reports) {
    if (reports.isEmpty) return [];
    reports.sort((a, b) => a.periodStart!.compareTo(b.periodStart!));
    return currentConfig.processData(reports);
  }
}