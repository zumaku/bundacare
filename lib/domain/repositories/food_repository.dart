import 'package:bundacare/domain/entities/food_log.dart';

abstract class FoodRepository {
  Future<List<FoodLog>> getFoodLogsForToday();
}