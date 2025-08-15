import 'package:bundacare/domain/entities/nutrition_result.dart';

// Model untuk satu item makanan
class FoodItemModel extends FoodItem {
  const FoodItemModel({
    required super.name,
    required super.count,
    required super.boundingBoxes, // <-- Ditambahkan ke constructor
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    // Parse array bounding_boxes dari JSON
    final boxes = (json['bounding_boxes'] as List<dynamic>?)
        ?.map((box) => (box as List<dynamic>).map((coord) => (coord as num).toDouble()).toList())
        .toList() ?? [];

    return FoodItemModel(
      name: json['name'] ?? 'N/A',
      count: (json['count'] as num?)?.toInt() ?? 0,
      boundingBoxes: boxes, // <-- Gunakan hasil parse
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
    // HAPUS boundingBoxes dari sini
  });

  factory NutritionResultModel.fromJson(Map<String, dynamic> json) {
    final foodsList = (json['foods'] as List<dynamic>?)
        ?.map((item) => FoodItemModel.fromJson(item as Map<String, dynamic>))
        .toList() ?? [];
    
    final totalJson = json['total'] as Map<String, dynamic>? ?? {};
    
    // HAPUS parsing bounding_boxes dari sini

    return NutritionResultModel(
      foods: foodsList,
      totalCalories: (totalJson['calories'] as num?)?.toDouble() ?? 0.0,
      totalProtein: (totalJson['protein'] as num?)?.toDouble() ?? 0.0,
      totalFat: (totalJson['fat'] as num?)?.toDouble() ?? 0.0,
      totalCarbohydrate: (totalJson['carbohydrate'] as num?)?.toDouble() ?? 0.0,
      // HAPUS boundingBoxes dari sini
    );
  }
}