import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/repositories/food_repository.dart';

class GetTodaysFoodLogs {
  final FoodRepository repository;

  GetTodaysFoodLogs(this.repository);

  Future<List<FoodLog>> call() async {
    return await repository.getFoodLogsForToday();
  }
}