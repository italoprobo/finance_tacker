import 'dart:math';
import 'package:finance_tracker_front/common/di/di.dart';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/features/reports/reports_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late final TabController _periodTabController;
  ReportsCubit? _reportsCubit;

  @override
  void initState() {
    super.initState();
    
    _periodTabController = TabController(
      initialIndex: ReportPeriod.month.index,
      length: ReportPeriod.values.length,
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _reportsCubit = context.read<ReportsCubit>();
        _reportsCubit?.getReportsByPeriod();
      });
    });
  }

  @override
  void dispose() {
    _periodTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AppHeader(
            title: "Estatísticas", 
            hasOptions: false,
            isWhiteTheme: true,
          ),
          Positioned(
            top: 150,
            left: 8,
            right: 8,
            bottom: 0,
            child: Column(
              children: [
                _buildPeriodTabs(),
                const SizedBox(height: 32),
                Flexible(
                  child: _buildChartArea(),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Principais Transações',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(
                        Icons.sort,
                        color: AppColors.purple,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: _buildSummary(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: StatefulBuilder(
        builder: (context, setState) {
          return TabBar(
            controller: _periodTabController,
            onTap: (index) => setState(() {
              _reportsCubit?.getReportsByPeriod(
                period: ReportPeriod.values[index],
              );
            }),
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: AppColors.purple,
            ),
            splashBorderRadius: BorderRadius.circular(8.0),
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.purple,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: ReportPeriod.values
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        e.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: e == _reportsCubit?.selectedPeriod
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }

  Widget _buildChartArea() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.purple,
            ),
          );
        }

        if (state is ReportsSuccess) {
          if (state.valueSpots.isEmpty) {
            return const Center(
              child: Text('Nenhuma transação encontrada neste período'),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 24.0,
            ),
            child: AspectRatio(
              aspectRatio: 1.70,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipRoundedRadius: 8,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipBorder: const BorderSide(
                        color: AppColors.purple,
                        width: 1,
                      ),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            'R\$ ${spot.y.toStringAsFixed(2)}',
                            const TextStyle(
                              color: AppColors.purple,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withOpacity(0.1),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _reportsCubit?.interval ?? 1,
                        getTitlesWidget: (value, meta) {
                          final period = _reportsCubit?.selectedPeriod;
                          String text = '';
                          
                          switch (period) {
                            case null:
                              text = '';
                              break;
                            case ReportPeriod.day:
                              text = '${value.toInt()}h';
                              break;
                            case ReportPeriod.week:
                              text = _reportsCubit!.dayName(value);
                              break;
                            case ReportPeriod.month:
                              text = value.toInt().toString();
                              break;
                            case ReportPeriod.year:
                              text = _reportsCubit!.monthName(value);
                              break;
                          }

                          return Text(
                            text,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minX: 0,
                  maxX: state.valueSpots.isEmpty 
                      ? 0 
                      : state.valueSpots.length.toDouble() - 1,
                  minY: state.valueSpots.isEmpty 
                      ? 0 
                      : state.valueSpots.map((e) => e.y).reduce(min),
                  maxY: state.valueSpots.isEmpty 
                      ? 0 
                      : state.valueSpots.map((e) => e.y).reduce(max) * 1.1,
                  lineBarsData: [
                    LineChartBarData(
                      spots: state.valueSpots,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      curveSmoothness: 0.35,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.purple.withOpacity(0.20),
                            AppColors.purple.withOpacity(0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is ReportsFailure) {
          return Center(
            child: Text('Erro: ${state.message}'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummary() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsSuccess) return const SizedBox.shrink();

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Receitas',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${state.totalIncome.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Total Despesas',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'R\$ ${state.totalExpense.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Text(
                      'Saldo',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${(state.totalIncome - state.totalExpense).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: state.totalIncome - state.totalExpense >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}