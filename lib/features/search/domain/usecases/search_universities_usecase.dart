import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/search/domain/entities/university_search_filter.dart';
import 'package:abroadready/features/search/domain/repositories/university_search_repository.dart';

class SearchUniversitiesUseCase {
  const SearchUniversitiesUseCase(this._repository);

  final UniversitySearchRepository _repository;

  Future<List<UniversityEntity>> call(UniversitySearchFilter filter) {
    return _repository.searchUniversities(filter);
  }
}
