import 'package:bundacare/data/datasources/auth_remote_data_source.dart';
import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:bundacare/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> signInWithGoogle() async {
    await remoteDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }
  
  @override
  User? get currentUser => remoteDataSource.currentUser;

  @override
  Future<UserProfile> getUserProfile() async {
    return await remoteDataSource.getUserProfile();
  }

  @override
  Future<void> updatePregnancyStartDate(DateTime date) async { // <-- Tambahkan implementasi ini
    await remoteDataSource.updatePregnancyStartDate(date);
  }
}