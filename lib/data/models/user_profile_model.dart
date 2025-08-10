import 'package:bundacare/domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.fullName,
    required super.avatarUrl,
    super.pregnancyStartDate,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      pregnancyStartDate: json['pregnancy_start_date'] != null
          ? DateTime.parse(json['pregnancy_start_date'])
          : null,
    );
  }
}