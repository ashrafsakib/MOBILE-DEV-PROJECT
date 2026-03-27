class UniversityProgramEntity {
  const UniversityProgramEntity({
    required this.id,
    required this.universityId,
    required this.programName,
    required this.degreeType,
    required this.studyLanguage,
    required this.tuitionPerYearEur,
    required this.applicationDeadline,
    required this.intakeMonth,
    required this.englishLanguageRequirement,
    required this.academicRequirement,
    required this.requiredDocuments,
    required this.averageProcessingTimeMonths,
    required this.degreeTypeKey,
    required this.studyLanguageKey,
    required this.intakeMonthKey,
    required this.searchTokens,
  });

  final String id;
  final String universityId;
  final String programName;
  final String degreeType;
  final String studyLanguage;
  final int tuitionPerYearEur;
  final DateTime? applicationDeadline;
  final String intakeMonth;
  final String englishLanguageRequirement;
  final String academicRequirement;
  final List<String> requiredDocuments;
  final int averageProcessingTimeMonths;

  // Normalized fields for fast equality queries in Firestore.
  final String degreeTypeKey;
  final String studyLanguageKey;
  final String intakeMonthKey;

  // Optional keyword matching support for simple contains-like UI experiences.
  final List<String> searchTokens;

  factory UniversityProgramEntity.fromCsvRow(Map<String, String> row) {
    final rowId = (row['university_id'] ?? '').trim();
    final programName = (row['program_name'] ?? '').trim();
    final degreeType = (row['degree_type'] ?? '').trim();
    final studyLanguage = (row['study_language'] ?? '').trim();
    final intakeMonth = (row['intake_month'] ?? '').trim();
    final englishReq = (row['english_language_requirement'] ?? '').trim();
    final academicReq = (row['academic_requirement'] ?? '').trim();

    return UniversityProgramEntity(
      id: rowId,
      universityId: _universityBaseId(rowId),
      programName: programName,
      degreeType: degreeType,
      studyLanguage: studyLanguage,
      tuitionPerYearEur: _toInt(row['tuition_per_year_eur']),
      applicationDeadline: _toDate(row['application_deadline']),
      intakeMonth: intakeMonth,
      englishLanguageRequirement: englishReq,
      academicRequirement: academicReq,
      requiredDocuments: _splitCsvList(row['required_documents']),
      averageProcessingTimeMonths: _toProcessingMonths(
        row['average_processing_time'],
      ),
      degreeTypeKey: _key(degreeType),
      studyLanguageKey: _key(studyLanguage),
      intakeMonthKey: _key(intakeMonth),
      searchTokens: _searchTokens([
        programName,
        degreeType,
        studyLanguage,
        intakeMonth,
      ]),
    );
  }

  factory UniversityProgramEntity.fromMap(Map<String, dynamic> map) {
    return UniversityProgramEntity(
      id: map['id'] as String,
      universityId: map['universityId'] as String,
      programName: map['programName'] as String,
      degreeType: map['degreeType'] as String,
      studyLanguage: map['studyLanguage'] as String,
      tuitionPerYearEur: map['tuitionPerYearEur'] as int,
      applicationDeadline: _fromStoredDate(map['applicationDeadline']),
      intakeMonth: map['intakeMonth'] as String,
      englishLanguageRequirement: map['englishLanguageRequirement'] as String,
      academicRequirement: map['academicRequirement'] as String,
      requiredDocuments: List<String>.from(map['requiredDocuments'] as List),
      averageProcessingTimeMonths: map['averageProcessingTimeMonths'] as int,
      degreeTypeKey: map['degreeTypeKey'] as String,
      studyLanguageKey: map['studyLanguageKey'] as String,
      intakeMonthKey: map['intakeMonthKey'] as String,
      searchTokens: List<String>.from(map['searchTokens'] as List),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'universityId': universityId,
      'programName': programName,
      'degreeType': degreeType,
      'studyLanguage': studyLanguage,
      'tuitionPerYearEur': tuitionPerYearEur,
      'applicationDeadline': applicationDeadline,
      'intakeMonth': intakeMonth,
      'englishLanguageRequirement': englishLanguageRequirement,
      'academicRequirement': academicRequirement,
      'requiredDocuments': requiredDocuments,
      'averageProcessingTimeMonths': averageProcessingTimeMonths,
      'degreeTypeKey': degreeTypeKey,
      'studyLanguageKey': studyLanguageKey,
      'intakeMonthKey': intakeMonthKey,
      'searchTokens': searchTokens,
    };
  }

  static int _toInt(String? value) {
    return int.tryParse((value ?? '').trim()) ?? 0;
  }

  static DateTime? _toDate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  static DateTime? _fromStoredDate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    try {
      return (value as dynamic).toDate() as DateTime;
    } catch (_) {
      return null;
    }
  }

  static List<String> _splitCsvList(String? value) {
    return (value ?? '')
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static int _toProcessingMonths(String? value) {
    final raw = (value ?? '').toLowerCase();
    final match = RegExp(r'\d+').firstMatch(raw);
    if (match == null) {
      return 0;
    }
    return int.tryParse(match.group(0) ?? '') ?? 0;
  }

  static String _key(String value) {
    return value.trim().toLowerCase();
  }

  static String _universityBaseId(String rowId) {
    final normalized = rowId.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    return normalized.replaceFirst(RegExp(r'_\d+$'), '');
  }

  static List<String> _searchTokens(List<String> values) {
    final tokens = <String>{};

    for (final value in values) {
      final words = value
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9 ]'), ' ')
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty);

      tokens.addAll(words);
    }

    return tokens.toList()..sort();
  }
}
