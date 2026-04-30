// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/filtre_chip.dart
// PURPOSE : one filter button (Tous / En attente / En cours / Soumis)
// IMPORTANT : this widget does NOT call setState itself
//             it receives isSelected and onTap FROM the page
//             setState is called in gestion_echantillons_page.dart
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);

class FiltreChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap; // VoidCallback = function that returns nothing

  const FiltreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // calls setState in the PAGE, not here
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? _green : Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
