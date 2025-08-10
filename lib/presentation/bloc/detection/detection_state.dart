part of 'detection_bloc.dart';

abstract class DetectionState extends Equatable {
  const DetectionState();
  @override
  List<Object> get props => [];
}

class DetectionInitial extends DetectionState {}

class DetectionLoading extends DetectionState {}

// State saat deteksi berhasil dan menampilkan data
class DetectionSuccess extends DetectionState {
  final NutritionResult result;
  final String imageUrl;

  const DetectionSuccess(this.result, this.imageUrl);
  @override
  List<Object> get props => [result, imageUrl];
}

// State saat proses penyimpanan berhasil
class DetectionSaveSuccess extends DetectionState {}

// State saat terjadi kegagalan (deteksi atau simpan)
class DetectionFailure extends DetectionState {
  final String message;
  const DetectionFailure(this.message);
  @override
  List<Object> get props => [message];
}