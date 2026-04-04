import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/search/domain/entities/university_search_filter.dart';
import 'package:abroadready/features/search/domain/usecases/get_country_filters_usecase.dart';
import 'package:abroadready/features/search/domain/usecases/search_universities_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum UniversitySearchStatus { initial, loading, success, failure }

class UniversitySearchState {
  const UniversitySearchState({
    required this.status,
    required this.results,
    required this.countries,
    required this.filter,
    required this.errorMessage,
  });

  final UniversitySearchStatus status;
  final List<UniversityEntity> results;
  final List<String> countries;
  final UniversitySearchFilter filter;
  final String? errorMessage;

  factory UniversitySearchState.initial() {
    return UniversitySearchState(
      status: UniversitySearchStatus.initial,
      results: const <UniversityEntity>[],
      countries: const <String>[],
      filter: UniversitySearchFilter.empty(),
      errorMessage: null,
    );
  }

  UniversitySearchState copyWith({
    UniversitySearchStatus? status,
    List<UniversityEntity>? results,
    List<String>? countries,
    UniversitySearchFilter? filter,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UniversitySearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      countries: countries ?? this.countries,
      filter: filter ?? this.filter,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

sealed class UniversitySearchEvent {
  const UniversitySearchEvent();
}

class UniversitySearchInitialized extends UniversitySearchEvent {
  const UniversitySearchInitialized();
}

class UniversitySearchQueryChanged extends UniversitySearchEvent {
  const UniversitySearchQueryChanged(this.query);

  final String query;
}

class UniversitySearchCountryChanged extends UniversitySearchEvent {
  const UniversitySearchCountryChanged(this.country);

  final String? country;
}

class UniversitySearchBudgetChanged extends UniversitySearchEvent {
  const UniversitySearchBudgetChanged(this.maxMonthlyBudgetEur);

  final int? maxMonthlyBudgetEur;
}

class UniversitySearchRankingChanged extends UniversitySearchEvent {
  const UniversitySearchRankingChanged(this.maxQsRanking);

  final int? maxQsRanking;
}

class UniversitySearchCleared extends UniversitySearchEvent {
  const UniversitySearchCleared();
}

class UniversitySearchBloc
    extends Bloc<UniversitySearchEvent, UniversitySearchState> {
  UniversitySearchBloc({
    required SearchUniversitiesUseCase searchUniversitiesUseCase,
    required GetCountryFiltersUseCase getCountryFiltersUseCase,
  }) : _searchUniversitiesUseCase = searchUniversitiesUseCase,
       _getCountryFiltersUseCase = getCountryFiltersUseCase,
       super(UniversitySearchState.initial()) {
    on<UniversitySearchInitialized>(_onInitialized);
    on<UniversitySearchQueryChanged>(_onQueryChanged);
    on<UniversitySearchCountryChanged>(_onCountryChanged);
    on<UniversitySearchBudgetChanged>(_onBudgetChanged);
    on<UniversitySearchRankingChanged>(_onRankingChanged);
    on<UniversitySearchCleared>(_onCleared);
  }

  final SearchUniversitiesUseCase _searchUniversitiesUseCase;
  final GetCountryFiltersUseCase _getCountryFiltersUseCase;

  Future<void> _onInitialized(
    UniversitySearchInitialized event,
    Emitter<UniversitySearchState> emit,
  ) async {
    emit(
      state.copyWith(status: UniversitySearchStatus.loading, clearError: true),
    );

    try {
      final countries = await _getCountryFiltersUseCase();
      final results = await _searchUniversitiesUseCase(state.filter);
      emit(
        state.copyWith(
          status: UniversitySearchStatus.success,
          countries: countries,
          results: results,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UniversitySearchStatus.failure,
          errorMessage: 'Could not load search results. Please try again.',
        ),
      );
    }
  }

  Future<void> _onQueryChanged(
    UniversitySearchQueryChanged event,
    Emitter<UniversitySearchState> emit,
  ) async {
    await _runSearch(emit, state.filter.copyWith(query: event.query));
  }

  Future<void> _onCountryChanged(
    UniversitySearchCountryChanged event,
    Emitter<UniversitySearchState> emit,
  ) async {
    await _runSearch(
      emit,
      event.country == null
          ? state.filter.copyWith(clearCountry: true)
          : state.filter.copyWith(country: event.country),
    );
  }

  Future<void> _onBudgetChanged(
    UniversitySearchBudgetChanged event,
    Emitter<UniversitySearchState> emit,
  ) async {
    await _runSearch(
      emit,
      event.maxMonthlyBudgetEur == null
          ? state.filter.copyWith(clearBudget: true)
          : state.filter.copyWith(
              maxMonthlyBudgetEur: event.maxMonthlyBudgetEur,
            ),
    );
  }

  Future<void> _onRankingChanged(
    UniversitySearchRankingChanged event,
    Emitter<UniversitySearchState> emit,
  ) async {
    await _runSearch(
      emit,
      event.maxQsRanking == null
          ? state.filter.copyWith(clearRanking: true)
          : state.filter.copyWith(maxQsRanking: event.maxQsRanking),
    );
  }

  Future<void> _onCleared(
    UniversitySearchCleared event,
    Emitter<UniversitySearchState> emit,
  ) async {
    await _runSearch(emit, UniversitySearchFilter.empty());
  }

  Future<void> _runSearch(
    Emitter<UniversitySearchState> emit,
    UniversitySearchFilter nextFilter,
  ) async {
    emit(
      state.copyWith(
        status: UniversitySearchStatus.loading,
        filter: nextFilter,
        clearError: true,
      ),
    );

    try {
      final results = await _searchUniversitiesUseCase(nextFilter);
      emit(
        state.copyWith(
          status: UniversitySearchStatus.success,
          filter: nextFilter,
          results: results,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: UniversitySearchStatus.failure,
          filter: nextFilter,
          errorMessage: 'Could not apply search filters.',
        ),
      );
    }
  }
}
