import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/firestore/schemas/university_schema.dart';
import 'package:abroadready/features/home/data/services/university_application_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UniversityDetailScreen extends StatefulWidget {
  const UniversityDetailScreen({super.key, required this.university});

  final UniversityEntity university;

  @override
  State<UniversityDetailScreen> createState() => _UniversityDetailScreenState();
}

class _UniversityDetailScreenState extends State<UniversityDetailScreen> {
  final UniversityApplicationService _applicationService =
      sl<UniversityApplicationService>();

  int _selectedTabIndex = 0;
  late final Future<List<String>> _requiredDocumentsFuture;

  @override
  void initState() {
    super.initState();
    _requiredDocumentsFuture = _applicationService
        .getRequiredDocumentsForUniversity(widget.university.id);
  }

  Future<void> _onApplyPressed() async {
    try {
      await _applicationService.applyToUniversity(widget.university);
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Application started. Your checklist is now available in Documents.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$error')));
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _OverviewTab(university: widget.university);
      case 1:
        return _RequirementsTab(
          requiredDocumentsFuture: _requiredDocumentsFuture,
        );
      case 2:
        return _CostsTab(university: widget.university);
      case 3:
        return const _DatesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              const SizedBox(height: 14),
              _HeroPanel(university: widget.university),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _onApplyPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4B47DB),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.school_rounded, size: 18),
                  label: const Text('Apply To University'),
                ),
              ),
              const SizedBox(height: 14),
              _TabStrip(
                selectedIndex: _selectedTabIndex,
                onSelected: (index) {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
              ),
              const SizedBox(height: 16),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'AbroadReady',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B1F31),
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

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A466E), Color(0xFF111E34)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'GLOBAL EXCELLENCE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            university.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              height: 1.03,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                CupertinoIcons.location_solid,
                color: Colors.white70,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                '${university.city}, ${university.country}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'Overview',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          _TabItem(
            label: 'Requirements',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          _TabItem(
            label: 'Costs',
            selected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
          _TabItem(
            label: 'Dates',
            selected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEDEFFC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? const Color(0xFF3E45C9)
                  : const Color(0xFF747C99),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoGrid(university: university),
        const SizedBox(height: 24),
        const Text(
          'Program Overview',
          style: TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: Color(0xFF151A2A),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The ${university.name} experience combines academic rigor with strong global exposure. '
          'Located in ${university.city}, this destination offers practical pathways for international students '
          'with focused mentoring, applied projects, and industry-relevant outcomes.',
          style: const TextStyle(
            fontSize: 15,
            height: 1.45,
            color: Color(0xFF606784),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _FactCard(
                title: 'QS Ranking',
                value: university.rankingQs > 0
                    ? '#${university.rankingQs}'
                    : 'N/A',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FactCard(
                title: 'Living Cost',
                value: university.livingCostPerMonthEur > 0
                    ? '€${university.livingCostPerMonthEur}/mo'
                    : 'N/A',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RequirementsTab extends StatelessWidget {
  const _RequirementsTab({required this.requiredDocumentsFuture});

  final Future<List<String>> requiredDocumentsFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: requiredDocumentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final documents = snapshot.data ?? const <String>[];
        if (documents.isEmpty) {
          return const Text(
            'No specific documents found yet. Tap Apply to create a checklist.',
            style: TextStyle(color: Color(0xFF636B88), fontSize: 15),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Required Documents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF151A2A),
              ),
            ),
            const SizedBox(height: 10),
            ...documents.map(
              (document) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.doc_on_doc,
                      size: 16,
                      color: Color(0xFF576086),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF1C243B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CostsTab extends StatelessWidget {
  const _CostsTab({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    final monthlyCost = university.livingCostPerMonthEur;
    final yearlyCost = monthlyCost > 0 ? monthlyCost * 12 : 0;

    return Column(
      children: [
        _FactCard(
          title: 'Estimated Living Cost (Monthly)',
          value: monthlyCost > 0 ? '€$monthlyCost' : 'N/A',
        ),
        const SizedBox(height: 10),
        _FactCard(
          title: 'Estimated Living Cost (Yearly)',
          value: yearlyCost > 0 ? '€$yearlyCost' : 'N/A',
        ),
      ],
    );
  }
}

class _DatesTab extends StatelessWidget {
  const _DatesTab();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Text(
        'Application dates vary by program and intake. Open the Documents tab after applying to track your preparation progress.',
        style: TextStyle(fontSize: 15, color: Color(0xFF616A89), height: 1.4),
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.university});

  final UniversityEntity university;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.42,
      children: [
        const _DetailTile(
          label: 'DURATION',
          value: '24 Months',
          icon: CupertinoIcons.clock,
        ),
        const _DetailTile(
          label: 'LANGUAGE',
          value: 'English (C1)',
          icon: CupertinoIcons.textformat_abc,
        ),
        _DetailTile(
          label: 'DEGREE',
          value: university.rankingQs > 200 ? 'B.Sc. Program' : 'M.Sc. Program',
          icon: CupertinoIcons.book,
        ),
        const _DetailTile(
          label: 'TYPE',
          value: 'Full-Time',
          icon: CupertinoIcons.globe,
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF6A7293)),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF777E9B),
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2437),
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF7B829F),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF20263A),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
