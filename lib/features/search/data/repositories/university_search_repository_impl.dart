import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/search/data/datasources/university_search_data_source.dart';
import 'package:abroadready/features/search/domain/entities/university_search_filter.dart';
import 'package:abroadready/features/search/domain/repositories/university_search_repository.dart';

class UniversitySearchRepositoryImpl implements UniversitySearchRepository {
  const UniversitySearchRepositoryImpl({
    required UniversitySearchDataSource dataSource,
  }) : _dataSource = dataSource;

  final UniversitySearchDataSource _dataSource;

  @override
  Future<List<String>> getCountryFilters() async {
    final universities = await _dataSource.fetchUniversities();
    final countries = universities
        .map((university) => university.country.trim())
        .where((country) => country.isNotEmpty)
        .toSet()
        .toList();

    countries.sort();
    return countries;
  }

  @override
  Future<List<UniversityEntity>> searchUniversities(
    UniversitySearchFilter filter,
  ) async {
    final universities = await _dataSource.fetchUniversities();
    final query = filter.query.trim().toLowerCase();

    final filtered = universities.where((university) {
      final matchesQuery =
          query.isEmpty ||
          university.name.toLowerCase().contains(query) ||
          university.country.toLowerCase().contains(query) ||
          university.city.toLowerCase().contains(query) ||
          university.searchTokens.any((token) => token.contains(query));

      final matchesCountry =
          filter.country == null || university.country == filter.country;

      final matchesBudget =
          filter.maxMonthlyBudgetEur == null ||
          (university.livingCostPerMonthEur > 0 &&
              university.livingCostPerMonthEur <= filter.maxMonthlyBudgetEur!);

      final matchesRanking =
          filter.maxQsRanking == null ||
          (university.rankingQs > 0 &&
              university.rankingQs <= filter.maxQsRanking!);

      return matchesQuery && matchesCountry && matchesBudget && matchesRanking;
    }).toList();

    filtered.sort((a, b) {
      final aRank = a.rankingQs <= 0 ? 999999 : a.rankingQs;
      final bRank = b.rankingQs <= 0 ? 999999 : b.rankingQs;
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.name.compareTo(b.name);
    });

    return filtered;
  }
}
