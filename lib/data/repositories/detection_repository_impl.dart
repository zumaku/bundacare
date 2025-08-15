import 'dart:io';
import 'package:bundacare/data/datasources/detection_remote_data_source.dart';
import 'package:bundacare/domain/repositories/detection_repository.dart';

class DetectionRepositoryImpl implements DetectionRepository {
  final DetectionRemoteDataSource remoteDataSource;

  DetectionRepositoryImpl({required this.remoteDataSource});

  // Metode ini sekarang menepati janji dengan mengembalikan Future<DetectionData>
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

  // Tambahkan kembali implementasi hapus gambar
  @override
  Future<void> deleteUploadedImage(String imageUrl) async {
    await remoteDataSource.deleteImage(imageUrl);
  }
}