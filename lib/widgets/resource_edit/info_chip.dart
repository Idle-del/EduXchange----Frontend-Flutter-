// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    required this.isDark,
    this.accent = false,
    this.accentColor = const Color(0xFF2C5A8C),
  });

  final String label;
  final bool isDark;
  final bool accent;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final color = accent
        ? accentColor
        : (isDark ? Colors.grey[300]! : Colors.grey[700]!);

    final backgroundColor = accent
        ? accentColor.withOpacity(isDark ? 0.18 : 0.08)
        : (isDark ? Colors.grey[850] : Colors.grey[200]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}