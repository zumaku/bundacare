import 'package:equatable/equatable.dart';

class NutritionResult extends Equatable {
  final String foodName;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrate;

  const NutritionResult({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
  });

  @override
  List<Object?> get props => [foodName, calories, protein, fat, carbohydrate];
}