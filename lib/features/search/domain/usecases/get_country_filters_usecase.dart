import 'package:abroadready/features/search/domain/repositories/university_search_repository.dart';

class GetCountryFiltersUseCase {
  const GetCountryFiltersUseCase(this._repository);

  final UniversitySearchRepository _repository;

  Future<List<String>> call() {
    return _repository.getCountryFilters();
  }
}
