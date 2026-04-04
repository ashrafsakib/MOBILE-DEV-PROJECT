import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/matches/data/datasources/matches_data_source.dart';
import 'package:abroadready/features/matches/domain/entities/university_match_entity.dart';
import 'package:abroadready/features/matches/domain/repositories/matches_repository.dart';
import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';

class MatchesRepositoryImpl implements MatchesRepository {
  const MatchesRepositoryImpl({required MatchesDataSource dataSource})
    : _dataSource = dataSource;

  final MatchesDataSource _dataSource;

  @override
  Future<List<UniversityMatchEntity>> getMatches() async {
    final data = await _dataSource.fetchData();
    final profile = data.profile;

    if (profile == null || !profile.isCompleted) {
      throw StateError('Please complete your profile to get accurate matches.');
    }

    final matches = data.universities
        .map(
          (university) => UniversityMatchEntity(
            university: university,
            matchPercentage: _score(profile, university),
          ),
        )
        .toList();

    matches.sort((a, b) {
      if (a.matchPercentage != b.matchPercentage) {
        return b.matchPercentage.compareTo(a.matchPercentage);
      }
      final aRank = a.university.rankingQs <= 0
          ? 999999
          : a.university.rankingQs;
      final bRank = b.university.rankingQs <= 0
          ? 999999
          : b.university.rankingQs;
      if (aRank != bRank) {
        return aRank.compareTo(bRank);
      }
      return a.university.name.compareTo(b.university.name);
    });

    return matches.take(20).toList();
  }

  int _score(ProfileSetupEntity profile, UniversityEntity university) {
    final country = _countryScore(profile, university);
    final budget = _budgetScore(profile, university);
    final ranking = _rankingScore(profile, university);
    final field = _fieldScore(profile, university);

    final weighted =
        (country * 0.30) + (budget * 0.30) + (ranking * 0.25) + (field * 0.15);

    return weighted.round().clamp(35, 99);
  }

  double _countryScore(
    ProfileSetupEntity profile,
    UniversityEntity university,
  ) {
    final preferredCountries = profile.targetCountries
        .map((country) => country.trim().toLowerCase())
        .where((country) => country.isNotEmpty)
        .toSet();

    if (preferredCountries.isEmpty) {
      return 60;
    }

    return preferredCountries.contains(university.country.toLowerCase())
        ? 100
        : 25;
  }

  double _budgetScore(ProfileSetupEntity profile, UniversityEntity university) {
    if (profile.monthlyLivingBudgetEur <= 0 ||
        university.livingCostPerMonthEur <= 0) {
      return 55;
    }

    if (university.livingCostPerMonthEur <= profile.monthlyLivingBudgetEur) {
      return 100;
    }

    final overBudget =
        university.livingCostPerMonthEur - profile.monthlyLivingBudgetEur;

    return (100 - (overBudget / 12)).clamp(0, 100).toDouble();
  }

  double _rankingScore(
    ProfileSetupEntity profile,
    UniversityEntity university,
  ) {
    if (university.rankingQs <= 0) {
      return 50;
    }

    final preferredRanking = profile.maxQsRanking > 0
        ? profile.maxQsRanking
        : 500;

    if (university.rankingQs <= preferredRanking) {
      return 100;
    }

    final overRanking = university.rankingQs - preferredRanking;
    return (100 - (overRanking / 4)).clamp(0, 100).toDouble();
  }

  double _fieldScore(ProfileSetupEntity profile, UniversityEntity university) {
    final field = profile.fieldOfStudy.trim().toLowerCase();
    if (field.isEmpty) {
      return 60;
    }

    final normalizedName = university.name.toLowerCase();
    if (normalizedName.contains(field)) {
      return 100;
    }

    final tokens = field
        .split(RegExp(r'\s+'))
        .where((token) => token.length > 2)
        .toSet();

    if (tokens.isEmpty) {
      return 45;
    }

    final tokenMatches = university.searchTokens
        .where((token) => tokens.contains(token))
        .length;

    if (tokenMatches == 0) {
      return 40;
    }

    if (tokenMatches >= 2) {
      return 90;
    }

    return 70;
  }
}
