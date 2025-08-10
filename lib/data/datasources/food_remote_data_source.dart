import 'package:bundacare/core/services/supabase_service.dart';
import 'package:bundacare/data/models/food_log_model.dart';
import 'package:bundacare/domain/entities/food_log.dart';

abstract class FoodRemoteDataSource {
  Future<List<FoodLogModel>> getFoodLogsForToday();
  Future<void> saveFoodLog(FoodLog foodLog);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  @override
  Future<List<FoodLogModel>> getFoodLogsForToday() async {
    try {
      final today = DateTime.now();
      final startOfToday = DateTime(today.year, today.month, today.day).toIso8601String();
      final endOfToday = DateTime(today.year, today.month, today.day, 23, 59, 59).toIso8601String();
      
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = await supabase
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfToday)
          .lte('created_at', endOfToday);

      final foodLogs = data.map((item) => FoodLogModel.fromJson(item)).toList();
      return foodLogs;
    } catch (e) {
      throw Exception('Failed to fetch food logs: $e');
    }
  }

  @override
  Future<void> saveFoodLog(FoodLog foodLog) async {
    try {
      await supabase.from('food_logs').insert({
        'user_id': supabase.auth.currentUser!.id,
        'food_name': foodLog.foodName,
        'image_url': foodLog.imageUrl,
        'calories': foodLog.calories,
        'protein': foodLog.protein,
        'fat': foodLog.fat,
        'carbohydrate': foodLog.carbohydrate,
        'created_at': foodLog.createdAt.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to save food log: $e');
    }
  }
}