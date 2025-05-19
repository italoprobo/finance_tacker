import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

// Estados
abstract class CategoriesState extends Equatable {
  @override
  List<Object> get props => [];
}

class CategoriesInitial extends CategoriesState {}

class CategoriesLoading extends CategoriesState {}

class CategoriesSuccess extends CategoriesState {
  final List<CategoryModel> categories;
  CategoriesSuccess({required this.categories});

  @override
  List<Object> get props => [categories];
}

class CategoriesFailure extends CategoriesState {
  final String message;
  CategoriesFailure(this.message);

  @override
  List<Object> get props => [message];
}

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? type;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'] ?? 'saida',
    );
  }

  @override
  List<Object?> get props => [id, name, description, type];
}

class CategoriesCubit extends Cubit<CategoriesState> {
  final Dio dio;

  CategoriesCubit(this.dio) : super(CategoriesInitial()) {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    emit(CategoriesLoading());
    try {
      final response = await dio.get('/categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Dados das categorias recebidos: $data'); // Debug
        List<CategoryModel> categories = data.map((e) => CategoryModel.fromJson(e)).toList();
        print('Categorias processadas: ${categories.map((c) => '${c.name}:${c.type}').toList()}'); // Debug
        emit(CategoriesSuccess(categories: categories));
      } else {
        emit(CategoriesFailure("Erro ao buscar categorias: Status ${response.statusCode}"));
      }
    } catch (e) {
      // Melhorando a mensagem de erro
      String errorMessage = "Falha ao conectar com o servidor";
      if (e is DioException) {
        if (e.type == DioExceptionType.connectionTimeout) {
          errorMessage = "Tempo de conexão esgotado";
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = "Erro de conexão: Verifique sua internet";
        } else if (e.response != null) {
          errorMessage = "Erro ${e.response?.statusCode}: ${e.response?.statusMessage}";
        }
      }
      emit(CategoriesFailure(errorMessage));
      print("Erro detalhado: $e"); // Para debug
    }
  }
} 