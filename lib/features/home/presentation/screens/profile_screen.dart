import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:abroadready/features/auth/data/services/auth_service.dart';
import 'package:abroadready/features/profile_setup/domain/entities/profile_setup_entity.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/get_current_user_profile_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = sl<AuthService>();
  final GetCurrentUserProfileUseCase _getCurrentUserProfileUseCase =
      sl<GetCurrentUserProfileUseCase>();
  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();

  late Future<_ProfileViewData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  Future<_ProfileViewData> _loadProfileData() async {
    final profile = await _getCurrentUserProfileUseCase();
    final user = _firebaseAuth.currentUser;
    return _ProfileViewData(user: user, profile: profile);
  }

  Future<void> _refresh() async {
    final future = _loadProfileData();
    setState(() {
      _profileFuture = future;
    });
    await future;
  }

  Future<void> _openProfileSetupForEditing() async {
    await Navigator.of(context).pushNamed(AppRoutes.profileSetup);
    if (!mounted) {
      return;
    }
    await _refresh();
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out?'),
          content: const Text('You can sign back in anytime.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await _authService.signOut();
      if (!mounted) {
        return;
      }
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _ProfileBackdrop(),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<_ProfileViewData>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      children: [
                        const SizedBox(height: 100),
                        const Icon(
                          Icons.error_outline,
                          size: 42,
                          color: AppColors.errorRed,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Could not load your profile.',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pull down to refresh.',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  }

                  final data =
                      snapshot.data ??
                      _ProfileViewData(user: null, profile: null);
                  return _ProfileContent(
                    data: data,
                    onEditProfile: _openProfileSetupForEditing,
                    onLogout: _confirmLogout,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3F5FF), Color(0xFFFDF7F1)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -70,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryIndigo.withValues(alpha: 0.14),
              ),
            ),
          ),
          Positioned(
            left: -80,
            top: 180,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7CD5BC).withValues(alpha: 0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.data,
    required this.onEditProfile,
    required this.onLogout,
  });

  final _ProfileViewData data;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final profile = data.profile;
    final displayName = (data.user?.displayName ?? '').trim();
    final email = (data.user?.email ?? '').trim();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const Spacer(),
            Text(
              'Profile',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            IconButton(
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Log Out',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3E44CC), Color(0xFF7076F4)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3E44CC).withValues(alpha: 0.26),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  _initials(displayName, email),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName.isEmpty ? 'Student' : displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email.isEmpty ? 'No email available' : email,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _ActionCard(
          onEditProfile: onEditProfile,
          onHelpline: () {
            Navigator.of(context).pushNamed(AppRoutes.helpline);
          },
        ),
        const SizedBox(height: 16),
        if (profile == null)
          _EmptyProfileCard(onEditProfile: onEditProfile)
        else ...[
          _ProfileSummaryCard(profile: profile),
          const SizedBox(height: 12),
          _PreferenceDetailsCard(profile: profile),
        ],
      ],
    );
  }

  String _initials(String displayName, String email) {
    if (displayName.isNotEmpty) {
      final parts = displayName
          .split(RegExp(r'\s+'))
          .where((part) => part.isNotEmpty)
          .take(2)
          .map((part) => part[0].toUpperCase())
          .toList();
      if (parts.isNotEmpty) {
        return parts.join();
      }
    }

    if (email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }

    return 'AR';
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.onEditProfile, required this.onHelpline});

  final VoidCallback onEditProfile;
  final VoidCallback onHelpline;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Edit Submitted Form'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onHelpline,
                icon: const Icon(Icons.support_agent_rounded),
                label: const Text('Open Student Helpline'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProfileCard extends StatelessWidget {
  const _EmptyProfileCard({required this.onEditProfile});

  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No profile form found yet.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Fill in your study preferences to get better recommendations.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: onEditProfile,
              child: const Text('Start Profile Form'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({required this.profile});

  final ProfileSetupEntity profile;

  @override
  Widget build(BuildContext context) {
    final scoreLabel = profile.englishTestType == 'Not required'
        ? 'Not required'
        : profile.englishTestScore.toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic Snapshot',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetricChip(
                  label: 'GPA',
                  value: profile.cumulativeGpa.toStringAsFixed(2),
                ),
                _MetricChip(label: 'Test', value: profile.englishTestType),
                _MetricChip(label: 'Score', value: scoreLabel),
                _MetricChip(
                  label: 'Degree',
                  value: profile.preferredDegreeType,
                ),
                _MetricChip(
                  label: 'Intake',
                  value: profile.preferredIntakeMonth,
                ),
                _MetricChip(
                  label: 'Language',
                  value: profile.preferredStudyLanguage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceDetailsCard extends StatelessWidget {
  const _PreferenceDetailsCard({required this.profile});

  final ProfileSetupEntity profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Field of study',
              value: profile.fieldOfStudy,
              icon: Icons.school_rounded,
            ),
            _DetailRow(
              label: 'Current location',
              value: profile.currentLocationCountry,
              icon: Icons.public_rounded,
            ),
            _DetailRow(
              label: 'Education level',
              value: profile.currentEducationLevel,
              icon: Icons.workspace_premium_rounded,
            ),
            _DetailRow(
              label: 'Monthly budget',
              value: '€${profile.monthlyLivingBudgetEur}/mo',
              icon: Icons.account_balance_wallet_rounded,
            ),
            _DetailRow(
              label: 'Max tuition/year',
              value: '€${profile.maxTuitionPerYearEur}',
              icon: Icons.receipt_long_rounded,
            ),
            _DetailRow(
              label: 'Max QS ranking',
              value: profile.maxQsRanking.toString(),
              icon: Icons.leaderboard_rounded,
            ),
            _DetailRow(
              label: 'Max Times ranking',
              value: profile.maxTimesRanking.toString(),
              icon: Icons.bar_chart_rounded,
            ),
            const SizedBox(height: 10),
            Text(
              'Target countries',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: profile.targetCountries.isEmpty
                  ? [const Chip(label: Text('No country selected'))]
                  : profile.targetCountries
                        .map((country) => Chip(label: Text(country)))
                        .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            height: 34,
            width: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryIndigo.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryIndigo),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ProfileViewData {
  const _ProfileViewData({required this.user, required this.profile});

  final User? user;
  final ProfileSetupEntity? profile;
}
