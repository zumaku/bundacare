part of 'food_bloc.dart';

abstract class FoodState extends Equatable {
  const FoodState();

  @override
  List<Object> get props => [];
}

class FoodInitial extends FoodState {}

class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final List<FoodLog> foodLogs;

  const FoodLoaded(this.foodLogs);

  // Getters untuk kalkulasi total nutrisi
  double get totalCalories => foodLogs.fold(0, (sum, item) => sum + item.calories);
  double get totalProtein => foodLogs.fold(0, (sum, item) => sum + item.protein);
  double get totalFat => foodLogs.fold(0, (sum, item) => sum + item.fat);
  double get totalCarbohydrate => foodLogs.fold(0, (sum, item) => sum + item.carbohydrate);

  @override
  List<Object> get props => [foodLogs, totalCalories, totalProtein, totalFat, totalCarbohydrate];
}

class FoodError extends FoodState {
  final String message;

  const FoodError(this.message);

  @override
  List<Object> get props => [message];
}

class FoodDeleteSuccess extends FoodState {}