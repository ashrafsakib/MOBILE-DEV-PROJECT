import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/features/matches/domain/entities/university_match_entity.dart';
import 'package:abroadready/features/matches/presentation/bloc/matches_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MatchesBloc>(
      create: (_) => sl<MatchesBloc>()..add(const MatchesLoaded()),
      child: const _MatchesView(),
    );
  }
}

class _MatchesView extends StatelessWidget {
  const _MatchesView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state.status == MatchesStatus.loading ||
              state.status == MatchesStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == MatchesStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ??
                          'Could not load your matches right now.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        context.read<MatchesBloc>().add(
                          const MatchesRefreshed(),
                        );
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final matches = state.matches;

          if (matches.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No matches available yet. Update your profile preferences to improve recommendations.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<MatchesBloc>().add(const MatchesRefreshed());
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                const Text(
                  'Your Best Matches',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF141827),
                  ),
                ),
                const SizedBox(height: 6),

                const SizedBox(height: 14),
                ...matches.map(
                  (match) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _MatchUniversityCard(match: match),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MatchUniversityCard extends StatelessWidget {
  const _MatchUniversityCard({required this.match});

  final UniversityMatchEntity match;

  @override
  Widget build(BuildContext context) {
    final university = match.university;

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
              Container(
                height: 146,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9CC6EE), Color(0xFF6E9AD8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          height: 42,
                          width: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            CupertinoIcons.building_2_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      _MatchBadge(percentage: match.matchPercentage),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      university.name,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF141827),
                        height: 1.05,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    university.livingCostPerMonthEur > 0
                        ? '€${university.livingCostPerMonthEur}/mo'
                        : 'Cost N/A',
                    style: const TextStyle(
                      color: Color(0xFF4B47DB),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
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
              const SizedBox(height: 8),
              Text(
                university.rankingQs > 0
                    ? 'QS #${university.rankingQs} ranked university aligned with your study and budget preferences.'
                    : 'Strong option based on your profile preferences and destination priorities.',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7D85A1),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      AppRoutes.universityDetail,
                      arguments: university,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B47DB),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percentage});

  final int percentage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1F7A42).withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percentage% Match',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
