import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:abroadready/core/widgets/ar_primary_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Welcome to\nAbroadReady',
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontSize: 48, height: 1.1),
              ),
              const SizedBox(height: 20),
              Text(
                'Your premium gateway to global education. Start your journey with confidence and expert support.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 17, height: 1.5),
              ),
              const SizedBox(height: 32),
              const _BenefitItem(
                icon: FontAwesomeIcons.shieldHalved,
                title: 'Expert guidance',
                description:
                    'Personalized support for your study abroad journey.',
              ),
              const SizedBox(height: 18),
              const _BenefitItem(
                icon: FontAwesomeIcons.clockRotateLeft,
                title: 'Simplified tracking',
                description:
                    'Manage your visa and applications in one dashboard.',
              ),
              const SizedBox(height: 18),
              const _BenefitItem(
                icon: FontAwesomeIcons.users,
                title: 'Global community',
                description: 'Connect with thousands of students worldwide.',
              ),
              const Spacer(),
              ArPrimaryButton(
                label: 'Create Account',
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.signUp),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.login),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Log In',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'DESIGNED FOR THE AMBITIOUS GLOBAL CITIZEN',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.45),
                    letterSpacing: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: FaIcon(icon, size: 17, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontSize: 16, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
