import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  
  ApiClient({Dio? dio})
      : dio = dio ??
          Dio(BaseOptions(
            //alterar para o ip da máquina
            baseUrl: 'http://localhost:3000', 
            connectTimeout: const Duration(milliseconds: 5000),
            receiveTimeout: const Duration(milliseconds: 3000),
          ));
}
