import 'package:abroadready/core/firestore/schemas/firestore_collections_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_application_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_program_schema.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UniversityApplicationService {
  UniversityApplicationService({
    required FirebaseFirestore firestore,
    required FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  static const List<String> _fallbackRequiredDocuments = <String>[
    'Academic Transcript',
    'Statement of Purpose',
    'Recommendation Letters',
    'English Proficiency (IELTS/TOEFL)',
    'Passport Copy',
  ];

  Stream<List<UniversityApplicationEntity>> watchMyApplications() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return Stream<List<UniversityApplicationEntity>>.value(
        const <UniversityApplicationEntity>[],
      );
    }

    return _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .collection(FirestoreCollections.applications)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final map = doc.data();
                map['id'] ??= doc.id;
                return UniversityApplicationEntity.fromMap(map);
              })
              .toList(growable: false);
        });
  }

  Future<List<String>> getRequiredDocumentsForUniversity(
    String universityId,
  ) async {
    final result = await _firestore
        .collection(FirestoreCollections.programs)
        .where('universityId', isEqualTo: universityId)
        .get();

    final documents = <String>{};
    for (final doc in result.docs) {
      final program = UniversityProgramEntity.fromMap(doc.data());
      documents.addAll(program.requiredDocuments);
    }

    if (documents.isEmpty) {
      return _fallbackRequiredDocuments;
    }

    return documents.toList(growable: false)..sort();
  }

  Future<void> applyToUniversity(UniversityEntity university) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to apply to universities.');
    }

    final documents = await getRequiredDocumentsForUniversity(university.id);
    final applicationRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .collection(FirestoreCollections.applications)
        .doc(university.id);

    final existing = await applicationRef.get();
    final existingData = existing.data() ?? <String, dynamic>{};
    final existingDocuments =
        (existingData['documents'] as List<dynamic>? ?? const <dynamic>[])
            .map(
              (item) => UniversityApplicationDocument.fromMap(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(growable: false);

    final readyByDocumentName = <String, bool>{
      for (final doc in existingDocuments) doc.name: doc.isReady,
    };

    final checklist = documents
        .map(
          (name) => UniversityApplicationDocument(
            name: name,
            isReady: readyByDocumentName[name] ?? false,
          ),
        )
        .toList(growable: false);

    await applicationRef.set({
      'id': university.id,
      'universityId': university.id,
      'universityName': university.name,
      'universityCity': university.city,
      'universityCountry': university.country,
      'documents': checklist
          .map((item) => item.toMap())
          .toList(growable: false),
      'createdAt': existingData['createdAt'] ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> toggleDocumentReady({
    required String applicationId,
    required String documentName,
    required bool isReady,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('Please sign in to update document status.');
    }

    final applicationRef = _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .collection(FirestoreCollections.applications)
        .doc(applicationId);

    final snapshot = await applicationRef.get();
    if (!snapshot.exists) {
      throw StateError('Application not found. Please apply again.');
    }

    final application = UniversityApplicationEntity.fromMap(snapshot.data()!);
    final updatedDocuments = application.documents
        .map(
          (doc) =>
              doc.name == documentName ? doc.copyWith(isReady: isReady) : doc,
        )
        .toList(growable: false);

    await applicationRef.set({
      'documents': updatedDocuments
          .map((doc) => doc.toMap())
          .toList(growable: false),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
