import 'package:abroadready/core/firestore/schemas/firestore_collections_schema.dart';
import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileSetupRemoteDataSource {
  ProfileSetupRemoteDataSource({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Future<ProfileSetupEntity?> getProfile({required String uid}) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    final map = snapshot.data();
    if (map == null) {
      return null;
    }

    final profileMap = map['profileSetup'];
    if (profileMap is! Map<String, dynamic>) {
      return null;
    }

    return ProfileSetupEntity.fromMap(profileMap);
  }

  Future<void> saveProfile({
    required String uid,
    required ProfileSetupEntity profile,
  }) async {
    await _firestore.collection(FirestoreCollections.users).doc(uid).set({
      'profileSetup': profile.toMap(),
      'profileCompleted': profile.isCompleted,
    }, SetOptions(merge: true));
  }

  Future<bool> isProfileCompleted({required String uid}) async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    final map = snapshot.data();
    if (map == null) {
      return false;
    }

    final completed = map['profileCompleted'];
    if (completed is bool) {
      return completed;
    }

    final profileMap = map['profileSetup'];
    if (profileMap is! Map<String, dynamic>) {
      return false;
    }

    return (profileMap['isCompleted'] as bool?) ?? false;
  }
}
