import 'package:abroadready/features/matches/domain/entities/university_match_entity.dart';
import 'package:abroadready/features/matches/domain/usecases/get_university_matches_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum MatchesStatus { initial, loading, success, failure }

class MatchesState {
  const MatchesState({
    required this.status,
    required this.matches,
    required this.errorMessage,
  });

  final MatchesStatus status;
  final List<UniversityMatchEntity> matches;
  final String? errorMessage;

  factory MatchesState.initial() {
    return const MatchesState(
      status: MatchesStatus.initial,
      matches: <UniversityMatchEntity>[],
      errorMessage: null,
    );
  }

  MatchesState copyWith({
    MatchesStatus? status,
    List<UniversityMatchEntity>? matches,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MatchesState(
      status: status ?? this.status,
      matches: matches ?? this.matches,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

sealed class MatchesEvent {
  const MatchesEvent();
}

class MatchesLoaded extends MatchesEvent {
  const MatchesLoaded();
}

class MatchesRefreshed extends MatchesEvent {
  const MatchesRefreshed();
}

class MatchesBloc extends Bloc<MatchesEvent, MatchesState> {
  MatchesBloc({
    required GetUniversityMatchesUseCase getUniversityMatchesUseCase,
  }) : _getUniversityMatchesUseCase = getUniversityMatchesUseCase,
       super(MatchesState.initial()) {
    on<MatchesLoaded>(_onLoad);
    on<MatchesRefreshed>(_onLoad);
  }

  final GetUniversityMatchesUseCase _getUniversityMatchesUseCase;

  Future<void> _onLoad(MatchesEvent event, Emitter<MatchesState> emit) async {
    emit(state.copyWith(status: MatchesStatus.loading, clearError: true));

    try {
      final matches = await _getUniversityMatchesUseCase();
      emit(state.copyWith(status: MatchesStatus.success, matches: matches));
    } on StateError catch (error) {
      emit(
        state.copyWith(
          status: MatchesStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: MatchesStatus.failure,
          errorMessage: 'Could not load university matches. Please try again.',
        ),
      );
    }
  }
}
