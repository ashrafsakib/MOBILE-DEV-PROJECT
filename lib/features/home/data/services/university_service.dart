import 'package:abroadready/core/firestore/schemas/firestore_collections_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UniversityService {
  const UniversityService({required FirebaseFirestore firestore})
    : _firestore = firestore;

  final FirebaseFirestore _firestore;

  Stream<List<UniversityEntity>> watchUniversities() {
    return _firestore
        .collection(FirestoreCollections.universities)
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UniversityEntity.fromMap(doc.data()))
              .toList();
        });
  }
}
