import 'package:equatable/equatable.dart';

// Kelas untuk merepresentasikan satu item makanan
class FoodItem extends Equatable {
  final String name;
  final int count;
  final List<List<double>> boundingBoxes; // <-- Dipindahkan ke sini

  const FoodItem({
    required this.name,
    required this.count,
    required this.boundingBoxes, // <-- Ditambahkan ke constructor
  });

  @override
  List<Object?> get props => [name, count, boundingBoxes];
}

// Kelas utama untuk hasil deteksi
class NutritionResult extends Equatable {
  final List<FoodItem> foods;
  final double totalCalories;
  final double totalProtein;
  final double totalFat;
  final double totalCarbohydrate;
  final Map<String, int>? imageDimensions;
  final List<String> risk;
  // HAPUS boundingBoxes dari sini

  const NutritionResult({
    required this.foods,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalFat,
    required this.totalCarbohydrate,
    required this.imageDimensions,
    required this.risk,
    // HAPUS boundingBoxes dari sini
  });

  String get combinedFoodName {
    return foods.map((food) => food.name).join(', ');
  }

  @override
  List<Object?> get props => [foods, totalCalories, totalProtein, totalFat, totalCarbohydrate, imageDimensions, risk];
}