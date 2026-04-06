import 'package:abroadready/features/matches/domain/entities/university_match_entity.dart';

abstract class MatchesRepository {
  Future<List<UniversityMatchEntity>> getMatches();
}
