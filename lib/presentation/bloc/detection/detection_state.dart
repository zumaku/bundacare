part of 'detection_bloc.dart';

// Kelas abstrak untuk menyatukan state yang membawa data hasil deteksi
abstract class DetectionResultState extends DetectionState {
  final NutritionResult result;
  final String imageUrl;

  const DetectionResultState(this.result, this.imageUrl);

  @override
  List<Object> get props => [result, imageUrl];
}

abstract class DetectionState extends Equatable {
  const DetectionState();
  @override
  List<Object> get props => [];
}

class DetectionInitial extends DetectionState {}

class DetectionLoading extends DetectionState {}

// Sekarang extends DetectionResultState
class DetectionSuccess extends DetectionResultState {
  const DetectionSuccess(super.result, super.imageUrl);
}

// State baru ini juga extends DetectionResultState
class DetectionSaveInProgress extends DetectionResultState {
  const DetectionSaveInProgress(super.result, super.imageUrl);
}

class DetectionSaveSuccess extends DetectionState {}

class DetectionFailure extends DetectionState {
  final String message;
  const DetectionFailure(this.message);
  @override
  List<Object> get props => [message];
}