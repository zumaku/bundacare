import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Dio client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.connectTimeout = const Duration(seconds: 10);
    return dio;
  });

  // Supabase client is initialized in main using SupabaseService.init
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
}
