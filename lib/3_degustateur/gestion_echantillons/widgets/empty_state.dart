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
          Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(
            'Aucun échantillon trouvé',
            style: TextStyle(
              color:    Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
