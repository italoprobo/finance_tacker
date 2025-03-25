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

  const CategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [id, name, description];
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
        List<CategoryModel> categories = data.map((e) => CategoryModel.fromJson(e)).toList();
        emit(CategoriesSuccess(categories: categories));
      } else {
        emit(CategoriesFailure("Erro ao buscar categorias"));
      }
    } catch (e) {
      emit(CategoriesFailure("Falha ao conectar com o servidor"));
    }
  }
} 