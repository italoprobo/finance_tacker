class Report {
  final String id;
  final String type;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double totalIncome;
  final double totalExpense;
  final Map<String, dynamic>? details;

  Report({
    required this.id,
    required this.type,
    this.periodStart,
    this.periodEnd,
    required this.totalIncome,
    required this.totalExpense,
    this.details,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    DateTime? parseAndConvertToLocal(String? dateString) {
      if (dateString == null) return null;
      try {
        final dateTimeUtc = DateTime.parse(dateString);
        return dateTimeUtc.toLocal();
      } catch (e) {
        print('Erro ao parsear data $dateString: $e');
        return null;
      }
    }

    return Report(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      periodStart: parseAndConvertToLocal(json['period_start']),
      periodEnd: parseAndConvertToLocal(json['period_end']),
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      details: json['details'],
    );
  }
  
  // Adicionar método para criar a partir de transações
  factory Report.fromTransactions(String id, String type, List<dynamic> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    
    for (var transaction in transactions) {
      if (transaction['type'] == 'income') {
        totalIncome += transaction['amount'].toDouble();
      } else {
        totalExpense += transaction['amount'].toDouble();
      }
    }
    
    return Report(
      id: id,
      type: type,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );
  }
}