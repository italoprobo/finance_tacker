import 'dart:math';
import 'package:finance_tracker_front/common/constants/app_colors.dart';
import 'package:finance_tracker_front/common/widgets/app_header.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/features/reports/reports_state.dart';
import 'package:finance_tracker_front/models/report.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finance_tracker_front/common/extensions/sizes.dart';
import 'package:finance_tracker_front/common/constants/app_text_styles.dart';
import 'package:finance_tracker_front/features/reports/chartconfig.dart';

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
          
          print("\n=== DEBUG: Renderizando gráfico ===");
          print("Período: ${_reportsCubit?.selectedPeriod}");
          print("minX: ${_reportsCubit?.minX}");
          print("maxX: ${_reportsCubit?.maxX}");
          print("interval: ${_reportsCubit?.interval}");
          print("Spots (${state.valueSpots.length}):");
          for (var spot in state.valueSpots) {
            final label = _reportsCubit?.formatLabel(spot.x) ?? '';
            print("x=${spot.x} ($label), y=${spot.y}");
          }
          
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 16.w,
            ),
            child: LineChart(
            LineChartData(
                lineTouchData: _buildLineTouchData(),
                gridData: _buildGridData(),
                titlesData: _buildTitlesData(),
                borderData: FlBorderData(show: false),
                minX: _reportsCubit?.minX ?? 0,
                maxX: _reportsCubit?.maxX ?? 0,
                minY: _calculateMinY(state.valueSpots),
                maxY: _calculateMaxY(state.valueSpots),
                lineBarsData: [
                  _buildLineBarData(state.valueSpots),
                ],
                extraLinesData: _buildExtraLinesData(),
                clipData: FlClipData.none(),
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

  LineTouchData _buildLineTouchData() {
    return LineTouchData(
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
                color: spot.y >= 0 ? Colors.green : Colors.red,
              ),
            );
          }).toList();
        },
        getTooltipColor: (_) => Colors.white,
        tooltipBorder: const BorderSide(
          color: AppColors.purple,
          width: 0.5,
        ),
      ),
      touchSpotThreshold: 20,
    );
  }

  FlGridData _buildGridData() {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: 100,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Colors.grey.withOpacity(0.1),
          strokeWidth: 1,
        );
      },
    );
  }

  FlTitlesData _buildTitlesData() {
    return FlTitlesData(
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
            if (_reportsCubit == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _reportsCubit!.formatLabel(value),
                style: AppTextStyles.smalltext13.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLineBarData(List<FlSpot> spots) {
    return LineChartBarData(
      spots: spots,
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
    );
  }

  ExtraLinesData _buildExtraLinesData() {
    return ExtraLinesData(
      horizontalLines: [
        HorizontalLine(
          y: 0,
          color: Colors.grey.withOpacity(0.3),
          strokeWidth: 1,
        ),
      ],
    );
  }

  double _calculateMinY(List<FlSpot> spots) {
    final minY = spots.map((e) => e.y).reduce(min);
    return minY < 0 ? minY * 1.2 - 100 : -10;
  }

  double _calculateMaxY(List<FlSpot> spots) {
    return spots.map((e) => e.y).reduce(max) * 1.2 + 100;
  }

  Widget _buildTransactionsList() {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state is! ReportsSuccess) {
          return const SizedBox.shrink();
        }

        print('Construindo lista de transações');
        print('Número de reports: ${state.reports.length}');
        
        // Filtrar reports com período válido
        final reportsWithTransactions = state.reports
          .where((report) => 
            report.periodStart != null && 
            (report.totalIncome > 0 || report.totalExpense > 0))
          .toList();
        
        print('Reports com transações válidas: ${reportsWithTransactions.length}');

        if (reportsWithTransactions.isEmpty) {
          return const Center(
            child: Text('Nenhuma transação encontrada neste período'),
          );
        }
        
        // Ordenar por data mais recente
        reportsWithTransactions.sort((a, b) => 
          b.periodStart!.compareTo(a.periodStart!));

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: reportsWithTransactions.length,
          itemBuilder: (context, index) {
            final report = reportsWithTransactions[index];
            
            // Garantir que temos transações válidas
            final List<Map<String, dynamic>> transactions = [];
            
            if (report.details != null && 
                report.details!['transactions'] is List) {
              for (var item in report.details!['transactions']) {
                if (item is Map<String, dynamic>) {
                  transactions.add(item);
                }
              }
            }
            
            print('Report $index: ${transactions.length} transações');
            
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(report.periodStart!),
                    style: AppTextStyles.mediumText16w500,
                  ),
                  const SizedBox(height: 8),
                  ...transactions.map((transaction) {
                    final isIncome = transaction['type']?.toString().toLowerCase() == 'entrada';
                    final amount = (transaction['amount'] as num?) ?? 0;
                    final description = transaction['description'] as String? ?? 'Sem descrição';
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              description,
                              style: AppTextStyles.smalltextw400,
                            ),
                          ),
                          Text(
                            'R\$ ${amount.toStringAsFixed(2)}',
                            style: AppTextStyles.smalltextw400.copyWith(
                              color: isIncome ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  if (transactions.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Divider(color: Colors.grey.withOpacity(0.2)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Total: R\$ ${(report.totalIncome - report.totalExpense).toStringAsFixed(2)}',
                          style: AppTextStyles.mediumText16w600.copyWith(
                            color: report.totalIncome >= report.totalExpense ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _getTransactionTitle(Report report) {
    if (_reportsCubit == null || report.periodStart == null) return 'Data inválida';

    final DateTime localDate = report.periodStart!;
    String periodInfo;

    // Obtém a informação do período baseado no tipo de relatório
    switch (_reportsCubit!.selectedPeriod) {
      case ReportPeriod.day:
        periodInfo = '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
        break;
      case ReportPeriod.week:
        periodInfo = _reportsCubit!.formatLabel(localDate.weekday.toDouble());
        break;
      case ReportPeriod.month:
        periodInfo = 'Dia ${localDate.day}';
        break;
      case ReportPeriod.year:
        periodInfo = YearlyChartConfig.monthNames[localDate.month - 1];
        break;
      default:
        periodInfo = 'Período Desconhecido';
    }

    // Retorna a descrição com o período
    return '${report.details?['description'] ?? 'Sem descrição'} • $periodInfo';
  }

  String _formatDate(DateTime date) {
    final localDate = date.isUtc ? date.toLocal() : date;
    return '${localDate.day.toString().padLeft(2, '0')}/${localDate.month.toString().padLeft(2, '0')}/${localDate.year}';
  }
}