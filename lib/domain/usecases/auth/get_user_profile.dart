import 'package:bundacare/domain/entities/user_profile.dart';
import 'package:bundacare/domain/repositories/auth_repository.dart';

class GetUserProfile {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  Future<UserProfile> call() async {
    return await repository.getUserProfile();
  }
}