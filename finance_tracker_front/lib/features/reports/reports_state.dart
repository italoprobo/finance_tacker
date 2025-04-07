import 'package:equatable/equatable.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finance_tracker_front/models/report.dart';

abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {}

class ReportsLoading extends ReportsState {}

class ReportsSuccess extends ReportsState {
  final List<Report> reports;
  final List<FlSpot> valueSpots;
  final double totalIncome;
  final double totalExpense;

  ReportsSuccess({
    required this.reports,
    required this.valueSpots,
    required this.totalIncome,
    required this.totalExpense,
  });

  @override
  List<Object?> get props => [reports, valueSpots, totalIncome, totalExpense];
}

class ReportsFailure extends ReportsState {
  final String message;

  ReportsFailure(this.message);

  @override
  List<Object?> get props => [message];
}