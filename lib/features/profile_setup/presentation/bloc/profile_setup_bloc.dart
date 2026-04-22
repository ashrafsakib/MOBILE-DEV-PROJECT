import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/get_current_user_profile_usecase.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/save_current_user_profile_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ProfileSetupSubmissionStatus { initial, loading, saving, success, failure }

class ProfileSetupState {
  const ProfileSetupState({
    required this.profile,
    required this.currentStep,
    required this.status,
    required this.errorMessage,
  });

  final ProfileSetupEntity profile;
  final int currentStep;
  final ProfileSetupSubmissionStatus status;
  final String? errorMessage;

  factory ProfileSetupState.initial() {
    return ProfileSetupState(
      profile: ProfileSetupEntity.empty(),
      currentStep: 1,
      status: ProfileSetupSubmissionStatus.initial,
      errorMessage: null,
    );
  }

  ProfileSetupState copyWith({
    ProfileSetupEntity? profile,
    int? currentStep,
    ProfileSetupSubmissionStatus? status,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileSetupState(
      profile: profile ?? this.profile,
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

sealed class ProfileSetupEvent {
  const ProfileSetupEvent();
}

class ProfileSetupLoaded extends ProfileSetupEvent {
  const ProfileSetupLoaded();
}

class ProfileSetupStepOneSubmitted extends ProfileSetupEvent {
  const ProfileSetupStepOneSubmitted({
    required this.preferredDegreeType,
    required this.preferredIntakeMonth,
    required this.preferredStudyLanguage,
  });

  final String preferredDegreeType;
  final String preferredIntakeMonth;
  final String preferredStudyLanguage;
}

class ProfileSetupStepTwoSubmitted extends ProfileSetupEvent {
  const ProfileSetupStepTwoSubmitted({
    required this.cumulativeGpa,
    required this.englishTestType,
    required this.englishTestScore,
    required this.currentEducationLevel,
  });

  final double cumulativeGpa;
  final String englishTestType;
  final double englishTestScore;
  final String currentEducationLevel;
}

class ProfileSetupStepThreeSubmitted extends ProfileSetupEvent {
  const ProfileSetupStepThreeSubmitted({
    required this.monthlyLivingBudgetEur,
    required this.targetCountries,
    required this.fieldOfStudy,
    required this.currentLocationCountry,
    required this.maxTuitionPerYearEur,
    required this.maxQsRanking,
    required this.maxTimesRanking,
  });

  final int monthlyLivingBudgetEur;
  final List<String> targetCountries;
  final String fieldOfStudy;
  final String currentLocationCountry;
  final int maxTuitionPerYearEur;
  final int maxQsRanking;
  final int maxTimesRanking;
}

class ProfileSetupPreviousStepPressed extends ProfileSetupEvent {
  const ProfileSetupPreviousStepPressed();
}

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  ProfileSetupBloc({
    required GetCurrentUserProfileUseCase getCurrentUserProfileUseCase,
    required SaveCurrentUserProfileUseCase saveCurrentUserProfileUseCase,
  }) : _getCurrentUserProfileUseCase = getCurrentUserProfileUseCase,
       _saveCurrentUserProfileUseCase = saveCurrentUserProfileUseCase,
       super(ProfileSetupState.initial()) {
    on<ProfileSetupLoaded>(_onLoaded);
    on<ProfileSetupStepOneSubmitted>(_onStepOneSubmitted);
    on<ProfileSetupStepTwoSubmitted>(_onStepTwoSubmitted);
    on<ProfileSetupStepThreeSubmitted>(_onStepThreeSubmitted);
    on<ProfileSetupPreviousStepPressed>(_onPreviousStepPressed);
  }

  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase;
  final SaveCurrentUserProfileUseCase _saveCurrentUserProfileUseCase;

  Future<void> _onLoaded(
    ProfileSetupLoaded event,
    Emitter<ProfileSetupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProfileSetupSubmissionStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final profile = await _getCurrentUserProfileUseCase();
      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileSetupSubmissionStatus.initial,
            profile: ProfileSetupEntity.empty(),
            currentStep: 1,
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.initial,
          profile: profile,
          currentStep: profile.isCompleted ? 1 : profile.currentStep,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.failure,
          errorMessage: 'Could not load profile setup progress.',
        ),
      );
    }
  }

  Future<void> _onStepOneSubmitted(
    ProfileSetupStepOneSubmitted event,
    Emitter<ProfileSetupState> emit,
  ) async {
    final updatedProfile = state.profile.copyWith(
      preferredDegreeType: event.preferredDegreeType,
      preferredIntakeMonth: event.preferredIntakeMonth,
      preferredStudyLanguage: event.preferredStudyLanguage,
      currentStep: 2,
      isCompleted: false,
    );

    emit(
      state.copyWith(
        status: ProfileSetupSubmissionStatus.saving,
        profile: updatedProfile,
        clearErrorMessage: true,
      ),
    );

    try {
      await _saveCurrentUserProfileUseCase(updatedProfile);
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.initial,
          profile: updatedProfile,
          currentStep: 2,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.failure,
          errorMessage: 'Could not save step 1. Please try again.',
        ),
      );
    }
  }

  Future<void> _onStepTwoSubmitted(
    ProfileSetupStepTwoSubmitted event,
    Emitter<ProfileSetupState> emit,
  ) async {
    final updatedProfile = state.profile.copyWith(
      cumulativeGpa: event.cumulativeGpa,
      englishTestType: event.englishTestType,
      englishTestScore: event.englishTestScore,
      currentEducationLevel: event.currentEducationLevel,
      currentStep: 3,
      isCompleted: false,
    );

    emit(
      state.copyWith(
        status: ProfileSetupSubmissionStatus.saving,
        profile: updatedProfile,
        clearErrorMessage: true,
      ),
    );

    try {
      await _saveCurrentUserProfileUseCase(updatedProfile);
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.initial,
          profile: updatedProfile,
          currentStep: 3,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.failure,
          errorMessage: 'Could not save step 2. Please try again.',
        ),
      );
    }
  }

  Future<void> _onStepThreeSubmitted(
    ProfileSetupStepThreeSubmitted event,
    Emitter<ProfileSetupState> emit,
  ) async {
    final updatedProfile = state.profile.copyWith(
      monthlyLivingBudgetEur: event.monthlyLivingBudgetEur,
      targetCountries: event.targetCountries,
      fieldOfStudy: event.fieldOfStudy,
      currentLocationCountry: event.currentLocationCountry,
      maxTuitionPerYearEur: event.maxTuitionPerYearEur,
      maxQsRanking: event.maxQsRanking,
      maxTimesRanking: event.maxTimesRanking,
      currentStep: 3,
      isCompleted: true,
    );

    emit(
      state.copyWith(
        status: ProfileSetupSubmissionStatus.saving,
        profile: updatedProfile,
        clearErrorMessage: true,
      ),
    );

    try {
      await _saveCurrentUserProfileUseCase(updatedProfile);
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.success,
          profile: updatedProfile,
          currentStep: 3,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileSetupSubmissionStatus.failure,
          errorMessage: 'Could not complete profile setup. Please try again.',
        ),
      );
    }
  }

  void _onPreviousStepPressed(
    ProfileSetupPreviousStepPressed event,
    Emitter<ProfileSetupState> emit,
  ) {
    if (state.currentStep <= 1) {
      return;
    }

    emit(
      state.copyWith(
        currentStep: state.currentStep - 1,
        status: ProfileSetupSubmissionStatus.initial,
        clearErrorMessage: true,
      ),
    );
  }
}
