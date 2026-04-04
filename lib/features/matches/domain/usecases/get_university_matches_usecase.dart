import 'package:abroadready/features/matches/domain/entities/university_match_entity.dart';
import 'package:abroadready/features/matches/domain/repositories/matches_repository.dart';

class GetUniversityMatchesUseCase {
  const GetUniversityMatchesUseCase(this._repository);

  final MatchesRepository _repository;

  Future<List<UniversityMatchEntity>> call() {
    return _repository.getMatches();
  }
}
