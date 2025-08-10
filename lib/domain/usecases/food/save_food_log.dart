import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/repositories/food_repository.dart';

class SaveFoodLog {
  final FoodRepository repository;

  SaveFoodLog(this.repository);

  Future<void> call(FoodLog foodLog) async {
    return repository.saveFoodLog(foodLog);
  }
}