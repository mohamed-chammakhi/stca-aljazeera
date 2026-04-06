// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/widgets/filtre_chip.dart
// PURPOSE : one filter button (Tous / En attente / En cours / Soumis)
// receives : label, isSelected, onTap FROM the page
// does NOT call setState — the page handles state via onTap callback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _green = Color(0xFF38835A);

class FiltreChip extends StatelessWidget {
  final String     label;
  final bool       isSelected;
  final VoidCallback onTap; // VoidCallback = function that takes nothing, returns nothing

  const FiltreChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // setState is called in the PAGE, not here
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          // white if selected, semi-transparent if not
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color:      isSelected ? _green : Colors.white,
            fontSize:   12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
