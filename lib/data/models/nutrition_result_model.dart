import 'package:bundacare/domain/entities/nutrition_result.dart';

// Model untuk satu item makanan
class FoodItemModel extends FoodItem {
  const FoodItemModel({required super.name, required super.count});

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      name: json['name'] ?? 'N/A',
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

// Model utama untuk hasil deteksi
class NutritionResultModel extends NutritionResult {
  const NutritionResultModel({
    required super.foods,
    required super.totalCalories,
    required super.totalProtein,
    required super.totalFat,
    required super.totalCarbohydrate,
  });

  factory NutritionResultModel.fromJson(Map<String, dynamic> json) {
    // Parse array 'foods'
    final foodsList = (json['foods'] as List<dynamic>?)
        ?.map((item) => FoodItemModel.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    // Parse objek 'total'
    final totalJson = json['total'] as Map<String, dynamic>? ?? {};

    return NutritionResultModel(
      foods: foodsList,
      totalCalories: (totalJson['calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (totalJson['protein'] as num?)?.toDouble() ?? 0.0,
      totalFat: (totalJson['fat'] as num?)?.toDouble() ?? 0.0,
      totalCarbohydrate: (totalJson['carbohydrate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}