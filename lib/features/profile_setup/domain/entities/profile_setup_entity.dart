class ProfileSetupEntity {
  const ProfileSetupEntity({
    required this.preferredDegreeType,
    required this.preferredIntakeMonth,
    required this.preferredStudyLanguage,
    required this.cumulativeGpa,
    required this.englishTestType,
    required this.englishTestScore,
    required this.currentEducationLevel,
    required this.monthlyLivingBudgetEur,
    required this.targetCountries,
    required this.fieldOfStudy,
    required this.currentLocationCountry,
    required this.maxTuitionPerYearEur,
    required this.maxQsRanking,
    required this.maxTimesRanking,
    required this.isCompleted,
    required this.currentStep,
  });

  final String preferredDegreeType;
  final String preferredIntakeMonth;
  final String preferredStudyLanguage;
  final double cumulativeGpa;
  final String englishTestType;
  final double englishTestScore;
  final String currentEducationLevel;
  final int monthlyLivingBudgetEur;
  final List<String> targetCountries;
  final String fieldOfStudy;
  final String currentLocationCountry;
  final int maxTuitionPerYearEur;
  final int maxQsRanking;
  final int maxTimesRanking;
  final bool isCompleted;
  final int currentStep;

  factory ProfileSetupEntity.empty() {
    return const ProfileSetupEntity(
      preferredDegreeType: '',
      preferredIntakeMonth: '',
      preferredStudyLanguage: '',
      cumulativeGpa: 0,
      englishTestType: '',
      englishTestScore: 0,
      currentEducationLevel: '',
      monthlyLivingBudgetEur: 1200,
      targetCountries: <String>[],
      fieldOfStudy: '',
      currentLocationCountry: '',
      maxTuitionPerYearEur: 25000,
      maxQsRanking: 500,
      maxTimesRanking: 500,
      isCompleted: false,
      currentStep: 1,
    );
  }

  ProfileSetupEntity copyWith({
    String? preferredDegreeType,
    String? preferredIntakeMonth,
    String? preferredStudyLanguage,
    double? cumulativeGpa,
    String? englishTestType,
    double? englishTestScore,
    String? currentEducationLevel,
    int? monthlyLivingBudgetEur,
    List<String>? targetCountries,
    String? fieldOfStudy,
    String? currentLocationCountry,
    int? maxTuitionPerYearEur,
    int? maxQsRanking,
    int? maxTimesRanking,
    bool? isCompleted,
    int? currentStep,
  }) {
    return ProfileSetupEntity(
      preferredDegreeType: preferredDegreeType ?? this.preferredDegreeType,
      preferredIntakeMonth: preferredIntakeMonth ?? this.preferredIntakeMonth,
      preferredStudyLanguage:
          preferredStudyLanguage ?? this.preferredStudyLanguage,
      cumulativeGpa: cumulativeGpa ?? this.cumulativeGpa,
      englishTestType: englishTestType ?? this.englishTestType,
      englishTestScore: englishTestScore ?? this.englishTestScore,
      currentEducationLevel:
          currentEducationLevel ?? this.currentEducationLevel,
      monthlyLivingBudgetEur:
          monthlyLivingBudgetEur ?? this.monthlyLivingBudgetEur,
      targetCountries: targetCountries ?? this.targetCountries,
      fieldOfStudy: fieldOfStudy ?? this.fieldOfStudy,
      currentLocationCountry:
          currentLocationCountry ?? this.currentLocationCountry,
      maxTuitionPerYearEur: maxTuitionPerYearEur ?? this.maxTuitionPerYearEur,
      maxQsRanking: maxQsRanking ?? this.maxQsRanking,
      maxTimesRanking: maxTimesRanking ?? this.maxTimesRanking,
      isCompleted: isCompleted ?? this.isCompleted,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  factory ProfileSetupEntity.fromMap(Map<String, dynamic> map) {
    final targetCountriesRaw = map['targetCountries'];
    return ProfileSetupEntity(
      preferredDegreeType: (map['preferredDegreeType'] as String?) ?? '',
      preferredIntakeMonth: (map['preferredIntakeMonth'] as String?) ?? '',
      preferredStudyLanguage: (map['preferredStudyLanguage'] as String?) ?? '',
      cumulativeGpa: _toDouble(map['cumulativeGpa']),
      englishTestType: (map['englishTestType'] as String?) ?? '',
      englishTestScore: _toDouble(map['englishTestScore']),
      currentEducationLevel: (map['currentEducationLevel'] as String?) ?? '',
      monthlyLivingBudgetEur: _toInt(map['monthlyLivingBudgetEur'], 1200),
      targetCountries: targetCountriesRaw is List
          ? targetCountriesRaw
                .whereType<String>()
                .map((country) => country.trim())
                .where((country) => country.isNotEmpty)
                .toList()
          : <String>[],
      fieldOfStudy: (map['fieldOfStudy'] as String?) ?? '',
      currentLocationCountry: (map['currentLocationCountry'] as String?) ?? '',
      maxTuitionPerYearEur: _toInt(map['maxTuitionPerYearEur'], 25000),
      maxQsRanking: _toInt(map['maxQsRanking'], 500),
      maxTimesRanking: _toInt(map['maxTimesRanking'], 500),
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      currentStep: _toInt(map['currentStep'], 1).clamp(1, 3),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'preferredDegreeType': preferredDegreeType,
      'preferredIntakeMonth': preferredIntakeMonth,
      'preferredStudyLanguage': preferredStudyLanguage,
      'cumulativeGpa': cumulativeGpa,
      'englishTestType': englishTestType,
      'englishTestScore': englishTestScore,
      'currentEducationLevel': currentEducationLevel,
      'monthlyLivingBudgetEur': monthlyLivingBudgetEur,
      'targetCountries': targetCountries,
      'fieldOfStudy': fieldOfStudy,
      'currentLocationCountry': currentLocationCountry,
      'maxTuitionPerYearEur': maxTuitionPerYearEur,
      'maxQsRanking': maxQsRanking,
      'maxTimesRanking': maxTimesRanking,
      'isCompleted': isCompleted,
      'currentStep': currentStep,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse((value ?? '').toString()) ?? 0;
  }

  static int _toInt(dynamic value, int fallback) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse((value ?? '').toString()) ?? fallback;
  }
}
