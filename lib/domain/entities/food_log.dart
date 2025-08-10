class FoodLog {
  final int? id;
  final String userId;
  final String foodName;
  final String imageUrl;
  final double calories;
  final double protein;
  final double fat;
  final double carbohydrate;
  final DateTime createdAt;

  FoodLog({
    this.id,
    required this.userId,
    required this.foodName,
    required this.imageUrl,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
    required this.createdAt,
  });
}
