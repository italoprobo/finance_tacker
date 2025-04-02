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
  final String? categoryId;
  final String userId;

  const TransactionModel({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
    this.categoryId,
    required this.userId,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final userId = json['user']?['id'] ?? json['userId'];
    
    return TransactionModel(
      id: json['id'],
      description: json['description'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      type: json['type'],
      date: DateTime.parse(json['date']),
      categoryId: json['category']?['id'],
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [id, description, amount, type, date, categoryId, userId];
}

class TransactionCubit extends Cubit<TransactionState> {
  final TransactionsRepository transactionsRepository;
  bool _isInitialized = false;
  String? _currentUserId;

  TransactionCubit(this.transactionsRepository) : super(TransactionsInitial());

  Future<void> initialize(String token, String userId) async {
    if (_isInitialized && _currentUserId == userId) {
      return;
    }
    
    try {
      if (token.isEmpty) {
        emit(TransactionsFailure("Token não fornecido"));
        return;
      }

      if (userId.isEmpty) {
        emit(TransactionsFailure("ID do usuário não fornecido"));
        return;
      }

      _currentUserId = userId;
      await fetchUserTransactions(token);
      _isInitialized = true;
    } catch (e) {
      emit(TransactionsFailure(e.toString()));
    }
  }

  Future<void> fetchUserTransactions(String token) async {
    if (state is TransactionsLoading) {
      return;
    }
    
    emit(TransactionsLoading());

    try {
      if (token.isEmpty) {
        emit(TransactionsFailure("Token não fornecido"));
        return;
      }

      final transactions = await transactionsRepository.fetchUserTransactions(token);
      emit(TransactionsSuccess(transactions: transactions));
    } catch (e) {
      emit(TransactionsFailure(e.toString()));
    }
  }

  Future<void> addTransaction(String token, Map<String, dynamic> transactionData) async {
    try {
      final newTransaction = await transactionsRepository.addTransaction(token, transactionData);
      
      if (state is TransactionsSuccess) {
        final currentState = state as TransactionsSuccess;
        if (newTransaction.userId == _currentUserId) {
          final updatedTransactions = [...currentState.transactions, newTransaction];
          emit(TransactionsSuccess(transactions: updatedTransactions));
        }
      } else {
        await fetchUserTransactions(token);
      }
    } catch (e) {
      emit(TransactionsFailure(e.toString()));
    }
  }

  Future<void> deleteTransaction(String token, String transactionId) async {
    try {
      await transactionsRepository.deleteTransaction(token, transactionId);
      if (state is TransactionsSuccess) {
        final currentState = state as TransactionsSuccess;
        final updatedTransactions = currentState.transactions.where((t) => t.id != transactionId).toList();
        emit(TransactionsSuccess(transactions: updatedTransactions));
      }
    } catch (e) {
      emit(TransactionsFailure("Erro ao excluir transação"));
    }
  }

  Future<void> updateTransaction(String transactionId, String token, Map<String, dynamic> transactionData) async {
    try {
      await transactionsRepository.updateTransaction(transactionId, token, transactionData);
      if (state is TransactionsSuccess) {
        final currentState = state as TransactionsSuccess;
        final updatedTransactions = currentState.transactions.map((t) {
          if (t.id == transactionId && t.userId == _currentUserId) {
            return TransactionModel(
              id: transactionId,
              description: transactionData['description'],
              amount: transactionData['amount'],
              type: transactionData['type'],
              date: DateTime.parse(transactionData['date']),
              categoryId: transactionData['categoryId'],
              userId: t.userId,
            );
          }
          return t;
        }).toList();
        emit(TransactionsSuccess(transactions: updatedTransactions));
      } else {
        await fetchUserTransactions(token);
      }
    } catch (e) {
      emit(TransactionsFailure("Erro ao atualizar transação"));
    }
  }
}

