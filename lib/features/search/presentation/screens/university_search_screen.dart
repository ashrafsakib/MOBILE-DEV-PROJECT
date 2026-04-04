import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/features/search/presentation/bloc/university_search_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UniversitySearchScreen extends StatelessWidget {
  const UniversitySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UniversitySearchBloc>(
      create: (_) =>
          sl<UniversitySearchBloc>()..add(const UniversitySearchInitialized()),
      child: const _UniversitySearchView(),
    );
  }
}

class _UniversitySearchView extends StatefulWidget {
  const _UniversitySearchView();

  @override
  State<_UniversitySearchView> createState() => _UniversitySearchViewState();
}

class _UniversitySearchViewState extends State<_UniversitySearchView> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickCountry(
    BuildContext context,
    UniversitySearchState state,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('All Countries'),
                trailing: state.filter.country == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(''),
              ),
              ...state.countries.map(
                (country) => ListTile(
                  title: Text(country),
                  trailing: state.filter.country == country
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(country),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;
    context.read<UniversitySearchBloc>().add(
      UniversitySearchCountryChanged(selected.isEmpty ? null : selected),
    );
  }

  Future<void> _pickBudget(
    BuildContext context,
    UniversitySearchState state,
  ) async {
    const options = <int>[1200, 1800, 2400, 3000];
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Any budget'),
                trailing: state.filter.maxMonthlyBudgetEur == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(-1),
              ),
              ...options.map(
                (budget) => ListTile(
                  title: Text('Up to EUR $budget / month'),
                  trailing: state.filter.maxMonthlyBudgetEur == budget
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(budget),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;
    context.read<UniversitySearchBloc>().add(
      UniversitySearchBudgetChanged(selected < 0 ? null : selected),
    );
  }

  Future<void> _pickRanking(
    BuildContext context,
    UniversitySearchState state,
  ) async {
    const options = <int>[100, 250, 500];
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: const Text('Any ranking'),
                trailing: state.filter.maxQsRanking == null
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.of(context).pop(-1),
              ),
              ...options.map(
                (rank) => ListTile(
                  title: Text('Top $rank (QS)'),
                  trailing: state.filter.maxQsRanking == rank
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.of(context).pop(rank),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;
    context.read<UniversitySearchBloc>().add(
      UniversitySearchRankingChanged(selected < 0 ? null : selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FC),
      body: SafeArea(
        child: BlocBuilder<UniversitySearchBloc, UniversitySearchState>(
          builder: (context, state) {
            final isLoading = state.status == UniversitySearchStatus.loading;

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFEAECF8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Search Universities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E2235),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _queryController.clear();
                          context.read<UniversitySearchBloc>().add(
                            const UniversitySearchCleared(),
                          );
                        },
                        child: const Text('RESET'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: [
                      TextField(
                        controller: _queryController,
                        onChanged: (value) {
                          context.read<UniversitySearchBloc>().add(
                            UniversitySearchQueryChanged(value),
                          );
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by university, city, or country',
                          prefixIcon: const Icon(Icons.search_rounded),
                          filled: true,
                          fillColor: const Color(0xFFEDEFF7),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _FilterPill(
                              icon: CupertinoIcons.globe,
                              label: state.filter.country ?? 'Country',
                              selected: state.filter.country != null,
                              onTap: () => _pickCountry(context, state),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              icon: CupertinoIcons.money_dollar_circle,
                              label: state.filter.maxMonthlyBudgetEur == null
                                  ? 'Budget'
                                  : 'EUR ${state.filter.maxMonthlyBudgetEur}',
                              selected:
                                  state.filter.maxMonthlyBudgetEur != null,
                              onTap: () => _pickBudget(context, state),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              icon: CupertinoIcons.star,
                              label: state.filter.maxQsRanking == null
                                  ? 'QS Ranking'
                                  : 'Top ${state.filter.maxQsRanking}',
                              selected: state.filter.maxQsRanking != null,
                              onTap: () => _pickRanking(context, state),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (state.status == UniversitySearchStatus.failure)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            state.errorMessage ?? 'Search failed.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else if (state.results.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Text(
                            'No universities match the selected filters.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      else
                        ...state.results.map(
                          (university) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _SearchResultCard(university: university),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF4B47DB) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? Colors.white : const Color(0xFF687091),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF687091),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(
            context,
          ).pushNamed(AppRoutes.universityDetail, arguments: university);
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                university.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF141827),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    CupertinoIcons.location_solid,
                    size: 13,
                    color: Color(0xFF848BA5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${university.city}, ${university.country}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF737C98),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _InfoChip(
                    label: university.rankingQs > 0
                        ? 'QS #${university.rankingQs}'
                        : 'QS N/A',
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: university.livingCostPerMonthEur > 0
                        ? 'EUR ${university.livingCostPerMonthEur}/mo'
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF616988),
        ),
      ),
    );
  }
}
