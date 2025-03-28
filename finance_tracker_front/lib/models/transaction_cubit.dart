import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_tracker_front/features/transactions/data/transactions_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final String? categoryId;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.categoryId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      date: DateTime.parse(json['date']),
      categoryId: json['categoryId'],
    );
  }

  @override
  List<Object?> get props => [id, description, amount, type, date, categoryId];
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionsRepository transactionsRepository;

  TransactionCubit(this.transactionsRepository) : super(TransactionsInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        emit(TransactionsFailure("Nenhum token salvo. Faça login novamente."));
        return;
      }
      fetchUserTransactions(token);
    } catch (e) {
      emit(TransactionsFailure("Erro ao recuperar token"));
    }
  }

  Future<void> fetchUserTransactions(String token) async {
    emit(TransactionsLoading());

    try {
      final transactions = await transactionsRepository.fetchUserTransactions(token);

      emit(TransactionsSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionsFailure("Erro ao buscar transações"));
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

  Future<void> deleteTransaction(String token, String transactionId) async {
    try {
      await transactionsRepository.deleteTransaction(token, transactionId);
      await fetchUserTransactions(token);
    } catch (e) {
      emit(TransactionsFailure("Erro ao excluir transação"));
    }
  }

  Future<void> updateTransaction(String transactionId, String token, Map<String, dynamic> transactionData) async {
    try {
      await transactionsRepository.updateTransaction(transactionId, token, transactionData);
      await fetchUserTransactions(token);
    } catch (e) {
      emit(TransactionsFailure("Erro ao atualizar transação"));
    }
  }
}

