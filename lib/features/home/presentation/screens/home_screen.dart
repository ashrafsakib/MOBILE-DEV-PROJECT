import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/features/auth/data/services/auth_service.dart';
import 'package:abroadready/features/home/data/services/university_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = sl<AuthService>();
  final UniversityService _universityService = sl<UniversityService>();

  bool _isSigningOut = false;
  String? _selectedCountry;
  String? _selectedRegion;
  String? _selectedCity;

  Future<void> _handleSignOut() async {
    setState(() => _isSigningOut = true);

    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to sign out. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  List<UniversityEntity> _applyFilters(List<UniversityEntity> universities) {
    return universities.where((university) {
      final matchesCountry =
          _selectedCountry == null || university.country == _selectedCountry;
      final matchesRegion =
          _selectedRegion == null || university.region == _selectedRegion;
      final matchesCity =
          _selectedCity == null || university.city == _selectedCity;
      return matchesCountry && matchesRegion && matchesCity;
    }).toList();
  }

  List<String> _distinctBy<T>(
    List<UniversityEntity> universities,
    T Function(UniversityEntity university) selector,
  ) {
    final values = universities
        .map(selector)
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();
    values.sort();
    return values;
  }

  void _resetFilters() {
    setState(() {
      _selectedCountry = null;
      _selectedRegion = null;
      _selectedCity = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Universities'),
        actions: [
          IconButton(
            tooltip: 'Clear filters',
            onPressed: _resetFilters,
            icon: const Icon(Icons.filter_alt_off),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: _isSigningOut ? null : _handleSignOut,
            icon: _isSigningOut
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<List<UniversityEntity>>(
        stream: _universityService.watchUniversities(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Could not load universities. Please try again.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final allUniversities = snapshot.data ?? const <UniversityEntity>[];
          if (allUniversities.isEmpty) {
            return Center(
              child: Text(
                'No universities found in Firestore.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final countries = _distinctBy(allUniversities, (u) => u.country);
          final regions = _distinctBy(allUniversities, (u) => u.region);
          final cities = _distinctBy(allUniversities, (u) => u.city);
          final filteredUniversities = _applyFilters(allUniversities);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filteredUniversities.length} of ${allUniversities.length} universities',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _FilterChipRow(
                      label: 'Country',
                      values: countries,
                      selectedValue: _selectedCountry,
                      onSelected: (value) {
                        setState(() {
                          _selectedCountry = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _FilterChipRow(
                      label: 'Region',
                      values: regions,
                      selectedValue: _selectedRegion,
                      onSelected: (value) {
                        setState(() {
                          _selectedRegion = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    _FilterChipRow(
                      label: 'City',
                      values: cities,
                      selectedValue: _selectedCity,
                      onSelected: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredUniversities.isEmpty
                    ? Center(
                        child: Text(
                          'No universities match these filters.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                        itemCount: filteredUniversities.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final university = filteredUniversities[index];
                          return _UniversityCard(university: university);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.label,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final List<String> values;
  final String? selectedValue;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: const Text('All'),
                  selected: selectedValue == null,
                  onSelected: (_) => onSelected(null),
                ),
              ),
              ...values.map(
                (value) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(value),
                    selected: selectedValue == value,
                    onSelected: (_) => onSelected(value),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.universityDetail, arguments: university);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                university.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                '${university.city}, ${university.country}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _MetricChip(
                    label: university.rankingQs > 0
                        ? 'QS #${university.rankingQs}'
                        : 'QS N/A',
                  ),
                  _MetricChip(
                    label: university.rankingTimes > 0
                        ? 'Times #${university.rankingTimes}'
                        : 'Times N/A',
                  ),
                  _MetricChip(
                    label: university.livingCostPerMonthEur > 0
                        ? '€${university.livingCostPerMonthEur}/mo'
                        : 'Cost N/A',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
