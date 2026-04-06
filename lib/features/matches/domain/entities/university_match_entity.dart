import 'package:abroadready/core/firestore/schemas/university_schema.dart';

class UniversityMatchEntity {
  const UniversityMatchEntity({
    required this.university,
    required this.matchPercentage,
  });

  final UniversityEntity university;
  final int matchPercentage;
}
