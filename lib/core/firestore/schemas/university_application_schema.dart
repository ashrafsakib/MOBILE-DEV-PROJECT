import 'package:cloud_firestore/cloud_firestore.dart';

class UniversityApplicationDocument {
  const UniversityApplicationDocument({
    required this.name,
    required this.isReady,
  });

  final String name;
  final bool isReady;

  factory UniversityApplicationDocument.fromMap(Map<String, dynamic> map) {
    return UniversityApplicationDocument(
      name: (map['name'] as String? ?? '').trim(),
      isReady: map['isReady'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'isReady': isReady};
  }

  UniversityApplicationDocument copyWith({String? name, bool? isReady}) {
    return UniversityApplicationDocument(
      name: name ?? this.name,
      isReady: isReady ?? this.isReady,
    );
  }
}

class UniversityApplicationEntity {
  const UniversityApplicationEntity({
    required this.id,
    required this.universityId,
    required this.universityName,
    required this.universityCity,
    required this.universityCountry,
    required this.documents,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String universityId;
  final String universityName;
  final String universityCity;
  final String universityCountry;
  final List<UniversityApplicationDocument> documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  int get totalDocuments => documents.length;

  int get readyDocuments => documents.where((doc) => doc.isReady).length;

  factory UniversityApplicationEntity.fromMap(Map<String, dynamic> map) {
    return UniversityApplicationEntity(
      id: (map['id'] as String? ?? '').trim(),
      universityId: (map['universityId'] as String? ?? '').trim(),
      universityName: (map['universityName'] as String? ?? '').trim(),
      universityCity: (map['universityCity'] as String? ?? '').trim(),
      universityCountry: (map['universityCountry'] as String? ?? '').trim(),
      documents: (map['documents'] as List<dynamic>? ?? const <dynamic>[])
          .map(
            (item) => UniversityApplicationDocument.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(growable: false),
      createdAt: _dateFromAny(map['createdAt']),
      updatedAt: _dateFromAny(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'universityId': universityId,
      'universityName': universityName,
      'universityCity': universityCity,
      'universityCountry': universityCountry,
      'documents': documents.map((doc) => doc.toMap()).toList(growable: false),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime? _dateFromAny(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
