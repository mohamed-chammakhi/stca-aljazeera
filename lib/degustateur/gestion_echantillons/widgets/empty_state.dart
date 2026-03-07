// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/empty_state.dart
// PURPOSE : shown when the filtered list has no results
// completely independent — no state, no logic, pure display
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun échantillon trouvé',
            style: GoogleFonts.domine(
              fontSize:   18,
              fontWeight: FontWeight.w700,
              color:      Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur "Ajouter" pour enregistrer un échantillon',
            style:     TextStyle(fontSize: 13, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
