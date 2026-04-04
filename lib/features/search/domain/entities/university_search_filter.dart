class UniversitySearchFilter {
  const UniversitySearchFilter({
    required this.query,
    required this.country,
    required this.maxMonthlyBudgetEur,
    required this.maxQsRanking,
  });

  final String query;
  final String? country;
  final int? maxMonthlyBudgetEur;
  final int? maxQsRanking;

  factory UniversitySearchFilter.empty() {
    return const UniversitySearchFilter(
      query: '',
      country: null,
      maxMonthlyBudgetEur: null,
      maxQsRanking: null,
    );
  }

  UniversitySearchFilter copyWith({
    String? query,
    String? country,
    int? maxMonthlyBudgetEur,
    int? maxQsRanking,
    bool clearCountry = false,
    bool clearBudget = false,
    bool clearRanking = false,
  }) {
    return UniversitySearchFilter(
      query: query ?? this.query,
      country: clearCountry ? null : (country ?? this.country),
      maxMonthlyBudgetEur: clearBudget
          ? null
          : (maxMonthlyBudgetEur ?? this.maxMonthlyBudgetEur),
      maxQsRanking: clearRanking ? null : (maxQsRanking ?? this.maxQsRanking),
    );
  }
}
