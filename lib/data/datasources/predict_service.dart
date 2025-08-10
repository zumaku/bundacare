import 'package:dio/dio.dart';

class PredictService {
  final Dio dio;
  PredictService(this.dio);

  Future<Map<String, dynamic>> predictFromImageUrl(String imageUrl) async {
    final response = await dio.post('https://fotota.site/predict', data: {'image_url': imageUrl});
    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(response.data);
    }
    throw Exception('Prediction failed with status: \${response.statusCode}');
  }
}
