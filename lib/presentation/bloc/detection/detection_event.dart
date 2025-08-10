part of 'detection_bloc.dart';

abstract class DetectionEvent extends Equatable {
  const DetectionEvent();
  @override
  List<Object> get props => [];
}

// Event saat deteksi dimulai
class DetectFoodStarted extends DetectionEvent {
  final File imageFile;
  const DetectFoodStarted(this.imageFile);
  @override
  List<Object> get props => [imageFile];
}

// Event saat tombol Simpan ditekan
class DetectionSaveRequested extends DetectionEvent {}

// Event saat tombol Ulangi/Close ditekan
class DetectionCancelled extends DetectionEvent {
  final String imageUrl;
  const DetectionCancelled(this.imageUrl);
  @override
  List<Object> get props => [imageUrl];
}