import 'package:abroadready/features/profile_setup/data/datasources/profile_setup_remote_data_source.dart';
import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupRepositoryImpl implements ProfileSetupRepository {
  ProfileSetupRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required ProfileSetupRemoteDataSource remoteDataSource,
  }) : _firebaseAuth = firebaseAuth,
       _remoteDataSource = remoteDataSource;

  final FirebaseAuth _firebaseAuth;
  final ProfileSetupRemoteDataSource _remoteDataSource;

  @override
  Future<ProfileSetupEntity?> getCurrentUserProfile() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user found.');
    }

    return _remoteDataSource.getProfile(uid: user.uid);
  }

  @override
  Future<bool> isCurrentUserProfileCompleted() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Future<bool>.value(false);
    }

    return _remoteDataSource.isProfileCompleted(uid: user.uid);
  }

  @override
  Future<void> saveCurrentUserProfile(ProfileSetupEntity profile) {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('No signed-in user found.');
    }

    return _remoteDataSource.saveProfile(uid: user.uid, profile: profile);
  }
}
