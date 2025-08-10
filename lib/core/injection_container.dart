import 'package:bundacare/data/datasources/food_remote_data_source.dart';
import 'package:bundacare/data/repositories/food_repository_impl.dart';
import 'package:bundacare/domain/repositories/food_repository.dart';
import 'package:bundacare/domain/usecases/food/get_todays_food_logs.dart';
import 'package:bundacare/presentation/bloc/food/food_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:bundacare/data/datasources/auth_remote_data_source.dart';
import 'package:bundacare/data/repositories/auth_repository_impl.dart';
import 'package:bundacare/domain/repositories/auth_repository.dart';
import 'package:bundacare/domain/usecases/auth/sign_in_with_google.dart';
import 'package:bundacare/domain/usecases/auth/sign_out.dart';
import 'package:bundacare/presentation/bloc/auth/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<Dio>(Dio());

  // BLoCs
  sl.registerFactory(() => AuthBloc(
    signInWithGoogle: sl(),
    signOut: sl(),
    supabaseClient: sl(),
  ));

  // Use Cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl())); // Jangan lupa buat filenya

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl());

  // ============================================================================

  // FITUR FOOD
  // BLoC
  sl.registerFactory(() => FoodBloc(getTodaysFoodLogs: sl()));

  // Use Cases
  sl.registerLazySingleton(() => GetTodaysFoodLogs(sl()));

  // Repository
  sl.registerLazySingleton<FoodRepository>(
      () => FoodRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<FoodRemoteDataSource>(
      () => FoodRemoteDataSourceImpl());
}