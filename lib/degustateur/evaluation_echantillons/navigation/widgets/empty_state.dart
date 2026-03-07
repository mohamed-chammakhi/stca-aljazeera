// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/widgets/empty_state.dart
// PURPOSE : shown when the filtered list has no results
// no state, no logic — purely display
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
          Icon(Icons.science_outlined, size: 70, color: Colors.grey.shade300),
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
            'Modifiez vos filtres ou votre recherche',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
