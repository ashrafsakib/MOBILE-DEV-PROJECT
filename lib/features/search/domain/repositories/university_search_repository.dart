import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/search/domain/entities/university_search_filter.dart';

abstract class UniversitySearchRepository {
  Future<List<UniversityEntity>> searchUniversities(
    UniversitySearchFilter filter,
  );

  Future<List<String>> getCountryFilters();
}
