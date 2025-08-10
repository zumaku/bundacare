import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bundacare/core/services/supabase_service.dart';

abstract class AuthRemoteDataSource {
  Future<void> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
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
}