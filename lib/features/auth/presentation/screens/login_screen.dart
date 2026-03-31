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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = sl<AuthService>();
  final IsCurrentUserProfileCompletedUseCase _isProfileCompletedUseCase =
      sl<IsCurrentUserProfileCompletedUseCase>();

  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<String> _resolvePostSignInRoute() async {
    final isCompleted = await _isProfileCompletedUseCase();
    return isCompleted ? AppRoutes.home : AppRoutes.profileSetup;
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter your email to reset password.')),
      );
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
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

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final route = await _resolvePostSignInRoute();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful.')));
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
                if (!_emailRegex.hasMatch(value.trim())) {
                  return 'Enter a valid email address';
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
                  onPressed: _isLoading ? null : _handleForgotPassword,
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
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _handleSignIn,
            ),
            const SizedBox(height: 20),
            SocialAuthSection(
              label: 'OR CONTINUE WITH',
              onGoogleTap: _isLoading ? () {} : _handleGoogleSignIn,
              onGithubTap: _isLoading ? () {} : _handleGithubSignIn,
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
