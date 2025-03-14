import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_tracker_front/features/transactions/data/transactions_repository.dart';

class TransactionState extends Equatable {
  @override
  List<Object> get props => [];
}

class TransactionsInitial extends TransactionState {}

class TransactionsLoading extends TransactionState {}

class TransactionsSuccess extends TransactionState {
  final List<TransactionModel> transactions;
  TransactionsSuccess({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TransactionsFailure extends TransactionState {
  final String message;
  TransactionsFailure(this.message);

  @override
  List<Object> get props => [message];
}

class TransactionModel extends Equatable {
  final String id;
  final String description;
  final double amount;
  final String type; 
  final DateTime date;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      date: DateTime.parse(json['date']),
    );
  }

  @override
  List<Object> get props => [id, description, amount, type, date];
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionsRepository transactionsRepository;
  TransactionCubit(this.transactionsRepository) : super(TransactionsInitial());

  Future<void> fetchUserTransactions(String token) async {
    emit(TransactionsLoading());
    try {
      final transactions = await transactionsRepository.fetchUserTransactions(token);
      emit(TransactionsSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionsFailure(e.toString()));
    }
  }

    Future<void> addTransaction(String token, Map<String, dynamic> transactionData) async {
    try {
      await transactionsRepository.addTransaction(token, transactionData);
      fetchUserTransactions(token);
    } catch (e) {
      emit(TransactionsFailure(e.toString()));
    }
  }
}
