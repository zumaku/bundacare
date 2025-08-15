import 'package:equatable/equatable.dart';

// Kelas untuk merepresentasikan satu item makanan
class FoodItem extends Equatable {
  final String name;
  final int count;

  const FoodItem({required this.name, required this.count});

  @override
  List<Object?> get props => [name, count];
}

// Kelas utama untuk hasil deteksi
class NutritionResult extends Equatable {
  final List<FoodItem> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbohydrate;

  const NutritionResult({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbohydrate,
  });

  // Helper untuk mendapatkan nama gabungan
  String get combinedFoodName {
    return foods.map((food) => food.name).join(', ');
  }

  @override
  List<Object?> get props => [foods, totalCalories, totalProtein, totalFat, totalCarbohydrate];
}