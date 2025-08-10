import 'package:bundacare/domain/entities/nutrition_result.dart';

class NutritionResultModel extends NutritionResult {
  const NutritionResultModel({
    required super.foodName,
    required super.calories,
    required super.protein,
    required super.fat,
    required super.carbohydrate,
  });

  factory NutritionResultModel.fromJson(Map<String, dynamic> json) {
    // Sesuaikan nama field dengan response aktual dari API Anda
    return NutritionResultModel(
      foodName: json['food_name'] ?? 'Tidak Dikenali',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrate: (json['carbohydrate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}