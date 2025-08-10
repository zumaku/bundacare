import 'package:equatable/equatable.dart';

class FoodLog extends Equatable {
  final int id;
  final DateTime createdAt;
  final String foodName;
  final String imageUrl;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrate;

  const FoodLog({
    required this.id,
    required this.createdAt,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
  });

  @override
  List<Object?> get props => [id, createdAt, foodName, imageUrl, calories, protein, fat, carbohydrate];
}