import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static late final SupabaseClient client;

  static Future<void> init({required String url, required String anonKey}) async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      debug: true,
    );
    client = Supabase.instance.client;
  }
}
