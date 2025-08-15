import 'dart:io';
import 'package:bundacare/domain/entities/nutrition_result.dart';

// Definisikan kembali kelas wrapper ini di sini
class DetectionData {
  final NutritionResult result;
  final String imageUrl;
  DetectionData(this.result, this.imageUrl);
}

// Kontraknya sekarang WAJIB mengembalikan DetectionData
abstract class DetectionRepository {
  Future<DetectionData> detectFromImage(File imageFile);
  Future<void> deleteUploadedImage(String imageUrl); // Kembalikan juga fungsi hapus
}