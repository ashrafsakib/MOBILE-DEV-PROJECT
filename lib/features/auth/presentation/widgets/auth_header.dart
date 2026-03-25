import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.topIcon,
  });

  final String title;
  final String subtitle;
  final Widget? topIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (topIcon != null) ...[
          Align(alignment: Alignment.center, child: topIcon),
          const SizedBox(height: 20),
        ],
        Text(title, style: Theme.of(context).textTheme.displayLarge),
        const SizedBox(height: 8),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
