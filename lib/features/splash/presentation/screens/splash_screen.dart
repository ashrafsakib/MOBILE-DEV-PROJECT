import 'dart:async';

import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _goToWelcome);
  }

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.welcome);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              const Spacer(flex: 3),
              const FaIcon(
                FontAwesomeIcons.graduationCap,
                size: 56,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: 20),
              Text(
                'ABROADREADY',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  letterSpacing: 3,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(strokeWidth: 2.2),
              ),
              const Spacer(flex: 2),
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(999),
                minHeight: 2,
                value: 0.35,
                backgroundColor: AppColors.borderLight,
              ),
              const SizedBox(height: 26),
              Text(
                'YOUR PERSONAL GUIDE TO STUDYING ABROAD',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
