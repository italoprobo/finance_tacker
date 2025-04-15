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

      // Usar o horário local diretamente do report.periodStart
      // que já foi convertido para local no Report.fromJson
      int hour = report.periodStart!.hour;
      double currentBalance = report.totalIncome - report.totalExpense;
      values[hour] = (values[hour] ?? 0) + currentBalance;
      
      print('Processando transação: hora=${report.periodStart!.hour}:${report.periodStart!.minute}, valor=$currentBalance');
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
  static const List<String> monthNames = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];

  static List<_MonthRange>? lastMonthRanges;

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
    lastMonthRanges = monthRanges;
    
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
                '(${YearlyChartConfig.monthNames[report.periodStart!.month-1]}): R\$ $balance adicionado ao índice $i (${YearlyChartConfig.monthNames[range.month-1]}/${range.year})');
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
      print('Índice ${spots[i].x.toInt()} (${YearlyChartConfig.monthNames[range.month-1]}/${range.year}): R\$ ${spots[i].y}');
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
    
    // Garantir que estamos usando o primeiro dia do mês para ambas as datas
    DateTime startMonth = DateTime(minDate.year, minDate.month, 1);
    DateTime endMonth = DateTime(maxDate.year, maxDate.month, 1);
    
    print('Período: ${startMonth.month}/${startMonth.year} até ${endMonth.month}/${endMonth.year}');
    
    // Calcular diferença em meses
    int monthsDiff = (endMonth.year - startMonth.year) * 12 + endMonth.month - startMonth.month;
    
    // Se temos menos de 5 meses de diferença, ajustar para mostrar meses anteriores
    if (monthsDiff < 5) {
      // Ajustar a data de início para ter pelo menos 6 meses
      int extraMonths = 5 - monthsDiff;
      int newMonth = startMonth.month - extraMonths;
      int yearAdjustment = 0;
      
      while (newMonth <= 0) {
        newMonth += 12;
        yearAdjustment--;
      }
      
      startMonth = DateTime(startMonth.year + yearAdjustment, newMonth, 1);
      monthsDiff = 5; // Agora temos 6 meses (índices 0-5)
      
      print('Ajustando para mostrar mais meses: ${startMonth.month}/${startMonth.year} até ${endMonth.month}/${endMonth.year}');
    }
    
    // Sempre mostrar exatamente 6 meses (ou menos se não houver 6)
    int numMonthsToShow = monthsDiff < 5 ? monthsDiff + 1 : 6;
    
    // Se temos mais de 6 meses, mostrar os 6 meses mais recentes
    if (monthsDiff > 5) {
      // Ajustar a data de início para pegar os 6 meses mais recentes
      int newMonth = endMonth.month - 5;
      int yearAdjustment = 0;
      
      while (newMonth <= 0) {
        newMonth += 12;
        yearAdjustment--;
      }
      
      startMonth = DateTime(endMonth.year + yearAdjustment, newMonth, 1);
      print('Ajustando para mostrar apenas os 6 meses mais recentes: ${startMonth.month}/${startMonth.year} até ${endMonth.month}/${endMonth.year}');
    }
    
    // Gerar as faixas de meses em ordem cronológica (mais antigo primeiro)
    for (int i = 0; i < numMonthsToShow; i++) {
      int month = startMonth.month + i;
      int year = startMonth.year;
      
      // Ajustar para virada de ano
      while (month > 12) {
        month -= 12;
        year++;
      }
      
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0); // Último dia do mês
      
      ranges.add(_MonthRange(
        index: i, // Índice 0 = mês mais antigo, 5 = mês mais recente
        month: month,
        year: year,
        start: firstDay,
        end: lastDay
      ));
      
      print('Mês ${YearlyChartConfig.monthNames[month-1]}/$year (índice: $i)');
    }
    
    return ranges;
  }
  
  bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    // Converte a data do report para UTC para consistência.
    // Se já for UTC, mantém; senão, converte.
    final dateUtc = date.isUtc ? date : date.toUtc();

    // Garante que as datas de início e fim do range representem
    // o dia inteiro em UTC.
    final startUtc = DateTime.utc(start.year, start.month, start.day);
    // O fim do dia (23:59:59.999) para a data final do range.
    final endUtc = DateTime.utc(end.year, end.month, end.day, 23, 59, 59, 999);

    // Compara as datas UTC. A data deve ser igual ou posterior ao início
    // E igual ou anterior ao fim do range.
    return !dateUtc.isBefore(startUtc) && !dateUtc.isAfter(endUtc);
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
    if (lastMonthRanges != null && lastMonthRanges!.isNotEmpty) {
      if (index >= 0 && index < lastMonthRanges!.length) {
        final range = lastMonthRanges![index];
        return YearlyChartConfig.monthNames[range.month - 1];
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
    
    return YearlyChartConfig.monthNames[month - 1];
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
