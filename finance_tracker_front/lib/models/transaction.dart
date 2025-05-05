import 'package:finance_tracker_front/models/client.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String type;
  final DateTime date;
  final String category;
  final bool isRecurring;
  final String? clientId;
  final Client? client;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    required this.category,
    required this.isRecurring,
    required this.clientId,
    required this.client,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      date: DateTime.parse(json['date']),
      category: json['category']?['name'] ?? 'Sem categoria',
      isRecurring: json['isRecurring'] ?? false,
      clientId: json['client_id'],
      client: json['client'] != null ? Client.fromJson(json['client']) : null,
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
      isRecurring: model.isRecurring,
      clientId: model.clientId,
      client: model.client,
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
      'isRecurring': isRecurring,
      'clientId': clientId,
      'client': client,
    };
  }
} 