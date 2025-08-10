import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final _client = Supabase.instance.client;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    // Supabase OAuth flow; mobile/web functional differences exist.
    await _client.auth.signInWithOAuth(OAuthProvider.google);
    return getCurrentUser();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email,
      avatarUrl: user.userMetadata?['avatar_url'],
    );
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
