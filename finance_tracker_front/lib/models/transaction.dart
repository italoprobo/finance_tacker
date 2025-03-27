import 'package:finance_tracker_front/models/transaction_cubit.dart';

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String type;
  final DateTime date;
  final String category;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: json['amount'].toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
      category: json['category'],
    );
  }

  factory Transaction.fromModel(TransactionModel model) {
    return Transaction(
      id: model.id,
      description: model.description,
      amount: model.amount,
      type: model.type,
      date: model.date,
      category: model.categoryId ?? 'Sem categoria',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
} 