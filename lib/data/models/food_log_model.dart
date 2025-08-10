import 'package:bundacare/domain/entities/food_log.dart';

class FoodLogModel extends FoodLog {
  const FoodLogModel({
    required super.id,
    required super.createdAt,
    required super.foodName,
    required super.imageUrl,
    required super.calories,
    required super.protein,
    required super.fat,
    required super.carbohydrate,
  });

  factory FoodLogModel.fromJson(Map<String, dynamic> json) {
    return FoodLogModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      foodName: json['food_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      calories: (json['calories'] as num?)?.toDouble() ?? 0.0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      carbohydrate: (json['carbohydrate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': createdAt.toIso8601String(),
      'food_name': foodName,
      'image_url': imageUrl,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbohydrate': carbohydrate,
    };
  }
}