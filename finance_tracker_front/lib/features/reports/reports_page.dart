import 'dart:math';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/features/reports/reports_state.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';

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
    Sizes.init(context);
    return Scaffold(
      body: Stack(
        children: [
          const AppHeader(
            title: "Estatísticas", 
            hasOptions: false,
            isWhiteTheme: true,
          ),
          Positioned(
            top: 150.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: _buildPeriodTabs(),
                ),
                SizedBox(height: 9.h),
                SizedBox(
                  height: 220.h,
                  child: _buildChartArea(),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Principais Transações',
                        style: AppTextStyles.buttontext.apply(color: AppColors.black),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(
                          Icons.sort,
                          color: AppColors.purple,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: _buildTransactionsList(),
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
      padding: EdgeInsets.symmetric(horizontal: 24.w),
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

          print('ValueSpots: ${state.valueSpots}');
          
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 4.h,
              horizontal: 16.w,
            ),
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
                      interval: 1,
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
                maxX: (state.valueSpots.length - 1).toDouble(),
                minY: state.valueSpots.map((e) => e.y).reduce(min) < 0 
                    ? state.valueSpots.map((e) => e.y).reduce(min) * 1.1
                    : 0,
                maxY: state.valueSpots.map((e) => e.y).reduce(max) * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: state.valueSpots,
                    isCurved: true,
                    color: AppColors.purple,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.purple,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
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

  Widget _buildTransactionsList() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsSuccess) {
          return const SizedBox.shrink();
        }

        if (state.reports.isEmpty) {
          return const Center(
            child: Text('Nenhuma transação encontrada neste período'),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: state.reports.length,
          itemBuilder: (context, index) {
            final report = state.reports[index];
            
            String title;
            switch (_reportsCubit?.selectedPeriod) {
              case ReportPeriod.day:
                title = '${report.periodStart?.hour}h';
                break;
              case ReportPeriod.week:
                title = _reportsCubit?.dayName(report.periodStart?.weekday.toDouble() ?? 0.0) ?? '';
                break;
              case ReportPeriod.month:
                title = 'Dia ${report.periodStart?.day}';
                break;
              case ReportPeriod.year:
                title = _reportsCubit?.monthName((report.periodStart?.month ?? 1).toDouble() - 1) ?? '';
                break;
              default:
                title = report.type;
            }

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (report.periodStart != null)
                          Text(
                            '${report.periodStart!.day}/${report.periodStart!.month}/${report.periodStart!.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    'R\$ ${(report.totalIncome - report.totalExpense).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: report.totalIncome - report.totalExpense >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}