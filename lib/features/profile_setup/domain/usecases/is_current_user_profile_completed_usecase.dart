import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';

class IsCurrentUserProfileCompletedUseCase {
  const IsCurrentUserProfileCompletedUseCase(this._repository);

  final ProfileSetupRepository _repository;

  Future<bool> call() {
    return _repository.isCurrentUserProfileCompleted();
  }
}
