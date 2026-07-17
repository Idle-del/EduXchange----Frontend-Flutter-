import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  final String text;
  final bool isDark;

  const SectionHeading({
    super.key,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: .2,
          color: isDark ? Colors.grey[300] : Colors.grey[800],
        ),
      ),
    );
  }
}