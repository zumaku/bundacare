import 'dart:io';
import 'package:bundacare/data/repositories/detection_repository_impl.dart';
import 'package:bundacare/domain/repositories/detection_repository.dart';

class DetectFromImage {
  final DetectionRepository repository;

  DetectFromImage(this.repository);

  // Ganti return type dari Future<NutritionResult> menjadi Future<DetectionData>
  Future<DetectionData> call(File imageFile) async {
    return await repository.detectFromImage(imageFile);
  }
}