import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/home/data/services/university_service.dart';

class UniversitySearchDataSource {
  const UniversitySearchDataSource({
    required UniversityService universityService,
  }) : _universityService = universityService;

  final UniversityService _universityService;

  Future<List<UniversityEntity>> fetchUniversities() {
    return _universityService.watchUniversities().first;
  }
}
