import 'dart:io';
import 'package:bundacare/domain/repositories/detection_repository.dart';

class DetectFromImage {
  final DetectionRepository repository;

  DetectFromImage(this.repository);

  // Return type-nya sekarang sudah benar: Future<DetectionData>
  Future<DetectionData> call(File imageFile) async {
    return await repository.detectFromImage(imageFile);
  }
}