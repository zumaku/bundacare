import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  final _client = Supabase.instance.client;

  Future<String> uploadFoodImage(Uint8List bytes, String filename) async {
    final path = 'uploads/$filename';

    await _client.storage
        .from('food_images')
        .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

    final publicUrl = _client.storage.from('food_images').getPublicUrl(path);
    return publicUrl ?? '';
  }
}
