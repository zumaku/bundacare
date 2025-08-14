import 'package:bundacare/core/services/supabase_service.dart';
import 'package:bundacare/data/models/food_log_model.dart';
import 'package:bundacare/domain/entities/food_log.dart';

abstract class FoodRemoteDataSource {
  Future<List<FoodLogModel>> getFoodLogsForToday();
  Future<void> saveFoodLog(FoodLog foodLog);
  Future<void> deleteFoodLog(int id);
}

class FoodRemoteDataSourceImpl implements FoodRemoteDataSource {
  @override
  Future<List<FoodLogModel>> getFoodLogsForToday() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Pengguna belum login');

      final now = DateTime.now();
      // Tentukan awal hari (pukul 00:00:00)
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      // Tentukan akhir hari (pukul 23:59:59)
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

      final data = await supabase
          .from('food_logs')
          .select()
          .eq('user_id', userId)
          .gte('created_at', startOfDay) // Lebih besar atau sama dengan awal hari
          .lte('created_at', endOfDay); // Lebih kecil atau sama dengan akhir hari

      final foodLogs = data.map((item) => FoodLogModel.fromJson(item)).toList();
      print("✅ Berhasil mengambil ${foodLogs.length} log makanan untuk hari ini.");
      return foodLogs;
    } catch (e) {
      print("❌ Error di FoodRemoteDataSource: $e");
      throw Exception('Gagal mengambil data log makanan: $e');
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

  @override
  Future<void> deleteFoodLog(int logId) async {
    try {
      await supabase
          .from('food_logs')
          .delete()
          .eq('id', logId);
    } catch (e) {
      throw Exception('Gagal menghapus log makanan: $e');
    }
  }
}