import 'package:flutter/material.dart';

class ArLabel extends StatelessWidget {
  const ArLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge,
    );
  }
}
