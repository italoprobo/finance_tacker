import 'dart:math';

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
    print('\n=== Criando Report do JSON ===');
    print('JSON recebido: ${json.toString().substring(0, min(500, json.toString().length))}');
    
    DateTime? parseAndConvertToLocal(String? dateString) {
      if (dateString == null) return null;
      try {
        final dateTimeUtc = DateTime.parse(dateString).toUtc();
        return dateTimeUtc.toLocal();
      } catch (e) {
        print('Erro ao parsear data $dateString: $e');
        return null;
      }
    }

    // Processar o campo details de forma segura
    Map<String, dynamic> detailsMap = {};
    if (json['details'] != null && json['details'] is Map) {
      detailsMap = Map<String, dynamic>.from(json['details']);
      
      // Verificar se há transações válidas
      if (detailsMap.containsKey('transactions') && detailsMap['transactions'] is List) {
        List<Map<String, dynamic>> validTransactions = [];
        
        for (var item in detailsMap['transactions']) {
          if (item is Map) {
            Map<String, dynamic> transaction = Map<String, dynamic>.from(item);
            // Garantir que campos obrigatórios estejam presentes
            if (transaction['amount'] == null) transaction['amount'] = 0;
            if (transaction['description'] == null) transaction['description'] = 'Sem descrição';
            if (transaction['type'] == null) transaction['type'] = 'saida';
            
            validTransactions.add(transaction);
          }
        }
        
        detailsMap['transactions'] = validTransactions;
      } else {
        // Se não houver transações válidas, inicializar com lista vazia
        detailsMap['transactions'] = [];
      }
    } else {
      // Se details não for um Map válido, inicializar vazio
      detailsMap = {'transactions': []};
    }

    return Report(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      periodStart: parseAndConvertToLocal(json['period_start']),
      periodEnd: parseAndConvertToLocal(json['period_end']),
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpense: (json['total_expense'] ?? 0).toDouble(),
      details: detailsMap,
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