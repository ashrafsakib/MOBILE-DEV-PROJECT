import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:abroadready/core/widgets/ar_label.dart';
import 'package:abroadready/core/widgets/ar_primary_button.dart';
import 'package:abroadready/core/widgets/ar_text_field.dart';
import 'package:abroadready/features/auth/presentation/widgets/auth_header.dart';
import 'package:abroadready/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:abroadready/features/auth/presentation/widgets/social_auth_section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(
              title: 'Welcome Back',
              subtitle: 'Please enter your details to sign in',
              topIcon: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: FaIcon(
                    FontAwesomeIcons.lock,
                    size: 24,
                    color: AppColors.primaryIndigo,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const ArLabel('Email Address'),
            const SizedBox(height: 8),
            ArTextField(
              controller: _emailController,
              hintText: 'name@company.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const ArLabel('Password'),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.primaryIndigo,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            ArTextField(
              controller: _passwordController,
              hintText: '••••••••',
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ArPrimaryButton(
              label: 'Sign In',
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {}
              },
            ),
            const SizedBox(height: 20),
            SocialAuthSection(
              label: 'OR CONTINUE WITH',
              onGoogleTap: () {},
              onGithubTap: () {},
            ),
            const SizedBox(height: 22),
            Center(
              child: Wrap(
                children: [
                  Text(
                    'Don\'t have an account? ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.signUp),
                    child: Text(
                      'Sign up for free',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
