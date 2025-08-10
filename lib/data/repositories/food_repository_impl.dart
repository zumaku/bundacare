import 'package:bundacare/data/datasources/food_remote_data_source.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/repositories/food_repository.dart';

class FoodRepositoryImpl implements FoodRepository {
  final FoodRemoteDataSource remoteDataSource;

  FoodRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<FoodLog>> getFoodLogsForToday() async {
    return await remoteDataSource.getFoodLogsForToday();
  }
}