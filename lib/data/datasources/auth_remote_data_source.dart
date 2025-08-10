import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bundacare/core/services/supabase_service.dart';
import 'package:bundacare/data/models/user_profile_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
  Future<UserProfileModel> getUserProfile(); 
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        // URL untuk redirect setelah login berhasil. HARUS dikonfigurasi di Supabase Dashboard.
        redirectTo: 'io.supabase.bundacare://login-callback/', 
      );
    } catch (e) {
      // Handle error, mungkin dengan custom exception
      throw Exception('Gagal login dengan Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  User? get currentUser => supabase.auth.currentUser;

  @override
  Future<UserProfileModel> getUserProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');
      
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single(); // .single() untuk mengambil satu baris saja

      return UserProfileModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }
}