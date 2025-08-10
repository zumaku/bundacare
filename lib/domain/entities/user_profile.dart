import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String fullName;
  final String avatarUrl;
  final DateTime? pregnancyStartDate;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
    this.pregnancyStartDate,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, pregnancyStartDate];
}