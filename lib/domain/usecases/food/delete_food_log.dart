import 'package:bundacare/domain/repositories/food_repository.dart';

class DeleteFoodLog {
  final FoodRepository repository;

  DeleteFoodLog(this.repository);

  Future<void> call(int logId) async {
    return repository.deleteFoodLog(logId);
  }
}