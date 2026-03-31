import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';

class SaveCurrentUserProfileUseCase {
  const SaveCurrentUserProfileUseCase(this._repository);

  final ProfileSetupRepository _repository;

  Future<void> call(ProfileSetupEntity profile) {
    return _repository.saveCurrentUserProfile(profile);
  }
}
