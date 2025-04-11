import 'dart:math' as math;

import 'package:bloc/bloc.dart';
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
    Map<int, double> values = {};
    
    print('\n=== Processando dados do gráfico ===');
    print('Período selecionado: $_selectedPeriod');
    print('Número de reports: ${reports.length}');
    
    if (_selectedPeriod == ReportPeriod.day) {
      // Inicializar todas as horas com 0
      for (int i = 0; i < 24; i++) {
        values[i] = 0;
      }
      
      for (var report in reports) {
        if (report.periodStart == null) continue;
        final value = report.totalIncome - report.totalExpense;
        final hour = report.periodStart!.hour;
        values[hour] = value; // Substituir valor ao invés de somar
        print('Hora ${hour}h: R\$ $value');
      }
    } else {
      int maxPeriod = _selectedPeriod == ReportPeriod.week 
          ? 7 
          : _selectedPeriod == ReportPeriod.month 
              ? DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day 
              : 12;
      
      // Inicializar todos os períodos com 0
      for (int i = 1; i <= maxPeriod; i++) {
        values[i] = 0;
      }
      
      for (var report in reports) {
        if (report.periodStart == null) continue;
        final value = report.totalIncome - report.totalExpense;
        int key;
        
        switch (_selectedPeriod) {
          case ReportPeriod.week:
            key = report.periodStart!.weekday;
            break;
          case ReportPeriod.month:
            key = report.periodStart!.day;
            break;
          case ReportPeriod.year:
            key = report.periodStart!.month;
            break;
          default:
            continue;
        }
        
        values[key] = value; // Substituir valor ao invés de somar
        print('${_selectedPeriod == ReportPeriod.year ? monthName(key.toDouble()) : 
              _selectedPeriod == ReportPeriod.week ? dayName(key.toDouble()) : 
              'Dia $key'}: R\$ $value');
      }
    }
    
    // Remover a normalização dos valores
    spots.addAll(
      values.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
        ..sort((a, b) => a.x.compareTo(b.x))
    );
    
    print('\nSpots gerados:');
    spots.forEach((spot) => print('x: ${spot.x}, y: ${spot.y}'));
    
    return spots;
  }

  String monthName(double value) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final index = value.toInt() - 1;
    if (index < 0 || index >= months.length) return '';
    return months[index];
  }

  String dayName(double value) {
    final days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final index = value.toInt() - 1;
    if (index < 0 || index >= days.length) return '';
    return days[index];
  }
}