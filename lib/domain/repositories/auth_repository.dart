import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<void> signInWithGoogle();
  Future<void> signOut();
  User? get currentUser;
  Future<UserProfile> getUserProfile();
  Future<void> updatePregnancyStartDate(DateTime date);
}