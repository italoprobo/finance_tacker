import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:finance_tracker_front/features/reports/reports_repository.dart';
import 'package:finance_tracker_front/features/reports/reports_cubit.dart';
import 'package:finance_tracker_front/features/clients/data/client_repository.dart';
import 'package:finance_tracker_front/models/card_cubit.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  // Http Client
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000', // ajuste para sua URL base
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
    return dio;
  });

  // Repositories
  getIt.registerLazySingleton<ReportsRepository>(
    () => ReportsRepository(getIt<Dio>()),
  );

  getIt.registerLazySingleton<ClientRepository>(
    () => ClientRepository(getIt<Dio>()),
  );

  // Cubits
  getIt.registerFactory<ReportsCubit>(
    () => ReportsCubit(getIt<ReportsRepository>()),
  );

  // Novo registro do CardCubit
  getIt.registerFactory<CardCubit>(
    () => CardCubit(getIt<Dio>()),
  );
}