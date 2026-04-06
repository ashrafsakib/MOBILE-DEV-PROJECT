import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/home/data/services/university_service.dart';
import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';

class MatchesDataBundle {
  const MatchesDataBundle({required this.profile, required this.universities});

  final ProfileSetupEntity? profile;
  final List<UniversityEntity> universities;
}

class MatchesDataSource {
  const MatchesDataSource({
    required UniversityService universityService,
    required ProfileSetupRepository profileSetupRepository,
  }) : _universityService = universityService,
       _profileSetupRepository = profileSetupRepository;

  final UniversityService _universityService;
  final ProfileSetupRepository _profileSetupRepository;

  Future<MatchesDataBundle> fetchData() async {
    final profile = await _profileSetupRepository.getCurrentUserProfile();
    final universities = await _universityService.watchUniversities().first;

    return MatchesDataBundle(profile: profile, universities: universities);
  }
}
