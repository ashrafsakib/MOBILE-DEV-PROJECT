import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:flutter/material.dart';

class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({super.key, required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(university.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(university.name, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${university.city}, ${university.country}',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            _InfoTile(label: 'Country', value: university.country),
            _InfoTile(label: 'City', value: university.city),
            _InfoTile(label: 'Region', value: university.region),
            _InfoTile(
              label: 'QS Ranking',
              value: university.rankingQs > 0
                  ? '#${university.rankingQs}'
                  : 'Not available',
            ),
            _InfoTile(
              label: 'Times Ranking',
              value: university.rankingTimes > 0
                  ? '#${university.rankingTimes}'
                  : 'Not available',
            ),
            _InfoTile(
              label: 'Living Cost (EUR / month)',
              value: university.livingCostPerMonthEur > 0
                  ? '€${university.livingCostPerMonthEur}'
                  : 'Not available',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
