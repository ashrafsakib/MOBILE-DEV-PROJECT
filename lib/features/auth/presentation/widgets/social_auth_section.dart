import 'package:abroadready/features/auth/presentation/widgets/social_auth_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    super.key,
    required this.onGoogleTap,
    required this.onGithubTap,
    required this.label,
  });

  final VoidCallback onGoogleTap;
  final VoidCallback onGithubTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Expanded(child: Divider(color: Theme.of(context).dividerColor)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            SocialAuthButton(
              label: 'Google',
              icon: SvgPicture.asset(
                'assets/logos/google.svg',
                width: 18,
                height: 18,
              ),
              onTap: onGoogleTap,
            ),
            const SizedBox(width: 12),
            SocialAuthButton(
              label: 'Github',
              icon: SvgPicture.asset(
                'assets/logos/github.svg',
                width: 18,
                height: 18,
              ),
              onTap: onGithubTap,
            ),
          ],
        ),
      ],
    );
  }
}
