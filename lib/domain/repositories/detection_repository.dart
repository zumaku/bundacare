import 'dart:io';
import 'package:bundacare/data/repositories/detection_repository_impl.dart';

abstract class DetectionRepository {
  Future<DetectionData> detectFromImage(File imageFile);
  Future<void> deleteUploadedImage(String imageUrl);
}