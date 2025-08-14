import 'package:bundacare/domain/entities/food_log.dart';

abstract class FoodRepository {
  Future<List<FoodLog>> getFoodLogsForToday();
  Future<void> saveFoodLog(FoodLog foodLog); // <-- Pastikan ini ada
  Future<void> deleteFoodLog(int logId);
}