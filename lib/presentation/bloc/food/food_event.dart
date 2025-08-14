part of 'food_bloc.dart';

abstract class FoodEvent extends Equatable {
  const FoodEvent();

  @override
  List<Object> get props => [];
}

class FetchTodaysFood extends FoodEvent {}

class DeleteFoodLogRequested extends FoodEvent {
  final int id;
  const DeleteFoodLogRequested(this.id);
  @override
  List<Object> get props => [id];
}