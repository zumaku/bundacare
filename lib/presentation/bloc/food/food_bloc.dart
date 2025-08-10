import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/usecases/food/get_todays_food_logs.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetTodaysFoodLogs _getTodaysFoodLogs;

  FoodBloc({required GetTodaysFoodLogs getTodaysFoodLogs})
      : _getTodaysFoodLogs = getTodaysFoodLogs,
        super(FoodInitial()) {
    on<FetchTodaysFood>((event, emit) async {
      emit(FoodLoading());
      try {
        final foodLogs = await _getTodaysFoodLogs();
        emit(FoodLoaded(foodLogs));
      } catch (e) {
        emit(FoodError(e.toString()));
      }
    });
  }
}