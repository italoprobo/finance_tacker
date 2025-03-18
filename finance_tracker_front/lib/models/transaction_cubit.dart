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

  TransactionCubit(this.transactionsRepository) : super(TransactionsInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    print("🛠 Iniciando TransactionCubit...");

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        print("⚠️ Nenhum token encontrado. Esperando autenticação...");
        emit(TransactionsFailure("Nenhum token salvo. Faça login novamente."));
        return;
      }

      print("✅ Token carregado: $token");
      fetchUserTransactions(token);
    } catch (e) {
      print("❌ Erro ao carregar o token: $e");
      emit(TransactionsFailure("Erro ao recuperar token"));
    }
  }

  Future<void> fetchUserTransactions(String token) async {
    print("📡 Buscando transações do usuário...");
    emit(TransactionsLoading());

    try {
      final transactions = await transactionsRepository.fetchUserTransactions(token);

      if (transactions.isEmpty) {
        print("⚠️ Nenhuma transação encontrada.");
      } else {
        print("✅ Transações carregadas! Quantidade: ${transactions.length}");
      }

      emit(TransactionsSuccess(transactions: transactions));
    } catch (e) {
      print("❌ Erro ao buscar transações: $e");
      emit(TransactionsFailure("Erro ao buscar transações"));
    }
  }

  Future<void> addTransaction(String token, Map<String, dynamic> transactionData) async {
    try {
      print("📝 Adicionando nova transação...");
      await transactionsRepository.addTransaction(token, transactionData);
      
      print("🔄 Recarregando transações após adição...");
      fetchUserTransactions(token);
    } catch (e) {
      print("❌ Falha ao adicionar transação: $e");
      emit(TransactionsFailure(e.toString()));
    }
  }
}

