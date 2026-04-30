// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/mes_echantillons/widgets/card_widgets/card_buttons.dart
//
// Two reusable button styles used inside EchantillonComCard action rows.
//
//   CardOutlineBtn — bordered, tinted background, custom color
//   CardFilledBtn  — solid green background, white text
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../widgets/col_colors.dart';

// ── Outlined button ──────────────────────────────────────────────────────────
class CardOutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const CardOutlineBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: bgColor ?? color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
                color: borderColor ?? color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Filled button ─────────────────────────────────────────────────────────────
class CardFilledBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const CardFilledBtn({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: colGreen,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 7),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
}
