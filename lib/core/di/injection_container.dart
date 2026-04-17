import 'package:abroadready/features/auth/data/services/auth_service.dart';
import 'package:abroadready/features/home/data/services/university_application_service.dart';
import 'package:abroadready/features/home/data/services/university_service.dart';
import 'package:abroadready/features/matches/data/datasources/matches_data_source.dart';
import 'package:abroadready/features/matches/data/repositories/matches_repository_impl.dart';
import 'package:abroadready/features/matches/domain/repositories/matches_repository.dart';
import 'package:abroadready/features/matches/domain/usecases/get_university_matches_usecase.dart';
import 'package:abroadready/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:abroadready/features/profile_setup/data/datasources/profile_setup_remote_data_source.dart';
import 'package:abroadready/features/profile_setup/data/repositories/profile_setup_repository_impl.dart';
import 'package:abroadready/features/profile_setup/domain/repositories/profile_setup_repository.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/get_current_user_profile_usecase.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/is_current_user_profile_completed_usecase.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/save_current_user_profile_usecase.dart';
import 'package:abroadready/features/profile_setup/presentation/bloc/profile_setup_bloc.dart';
import 'package:abroadready/features/search/data/datasources/university_search_data_source.dart';
import 'package:abroadready/features/search/data/repositories/university_search_repository_impl.dart';
import 'package:abroadready/features/search/domain/repositories/university_search_repository.dart';
import 'package:abroadready/features/search/domain/usecases/get_country_filters_usecase.dart';
import 'package:abroadready/features/search/domain/usecases/search_universities_usecase.dart';
import 'package:abroadready/features/search/presentation/bloc/university_search_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'service_locator.dart';

Future<void> setupDependencies() async {
  _registerExternalDependencies();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerPresentationLayer();
}

void _registerExternalDependencies() {
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}

void _registerDataSources() {
  sl.registerLazySingleton<AuthService>(
    () => AuthService(firebaseAuth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<ProfileSetupRemoteDataSource>(
    () => ProfileSetupRemoteDataSource(firestore: sl()),
  );
  sl.registerLazySingleton<UniversityService>(
    () => UniversityService(firestore: sl()),
  );
  sl.registerLazySingleton<UniversityApplicationService>(
    () => UniversityApplicationService(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton<UniversitySearchDataSource>(
    () => UniversitySearchDataSource(universityService: sl()),
  );
  sl.registerLazySingleton<MatchesDataSource>(
    () => MatchesDataSource(
      universityService: sl(),
      profileSetupRepository: sl(),
    ),
  );
}

void _registerRepositories() {
  sl.registerLazySingleton<ProfileSetupRepository>(
    () =>
        ProfileSetupRepositoryImpl(firebaseAuth: sl(), remoteDataSource: sl()),
  );
  sl.registerLazySingleton<UniversitySearchRepository>(
    () => UniversitySearchRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton<MatchesRepository>(
    () => MatchesRepositoryImpl(dataSource: sl()),
  );
}

void _registerUseCases() {
  sl.registerLazySingleton<GetCurrentUserProfileUseCase>(
    () => GetCurrentUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<SaveCurrentUserProfileUseCase>(
    () => SaveCurrentUserProfileUseCase(sl()),
  );
  sl.registerLazySingleton<IsCurrentUserProfileCompletedUseCase>(
    () => IsCurrentUserProfileCompletedUseCase(sl()),
  );
  sl.registerLazySingleton<SearchUniversitiesUseCase>(
    () => SearchUniversitiesUseCase(sl()),
  );
  sl.registerLazySingleton<GetCountryFiltersUseCase>(
    () => GetCountryFiltersUseCase(sl()),
  );
  sl.registerLazySingleton<GetUniversityMatchesUseCase>(
    () => GetUniversityMatchesUseCase(sl()),
  );
}

void _registerPresentationLayer() {
  sl.registerFactory<ProfileSetupBloc>(
    () => ProfileSetupBloc(
      getCurrentUserProfileUseCase: sl(),
      saveCurrentUserProfileUseCase: sl(),
    ),
  );
  sl.registerFactory<UniversitySearchBloc>(
    () => UniversitySearchBloc(
      searchUniversitiesUseCase: sl(),
      getCountryFiltersUseCase: sl(),
    ),
  );
  sl.registerFactory<MatchesBloc>(
    () => MatchesBloc(getUniversityMatchesUseCase: sl()),
  );
}
