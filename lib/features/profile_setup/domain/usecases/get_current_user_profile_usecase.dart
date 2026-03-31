import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';

class GetCurrentUserProfileUseCase {
  const GetCurrentUserProfileUseCase(this._repository);

  final ProfileSetupRepository _repository;

  Future<ProfileSetupEntity?> call() {
    return _repository.getCurrentUserProfile();
  }
}
