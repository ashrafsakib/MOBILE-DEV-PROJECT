import 'package:abroadready/core/di/service_locator.dart';
import 'package:abroadready/core/navigation/app_routes.dart';
import 'package:abroadready/core/theme/app_colors.dart';
import 'package:abroadready/core/widgets/ar_label.dart';
import 'package:abroadready/core/widgets/ar_primary_button.dart';
import 'package:abroadready/core/widgets/ar_text_field.dart';
import 'package:abroadready/features/auth/data/services/auth_service.dart';
import 'package:abroadready/features/auth/presentation/widgets/auth_header.dart';
import 'package:abroadready/features/auth/presentation/widgets/auth_screen_scaffold.dart';
import 'package:abroadready/features/auth/presentation/widgets/social_auth_section.dart';
import 'package:abroadready/features/profile_setup/domain/usecases/is_current_user_profile_completed_usecase.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = sl<AuthService>();
  final IsCurrentUserProfileCompletedUseCase _isProfileCompletedUseCase =
      sl<IsCurrentUserProfileCompletedUseCase>();

  bool _obscurePassword = true;
  bool _acceptedTerms = false;
  bool _isLoading = false;

  Future<String> _resolvePostSignInRoute() async {
    final isCompleted = await _isProfileCompletedUseCase();
    return isCompleted ? AppRoutes.home : AppRoutes.profileSetup;
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      final route = await _resolvePostSignInRoute();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.readableErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGithubSignIn() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGithub();
      final route = await _resolvePostSignInRoute();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.readableErrorMessage(error))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCreateAccount() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms of Service and Privacy Policy.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.createUserWithEmailAndPassword(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final route = await _resolvePostSignInRoute();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully.')),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_authService.readableErrorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenScaffold(
      backButton: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, size: 18),
        label: const Text('BACK'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthHeader(
              title: 'Create Account',
              subtitle: 'Join our community and start your journey today.',
            ),
            const SizedBox(height: 24),
            const ArLabel('Full Name'),
            const SizedBox(height: 8),
            ArTextField(
              controller: _fullNameController,
              hintText: 'John Doe',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            const ArLabel('Email Address'),
            const SizedBox(height: 8),
            ArTextField(
              controller: _emailController,
              hintText: 'john@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!_emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            const ArLabel('Password'),
            const SizedBox(height: 8),
            ArTextField(
              controller: _passwordController,
              hintText: '••••••••',
              obscureText: _obscurePassword,
              onChanged: (_) => setState(() {}),
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 8) {
                  return 'At least 8 characters required';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _PasswordStrengthBar(password: _passwordController.text),
            const SizedBox(height: 8),
            Text(
              'Minimum 8 characters with one special symbol.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _acceptedTerms,
              onChanged: (value) {
                setState(() {
                  _acceptedTerms = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge,
                  children: const [
                    TextSpan(text: 'I agree to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: AppColors.primaryIndigo,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ArPrimaryButton(
              label: 'Create Account',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleCreateAccount,
            ),
            const SizedBox(height: 20),
            SocialAuthSection(
              label: 'OR SIGN UP WITH',
              onGoogleTap: _isLoading ? () {} : _handleGoogleSignIn,
              onGithubTap: _isLoading ? () {} : _handleGithubSignIn,
            ),
            const SizedBox(height: 22),
            Center(
              child: Wrap(
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(AppRoutes.login),
                    child: Text(
                      'Log in',
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

class _PasswordStrengthBar extends StatelessWidget {
  const _PasswordStrengthBar({required this.password});

  final String password;

  int get _score {
    var score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: List.generate(4, (index) {
            final isActive = index < _score;
            return Container(
              width: (constraints.maxWidth - 18) / 4,
              height: 3,
              margin: EdgeInsets.only(right: index == 3 ? 0 : 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryIndigo
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        );
      },
    );
  }
}
