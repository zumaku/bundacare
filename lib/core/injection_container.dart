import 'package:bundacare/data/datasources/detection_remote_data_source.dart';
import 'package:bundacare/data/datasources/food_remote_data_source.dart';
import 'package:bundacare/data/repositories/detection_repository_impl.dart';
import 'package:bundacare/data/repositories/food_repository_impl.dart';
import 'package:bundacare/domain/repositories/detection_repository.dart';
import 'package:bundacare/domain/repositories/food_repository.dart';
import 'package:bundacare/domain/usecases/auth/get_user_profile.dart';
import 'package:bundacare/domain/usecases/food/detect_from_image.dart';
import 'package:bundacare/domain/usecases/food/get_todays_food_logs.dart';
import 'package:bundacare/presentation/bloc/detection/detection_bloc.dart';
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
import 'package:bundacare/domain/usecases/food/save_food_log.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerSingleton<SupabaseClient>(Supabase.instance.client);
  sl.registerSingleton<Dio>(Dio());

  // BLoCs
  sl.registerFactory(() => AuthBloc(
        signInWithGoogle: sl(),
        signOut: sl(),
        getUserProfile: sl(),
        supabaseClient: sl(),
      ));
  sl.registerFactory(() => FoodBloc(getTodaysFoodLogs: sl()));
  sl.registerFactory(() => DetectionBloc(
        detectFromImage: sl(),
        saveFoodLog: sl(),
        detectionRepository: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => GetTodaysFoodLogs(sl()));
  sl.registerLazySingleton(() => SaveFoodLog(sl()));
  sl.registerLazySingleton(() => DetectFromImage(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<FoodRepository>(() => FoodRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<DetectionRepository>(() => DetectionRepositoryImpl(remoteDataSource: sl()));

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl());
  sl.registerLazySingleton<FoodRemoteDataSource>(() => FoodRemoteDataSourceImpl());
  sl.registerLazySingleton<DetectionRemoteDataSource>(() => DetectionRemoteDataSourceImpl(dio: sl()));
}