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
      _reportsCubit = context.read<ReportsCubit>();
      _reportsCubit?.getReportsByPeriod(
        period: ReportPeriod.values[_periodTabController.index],
      );
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
                  height: 280.h,
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
      child: TabBar(
        controller: _periodTabController,
        onTap: (index) {
          _reportsCubit?.getReportsByPeriod(
            period: ReportPeriod.values[index],
          );
        },
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.purple,
        ),
        indicatorColor: Colors.transparent,
        indicatorWeight: 0,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(8.0),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.purple,
        indicatorSize: TabBarIndicatorSize.tab,
        physics: const NeverScrollableScrollPhysics(),
        tabs: ReportPeriod.values.map((period) => 
          Container(
            width: 90.w,
            height: 40.h,
            alignment: Alignment.center,
            child: Text(
              period.displayName,
              style: AppTextStyles.smalltext13.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ).toList(),
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
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 16.w,
            ),
            child: LineChart(
            LineChartData(
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 4,
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tooltipMargin: 16,
                    maxContentWidth: 120,
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'R\$ ${spot.y.toStringAsFixed(2)}',
                          AppTextStyles.mediumText16w600.copyWith(
                            color: AppColors.purple,
                          ),
                        );
                      }).toList();
                    },
                    getTooltipColor: (spot) => Colors.white,
                    tooltipBorder: const BorderSide(
                      color: AppColors.purple,
                      width: 0.5,
                    ),
                  ),
                  touchSpotThreshold: 50,
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: null,
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
                      reservedSize: 35,
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

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            text,
                            style: AppTextStyles.inputLabelText.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                minX: _reportsCubit?.selectedPeriod == ReportPeriod.day ? 0 : 1,
                maxX: _reportsCubit?.selectedPeriod == ReportPeriod.day 
                    ? 23 
                    : _reportsCubit?.selectedPeriod == ReportPeriod.week 
                        ? 7 
                        : _reportsCubit?.selectedPeriod == ReportPeriod.month 
                            ? DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day.toDouble()
                            : 12,
                minY: state.valueSpots.map((e) => e.y).reduce(min) < 0 
                    ? state.valueSpots.map((e) => e.y).reduce(min) * 1.2 - 100
                    : -10,
                maxY: state.valueSpots.map((e) => e.y).reduce(max) * 1.2 + 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: state.valueSpots,
                    isCurved: true,
                    color: AppColors.purple,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    preventCurveOverShooting: true,
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
                          AppColors.purple.withOpacity(0.15),
                          AppColors.purple.withOpacity(0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 0,
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ],
                ),
                clipData: const FlClipData.all(),
              ),
              duration: const Duration(milliseconds: 500),
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

        final reportsWithTransactions = state.reports.where((report) => 
          report.totalIncome > 0 || report.totalExpense > 0
        ).toList();

        if (reportsWithTransactions.isEmpty) {
          return const Center(
            child: Text('Nenhuma transação encontrada neste período'),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: reportsWithTransactions.length,
          itemBuilder: (context, index) {
            final report = reportsWithTransactions[index];
            
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
                          style: AppTextStyles.mediumText16w500,
                        ),
                        if (report.periodStart != null)
                          Text(
                            '${report.periodStart!.day}/${report.periodStart!.month}/${report.periodStart!.year}',
                            style: AppTextStyles.smalltextw400.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
              Text(
                    'R\$ ${(report.totalIncome - report.totalExpense).toStringAsFixed(2)}',
                    style: AppTextStyles.mediumText16w600.copyWith(
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