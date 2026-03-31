import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';

abstract class ProfileSetupRepository {
  Future<ProfileSetupEntity?> getCurrentUserProfile();
  Future<void> saveCurrentUserProfile(ProfileSetupEntity profile);
  Future<bool> isCurrentUserProfileCompleted();
}
