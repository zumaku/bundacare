import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/food_log.dart';

class FoodRepositoryImpl {
  final _client = Supabase.instance.client;

  Future<void> saveFoodLog(FoodLog log) async {
    await _client.from('food_logs').insert({
      'user_id': log.userId,
      'food_name': log.foodName,
      'image_url': log.imageUrl,
      'calories': log.calories,
      'protein': log.protein,
      'fat': log.fat,
      'carbohydrate': log.carbohydrate,
    });
  }

  Future<List<FoodLog>> getTodayLogs(String userId) async {
    final res = await _client.from('food_logs').select().eq('user_id', userId).limit(100);
    // Simplified mapping here
    return [];
  }
}
