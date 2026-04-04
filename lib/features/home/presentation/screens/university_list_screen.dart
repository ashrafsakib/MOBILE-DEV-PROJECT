import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/features/home/data/services/university_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UniversityListScreen extends StatefulWidget {
  const UniversityListScreen({super.key});

  @override
  State<UniversityListScreen> createState() => _UniversityListScreenState();
}

class _UniversityListScreenState extends State<UniversityListScreen> {
  final UniversityService _universityService = sl<UniversityService>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedTrack = 0;

  static const List<String> _tracks = <String>[
    "Master's Degree",
    'Computer Science',
    'Engineering',
    'Business',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UniversityEntity> _applySearch(List<UniversityEntity> universities) {
    if (_searchQuery.trim().isEmpty) {
      return universities;
    }

    final query = _searchQuery.trim().toLowerCase();
    return universities.where((university) {
      return university.name.toLowerCase().contains(query) ||
          university.city.toLowerCase().contains(query) ||
          university.country.toLowerCase().contains(query) ||
          university.searchTokens.any((token) => token.contains(query));
    }).toList();
  }

  int _scoreFor(UniversityEntity university) {
    final rankingScore = university.rankingQs > 0
        ? (120 - (university.rankingQs / 12)).clamp(35, 98).toDouble()
        : 58.0;
    final costScore = university.livingCostPerMonthEur > 0
        ? (100 - ((university.livingCostPerMonthEur - 1600).abs() / 20))
              .clamp(30, 96)
              .toDouble()
        : 60.0;

    return (rankingScore * 0.62 + costScore * 0.38).round().clamp(62, 97);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FC),
      body: SafeArea(
        child: StreamBuilder<List<UniversityEntity>>(
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

            final universities = snapshot.data ?? const <UniversityEntity>[];
            final filtered = _applySearch(universities)
              ..sort((a, b) => _scoreFor(b).compareTo(_scoreFor(a)));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _ListTopBar(onBack: () => Navigator.of(context).pop()),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search universities...',
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
                          children: List.generate(_tracks.length, (index) {
                            final selected = _selectedTrack == index;
                            return Padding(
                              padding: EdgeInsets.only(
                                right: index == _tracks.length - 1 ? 0 : 8,
                              ),
                              child: _TrackChip(
                                label: _tracks[index],
                                selected: selected,
                                onTap: () =>
                                    setState(() => _selectedTrack = index),
                              ),
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 28),
                          child: Text(
                            'No universities found for your search.',
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        )
                      else
                        ...filtered.map(
                          (university) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ListUniversityCard(university: university),
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

class _ListTopBar extends StatelessWidget {
  const _ListTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFFEAECF8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'AbroadReady',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4B47DB),
            ),
          ),
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFFF1D7BC),
          child: Icon(Icons.person, size: 16, color: Color(0xFF312D42)),
        ),
      ],
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF687091),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ListUniversityCard extends StatelessWidget {
  const _ListUniversityCard({required this.university});

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
                  child: Align(
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
                        : '€0/yr',
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
                'A world-renowned institution with strong programs and international pathways for future-focused students.',
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
