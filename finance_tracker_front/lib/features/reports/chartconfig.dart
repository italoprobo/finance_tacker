// Criar uma classe base para configuração dos gráficos
import 'package:finance_tracker_front/models/report.dart';
import 'package:fl_chart/fl_chart.dart';

abstract class ChartConfig {
  List<FlSpot> processData(List<Report> reports);
  double getMinX();
  double getMaxX();
  double getInterval();
  String formatLabel(double value);
}

// Configuração específica para gráfico diário
class DailyChartConfig extends ChartConfig {
  @override
  List<FlSpot> processData(List<Report> reports) {
    Map<int, double> values = {};
    for (int i = 0; i < 24; i++) {
      values[i] = 0;
    }
    
    for (var report in reports) {
      if (report.periodStart == null) continue;
      values[report.periodStart!.hour] = report.totalIncome - report.totalExpense;
    }
    
    return values.entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
      .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  @override
  double getMinX() => 0.0;

  @override
  double getMaxX() => 23.0;

  @override
  double getInterval() => 4;

  @override
  String formatLabel(double value) => '${value.toInt()}h';
}

// Configuração específica para gráfico semanal
class WeeklyChartConfig extends ChartConfig {
  final List<String> dayNames = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  List<FlSpot> processData(List<Report> reports) {
    print('\n=== DEBUG: Processando dados semanais ===');
    
    Map<int, double> values = {};
    for (int i = 1; i <= 7; i++) {
      values[i] = 0;
      print('Inicializando dia $i (${dayNames[i-1]}) com 0');
    }
    
    for (var report in reports) {
      if (report.periodStart == null) continue;
      final weekday = report.periodStart!.weekday;
      final oldValue = values[weekday] ?? 0;
      final newValue = oldValue + (report.totalIncome - report.totalExpense);
      values[weekday] = newValue;
      print('Report do dia ${report.periodStart}: weekday=$weekday (${dayNames[weekday-1]}), valor: $oldValue -> $newValue');
    }
    
    final spots = values.entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
      .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    
    print('Spots gerados (${spots.length}):');
    for (var spot in spots) {
      print('x=${spot.x} (${formatLabel(spot.x)}), y=${spot.y}');
    }
    
    return spots;
  }

  @override
  double getMinX() => 1.0;

  @override
  double getMaxX() => 7.0;

  @override
  double getInterval() => 1;

  @override
  String formatLabel(double value) {
    final index = value.toInt() - 1;
    if (index < 0 || index >= dayNames.length) return '';
    return dayNames[index];
  }
}

// Configuração específica para gráfico mensal
class MonthlyChartConfig extends ChartConfig {
  @override
  List<FlSpot> processData(List<Report> reports) {
    print('\n=== DEBUG: Processando dados mensais ===');
    
    Map<int, double> dailyTotals = {};
    List<int> fixedDays = [1, 5, 10, 15, 20, 25];
    
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    if (!fixedDays.contains(lastDay)) {
      fixedDays.add(lastDay);
    }
    
    print('Dias fixos: $fixedDays');
    print('Último dia do mês: $lastDay');
    
    for (var day in fixedDays) {
      if (day <= lastDay) {
        dailyTotals[day] = 0;
        print('Inicializando dia $day com 0');
      }
    }
    
    for (var report in reports) {
      if (report.periodStart == null) continue;
      final day = report.periodStart!.day;
      final nearestDay = fixedDays.reduce((a, b) {
        return (day - a).abs() < (day - b).abs() ? a : b;
      });
      final oldValue = dailyTotals[nearestDay] ?? 0;
      final newValue = oldValue + (report.totalIncome - report.totalExpense);
      dailyTotals[nearestDay] = newValue;
      print('Dia $day agrupado em $nearestDay: $oldValue -> $newValue');
    }
    
    final spots = dailyTotals.entries
      .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
      .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
    
    print('Spots gerados (${spots.length}):');
    for (var spot in spots) {
      print('x=${spot.x} (dia ${spot.x.toInt()}), y=${spot.y}');
    }
    
    return spots;
  }

  @override
  double getMinX() => 1.0;

  @override
  double getMaxX() => DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day.toDouble();

  @override
  double getInterval() => 5;

  @override
  String formatLabel(double value) => value.toInt().toString();
}

// Configuração específica para gráfico anual
class YearlyChartConfig extends ChartConfig {
  final List<String> monthNames = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

  @override
  List<FlSpot> processData(List<Report> reports) {
    print('\n=== DEBUG: Processando dados anuais ===');
    
    if (reports.isEmpty) {
      return List.generate(6, (index) => FlSpot(index.toDouble(), 0));
    }

    // Determinar o período de 6 meses baseado nas datas reais dos reports
    final minDate = _findMinDate(reports);
    final maxDate = _findMaxDate(reports);
    
    print('Data mais antiga: ${minDate.day}/${minDate.month}/${minDate.year}');
    print('Data mais recente: ${maxDate.day}/${maxDate.month}/${maxDate.year}');
    
    // Usar as datas REAIS para criar os ranges de meses
    final monthRanges = _createMonthRanges(minDate, maxDate);
    
    // Inicializar totais
    Map<int, double> totals = {};
    for (int i = 0; i < monthRanges.length; i++) {
      totals[i] = 0;
    }
    
    // Processar reports
    for (var report in reports) {
      if (report.periodStart == null) continue;
      
      for (int i = 0; i < monthRanges.length; i++) {
        var range = monthRanges[i];
        if (isDateInRange(report.periodStart!, range.start, range.end)) {
          final balance = report.totalIncome - report.totalExpense;
          totals[i] = (totals[i] ?? 0) + balance;
          
          print('Report de ${report.periodStart!.day}/${report.periodStart!.month}/${report.periodStart!.year} ' +
                '(${monthNames[report.periodStart!.month-1]}): R\$ $balance adicionado ao índice $i (${monthNames[range.month-1]}/${range.year})');
        }
      }
    }
    
    // Criar spots
    final spots = totals.entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList()
        ..sort((a, b) => a.x.compareTo(b.x));
    
    print('\nSpots finais:');
    for (var i = 0; i < spots.length; i++) {
      final range = monthRanges[i];
      print('Índice ${spots[i].x.toInt()} (${monthNames[range.month-1]}/${range.year}): R\$ ${spots[i].y}');
    }
    
    return spots;
  }
  
  DateTime _findMinDate(List<Report> reports) {
    return reports
        .where((r) => r.periodStart != null)
        .map((r) => r.periodStart!)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  }
  
  DateTime _findMaxDate(List<Report> reports) {
    return reports
        .where((r) => r.periodStart != null)
        .map((r) => r.periodStart!)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
  
  List<_MonthRange> _createMonthRanges(DateTime minDate, DateTime maxDate) {
    List<_MonthRange> ranges = [];
    
    // Encontrar o mês mais recente (pode ser o mês da data mais recente)
    DateTime latestMonth = DateTime(maxDate.year, maxDate.month, 1);
    
    // Gerar 6 meses retroativos a partir do mês mais recente
    for (int i = 5; i >= 0; i--) {
      int month = latestMonth.month - i;
      int year = latestMonth.year;
      
      if (month <= 0) {
        month += 12;
        year -= 1;
      }
      
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      
      ranges.add(_MonthRange(
        index: 5 - i,
        month: month,
        year: year,
        start: firstDay,
        end: lastDay
      ));
      
      print('Mês ${monthNames[month-1]}/$year (índice: ${5-i})');
    }
    
    return ranges;
  }
  
  bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAtSameMomentAs(start) || 
           date.isAtSameMomentAs(end) || 
           (date.isAfter(start) && date.isBefore(end));
  }

  @override
  double getMinX() => 0.0;

  @override
  double getMaxX() => 5.0;

  @override
  double getInterval() => 1.0;

  @override
  String formatLabel(double value) {
    final index = value.toInt();
    
    // Obter os meses atuais dos reports
    if (_lastMonthRanges != null && _lastMonthRanges!.isNotEmpty) {
      if (index >= 0 && index < _lastMonthRanges!.length) {
        final range = _lastMonthRanges![index];
        return monthNames[range.month - 1];
      }
    }
    
    // Fallback para caso não tenhamos ranges salvos
    final now = DateTime.now();
    int month = now.month - (5 - index);
    int year = now.year;
    
    if (month <= 0) {
      month += 12;
      year -= 1;
    }
    
    return monthNames[month - 1];
  }
  
  // Cache dos últimos monthRanges calculados para uso no formatLabel
  static List<_MonthRange>? _lastMonthRanges;
  
  List<_MonthRange> _getMonthRanges() {
    final ranges = _createMonthRanges(DateTime.now().subtract(const Duration(days: 180)), DateTime.now());
    _lastMonthRanges = ranges;
    return ranges;
  }
}

// Classe de apoio para rastrear informações dos meses
class _MonthRange {
  final int index;
  final int month;
  final int year;
  final DateTime start;
  final DateTime end;
  
  _MonthRange({
    required this.index,
    required this.month,
    required this.year,
    required this.start,
    required this.end,
  });
}
