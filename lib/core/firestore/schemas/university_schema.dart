class UniversityEntity {
  const UniversityEntity({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.region,
    required this.rankingQs,
    required this.rankingTimes,
    required this.livingCostPerMonthEur,
    required this.countryKey,
    required this.cityKey,
    required this.regionKey,
    required this.searchTokens,
  });

  final String id;
  final String name;
  final String country;
  final String city;
  final String region;
  final int rankingQs;
  final int rankingTimes;
  final int livingCostPerMonthEur;

  // Normalized fields for fast equality queries in Firestore.
  final String countryKey;
  final String cityKey;
  final String regionKey;

  // Optional keyword matching support for simple contains-like UI experiences.
  final List<String> searchTokens;

  factory UniversityEntity.fromCsvRow(Map<String, String> row) {
    final rowId = (row['university_id'] ?? '').trim();
    final name = (row['university_name'] ?? '').trim();
    final country = (row['country'] ?? '').trim();
    final city = (row['city'] ?? '').trim();
    final region = (row['region'] ?? '').trim();

    return UniversityEntity(
      id: _universityBaseId(rowId),
      name: name,
      country: country,
      city: city,
      region: region,
      rankingQs: _toInt(row['ranking_qs']),
      rankingTimes: _toInt(row['ranking_times']),
      livingCostPerMonthEur: _toInt(row['living_cost_per_month_eur']),
      countryKey: _key(country),
      cityKey: _key(city),
      regionKey: _key(region),
      searchTokens: _searchTokens([name, country, city, region]),
    );
  }

  factory UniversityEntity.fromMap(Map<String, dynamic> map) {
    return UniversityEntity(
      id: (map['id'] as String? ?? '').trim(),
      name: (map['name'] as String? ?? '').trim(),
      country: (map['country'] as String? ?? '').trim(),
      city: (map['city'] as String? ?? '').trim(),
      region: (map['region'] as String? ?? '').trim(),
      rankingQs: _toIntFromAny(map['rankingQs']),
      rankingTimes: _toIntFromAny(map['rankingTimes']),
      livingCostPerMonthEur: _toIntFromAny(map['livingCostPerMonthEur']),
      countryKey: (map['countryKey'] as String? ?? '').trim(),
      cityKey: (map['cityKey'] as String? ?? '').trim(),
      regionKey: (map['regionKey'] as String? ?? '').trim(),
      searchTokens: List<String>.from(
        map['searchTokens'] as List<dynamic>? ?? [],
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'city': city,
      'region': region,
      'rankingQs': rankingQs,
      'rankingTimes': rankingTimes,
      'livingCostPerMonthEur': livingCostPerMonthEur,
      'countryKey': countryKey,
      'cityKey': cityKey,
      'regionKey': regionKey,
      'searchTokens': searchTokens,
    };
  }

  static int _toInt(String? value) {
    return int.tryParse((value ?? '').trim()) ?? 0;
  }

  static int _toIntFromAny(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? 0;
    }
    return 0;
  }

  static String _universityBaseId(String rowId) {
    final normalized = rowId.trim();
    if (normalized.isEmpty) {
      return normalized;
    }

    return normalized.replaceFirst(RegExp(r'_\d+$'), '');
  }

  static String _key(String value) {
    return value.trim().toLowerCase();
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
