import 'package:flutter/material.dart';

class ArPrimaryButton extends StatelessWidget {
  const ArPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final Widget child = isLoading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      child: icon == null || isLoading
          ? ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: child,
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: icon!,
              label: child,
            ),
    );
  }
}
