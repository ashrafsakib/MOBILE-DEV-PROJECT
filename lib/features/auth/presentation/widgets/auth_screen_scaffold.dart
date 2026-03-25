import 'package:abroadready/core/widgets/ar_card.dart';
import 'package:flutter/material.dart';

class AuthScreenScaffold extends StatelessWidget {
  const AuthScreenScaffold({super.key, required this.child, this.backButton});

  final Widget child;
  final Widget? backButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (backButton != null)
                Align(alignment: Alignment.centerLeft, child: backButton),
              ArCard(
                child: Padding(padding: const EdgeInsets.all(8), child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
