import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bundacare/domain/entities/food_log.dart';
import 'package:bundacare/domain/entities/nutrition_result.dart';
import 'package:bundacare/domain/usecases/food/detect_from_image.dart';
import 'package:bundacare/domain/usecases/food/save_food_log.dart';
import 'package:bundacare/domain/repositories/detection_repository.dart'; // Import untuk event cancel

part 'detection_event.dart';
part 'detection_state.dart';

class DetectionBloc extends Bloc<DetectionEvent, DetectionState> {
  final DetectFromImage _detectFromImage;
  final SaveFoodLog _saveFoodLog;
  final DetectionRepository _detectionRepository; // Tambahkan untuk cancel

  DetectionBloc({
    required DetectFromImage detectFromImage,
    required SaveFoodLog saveFoodLog,
    required DetectionRepository detectionRepository, // Tambahkan untuk cancel
  })  : _detectFromImage = detectFromImage,
        _saveFoodLog = saveFoodLog,
        _detectionRepository = detectionRepository, // Tambahkan untuk cancel
        super(DetectionInitial()) {

    on<DetectFoodStarted>((event, emit) async {
      emit(DetectionLoading());
      try {
        // Panggilan ini sekarang mengembalikan DetectionData
        final detectionData = await _detectFromImage(event.imageFile);
        // Pisahkan datanya untuk disimpan di state
        emit(DetectionSuccess(detectionData.result, detectionData.imageUrl));
      } catch (e) {
        emit(DetectionFailure(e.toString()));
      }
    });

    on<DetectionSaveRequested>((event, emit) async {
      final currentState = state;
      if (currentState is DetectionSuccess) {
        emit(DetectionSaveInProgress(currentState.result, currentState.imageUrl));
        try {
          final foodLog = FoodLog(
            id: 0,
            createdAt: DateTime.now(),
            foodName: currentState.result.combinedFoodName, // Gunakan nama gabungan
            imageUrl: currentState.imageUrl,
            calories: currentState.result.totalCalories, // Gunakan total
            protein: currentState.result.totalProtein,
            fat: currentState.result.totalFat,
            carbohydrate: currentState.result.totalCarbohydrate,
          );
          await _saveFoodLog(foodLog);
          emit(DetectionSaveSuccess());
        } catch (e) {
          emit(DetectionFailure(e.toString()));
        }
      }
    });
    
    // Tambahkan kembali handler untuk event cancel
    on<DetectionCancelled>((event, emit) async {
      try {
        await _detectionRepository.deleteUploadedImage(event.imageUrl);
      } catch (e) {
        //
      }
    });
  }
}