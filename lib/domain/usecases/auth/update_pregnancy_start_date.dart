import 'package:bundacare/domain/repositories/auth_repository.dart';

class UpdatePregnancyStartDate {
  final AuthRepository repository;

  UpdatePregnancyStartDate(this.repository);

  Future<void> call(DateTime date) async {
    return repository.updatePregnancyStartDate(date);
  }
}