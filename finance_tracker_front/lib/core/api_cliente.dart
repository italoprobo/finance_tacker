import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  
  ApiClient({Dio? dio})
      : dio = dio ??
          Dio(BaseOptions(
            baseUrl: 'http://localhost:3000', 
            connectTimeout: Duration(milliseconds: 5000),
            receiveTimeout: Duration(milliseconds: 3000),
          ));
}
