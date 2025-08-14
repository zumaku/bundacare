import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/usecases/food/delete_food_log.dart';
import 'package:bundacare/domain/usecases/food/get_todays_food_logs.dart';

part 'food_event.dart';
part 'food_state.dart';

class FoodBloc extends Bloc<FoodEvent, FoodState> {
  final GetTodaysFoodLogs _getTodaysFoodLogs;
  final DeleteFoodLog _deleteFoodLog;

  FoodBloc({
    required GetTodaysFoodLogs getTodaysFoodLogs,
    required DeleteFoodLog deleteFoodLog,
  })  : _getTodaysFoodLogs = getTodaysFoodLogs,
        _deleteFoodLog = deleteFoodLog,
        super(FoodInitial()) {
          
    on<FetchTodaysFood>((event, emit) async {
      emit(FoodLoading());
      try {
        final foodLogs = await _getTodaysFoodLogs();
        emit(FoodLoaded(foodLogs));
      } catch (e) {
        // --- INI BAGIAN PENTING ---
        // Jika terjadi error, pancarkan state FoodError
        emit(FoodError(e.toString()));
      }
    });

    on<DeleteFoodLogRequested>((event, emit) async {
      try {
        await _deleteFoodLog(event.id);
        add(FetchTodaysFood()); // Refresh data setelah hapus
      } catch (e) {
        // Anda bisa menambahkan state error khusus untuk hapus jika perlu
        print("Gagal menghapus log: $e");
      }
    });
  }
}