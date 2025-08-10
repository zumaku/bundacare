import 'dart:io';
import 'package:bundacare/data/datasources/detection_remote_data_source.dart';
import 'package:bundacare/domain/entities/nutrition_result.dart';
import 'package:bundacare/domain/repositories/detection_repository.dart';

// Definisikan class kecil untuk membungkus hasil
class DetectionData {
  final NutritionResult result;
  final String imageUrl;
  DetectionData(this.result, this.imageUrl);
}

class DetectionRepositoryImpl implements DetectionRepository {
  final DetectionRemoteDataSource remoteDataSource;

  DetectionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DetectionData> detectFromImage(File imageFile) async {
    final imageUrl = await remoteDataSource.uploadImage(imageFile);
    try {
      final nutritionResult = await remoteDataSource.getNutritionData(imageUrl);
      return DetectionData(nutritionResult, imageUrl);
    } catch (e) {
      await remoteDataSource.deleteImage(imageUrl);
      rethrow;
    }
  }

  @override
  Future<void> deleteUploadedImage(String imageUrl) async {
    await remoteDataSource.deleteImage(imageUrl);
  }
}