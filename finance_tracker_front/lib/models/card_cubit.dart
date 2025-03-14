import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

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
  final DateTime? closingDate;
  final DateTime? dueDate;
  final String lastDigits;

  CardModel({
    required this.id,
    required this.name,
    required this.cardType,
    required this.limit,
    required this.currentBalance,
    this.closingDate,
    this.dueDate,
    required this.lastDigits,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      cardType: List<String>.from(json['cardType']),
      limit: (json['limit'] != null ? double.tryParse(json['limit'].toString()) : 0.0) ?? 0.0,
      currentBalance: json['current_balance'] != null ? double.tryParse(json['current_balance'].toString()) ?? 0.0 : 0.0,
      closingDate: json['closingDate'] != null ? DateTime.parse(json['closingDate']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      lastDigits: json['lastDigits'],
    );
  }
}


class CardCubit extends Cubit<CardState> {
  final Dio dio;

  CardCubit(this.dio) : super(CardInitial());

  Future<void> fetchUserCards(String token) async {
    emit(CardLoading());
    try {
      final response = await dio.get(
        '/card',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        List<CardModel> cards = data.map((e) => CardModel.fromJson(e)).toList();
        emit(CardSuccess(cards: cards));
      } else {
        print("Erro no servidor: ${response.statusCode} - ${response.data}");
        emit(CardFailure("Erro ao buscar cartões"));
      }
    } catch (e) {
      print("Erro ao conectar: $e");
      emit(CardFailure("Falha ao conectar com o servidor"));
    }
  }
}
