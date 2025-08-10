import 'dart:io';
import 'package:bundacare/core/services/supabase_service.dart';
import 'package:bundacare/data/models/nutrition_result_model.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

abstract class DetectionRemoteDataSource {
  Future<String> uploadImage(File imageFile);
  Future<NutritionResultModel> getNutritionData(String imageUrl);
  Future<void> deleteImage(String imageUrl);
}

class DetectionRemoteDataSourceImpl implements DetectionRemoteDataSource {
  final Dio dio;

  DetectionRemoteDataSourceImpl({required this.dio});

  @override
  Future<String> uploadImage(File imageFile) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    final fileName = '${DateTime.now().toIso8601String()}${p.extension(imageFile.path)}';
    final filePath = '$userId/$fileName';

    await supabase.storage.from('food-images').upload(filePath, imageFile);
    final publicUrl = supabase.storage.from('food-images').getPublicUrl(filePath);
    return publicUrl;
  }

  @override
  Future<NutritionResultModel> getNutritionData(String imageUrl) async {
    const endpoint = 'https://fotota.site/predict';
    try {
      final response = await dio.post(
        endpoint,
        data: {'image_url': imageUrl},
      );
      return NutritionResultModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get nutrition data: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    // Ekstrak path file dari URL lengkap
    final uri = Uri.parse(imageUrl);
    final filePath = uri.pathSegments.sublist(uri.pathSegments.indexOf('food-images') + 1).join('/');

    await supabase.storage.from('food-images').remove([filePath]);
  }
}