import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:finance_tracker_front/models/transaction_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class CardState extends Equatable {
  @override
  List<Object> get props => [];
}

class CardInitial extends CardState {}

class CardLoading extends CardState {}

class CardSuccess extends CardState {
  final List<CardModel> cards;

  CardSuccess({required this.cards});

  @override
  List<Object> get props => [cards];
}

class CardFailure extends CardState {
  final String message;
  CardFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CardModel {
  final String id;
  final String name;
  final List<String> cardType;
  final double limit;
  final double currentBalance;
  final double? salary;
  final int? closingDay;
  final int? dueDay;
  final String lastDigits;
  final List<TransactionModel>? transactions;
  final List<InvoiceTransaction>? invoiceTransactions;

  CardModel({
    required this.id,
    required this.name,
    required this.cardType,
    required this.limit,
    required this.currentBalance,
    this.salary,
    this.closingDay,
    this.dueDay,
    required this.lastDigits,
    this.transactions,
    this.invoiceTransactions,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      cardType: List<String>.from(json['cardType']),
      limit: (json['limit'] != null ? double.tryParse(json['limit'].toString()) : 0.0) ?? 0.0,
      currentBalance: json['current_balance'] != null ? double.tryParse(json['current_balance'].toString()) ?? 0.0 : 0.0,
      salary: json['salary'] != null ? double.tryParse(json['salary'].toString()) : null,
      closingDay: json['closingDay'],
      dueDay: json['dueDay'],
      lastDigits: json['lastDigits'],
      transactions: json['transactions'] != null 
          ? List<TransactionModel>.from(json['transactions'].map((x) => TransactionModel.fromJson(x)))
          : null,
      invoiceTransactions: json['invoiceTransactions'] != null
          ? List<InvoiceTransaction>.from(json['invoiceTransactions'].map((x) => InvoiceTransaction.fromJson(x)))
          : null,
    );
  }
}

class InvoiceTransaction {
  final int month;
  final int year;
  final List<String> transactions;

  InvoiceTransaction({
    required this.month,
    required this.year,
    required this.transactions,
  });

  factory InvoiceTransaction.fromJson(Map<String, dynamic> json) {
    return InvoiceTransaction(
      month: json['month'],
      year: json['year'],
      transactions: List<String>.from(json['transactions']),
    );
  }
}

class CardCubit extends Cubit<CardState> {
  final Dio dio;

  CardCubit(this.dio) : super(CardInitial()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');

      if (token == null || token.isEmpty) {
        emit(CardFailure("Nenhum token salvo. Faça login novamente."));
        return;
      }
      fetchUserCards(token);
    } catch (e) {
      emit(CardFailure("Erro ao recuperar token"));
    }
  }

  Future<void> fetchUserCards(String token) async {
    emit(CardLoading());
    try {
      final response = await dio.get(
        '/card',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<CardModel> cards = data.map((e) => CardModel.fromJson(e)).toList();
        emit(CardSuccess(cards: cards));
      } else if (response.statusCode == 401) {
        emit(CardFailure("Sessão expirada. Por favor, faça login novamente."));
      } else {
        emit(CardFailure("Erro ao buscar cartões: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CardFailure("Falha ao conectar com o servidor: ${e.toString()}"));
    }
  }

  Future<void> addCard(String token, Map<String, dynamic> cardData) async {
    emit(CardLoading());
    try {
      final response = await dio.post(
        '/card',
        data: cardData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 201) {
        await fetchUserCards(token);
      } else if (response.statusCode == 401) {
        emit(CardFailure("Sessão expirada. Por favor, faça login novamente."));
      } else {
        emit(CardFailure("Erro ao adicionar cartão: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CardFailure("Falha ao conectar com o servidor: ${e.toString()}"));
    }
  }

  Future<void> updateCard(String token, String cardId, Map<String, dynamic> cardData) async {
    emit(CardLoading());
    try {
      final response = await dio.patch(
        '/card/$cardId',
        data: cardData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        await fetchUserCards(token);
      } else if (response.statusCode == 401) {
        emit(CardFailure("Sessão expirada. Por favor, faça login novamente."));
      } else {
        emit(CardFailure("Erro ao atualizar cartão: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CardFailure("Falha ao conectar com o servidor: ${e.toString()}"));
    }
  }

  Future<void> deleteCard(String token, String cardId) async {
    emit(CardLoading());
    try {
      final response = await dio.delete(
        '/card/$cardId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        await fetchUserCards(token);
      } else if (response.statusCode == 401) {
        emit(CardFailure("Sessão expirada. Por favor, faça login novamente."));
      } else {
        emit(CardFailure("Erro ao excluir cartão: ${response.statusCode}"));
      }
    } catch (e) {
      emit(CardFailure("Falha ao conectar com o servidor: ${e.toString()}"));
    }
  }

  Future<double> getCardBalance(String token, String cardId) async {
    try {
      final response = await dio.get(
        '/card/$cardId/balance',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return double.parse(response.data['balance'].toString());
      }
      throw Exception('Erro ao buscar saldo');
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor');
    }
  }

  Future<Map<String, dynamic>> getCurrentInvoice(String token, String cardId) async {
    try {
      final response = await dio.get(
        '/card/$cardId/invoice',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Erro ao buscar fatura');
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor');
    }
  }

  Future<void> linkTransaction(String token, String cardId, String transactionId) async {
    try {
      final response = await dio.post(
        '/card/$cardId/link-transaction/$transactionId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        await fetchUserCards(token);
      } else {
        throw Exception('Erro ao vincular transação');
      }
    } catch (e) {
      throw Exception('Falha ao conectar com o servidor');
    }
  }
}
