// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/statut_badge.dart
// PURPOSE : colored badge showing the status of an échantillon
// REUSABLE : can be imported in evaluation page, gestion page, anywhere
// receives : statut (String) — displays the right color and icon
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

class StatutBadge extends StatelessWidget {
  final String statut;

  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    // Determine color and icon based on statut value
    Color couleur;
    IconData icone;

    switch (statut) {
      case 'Non évaluée':
        couleur = Colors.orange;
        icone = Icons.hourglass_empty_rounded;
        break;
      case 'Évaluation en cours':
        couleur = Colors.blue;
        icone = Icons.edit_outlined;
        break;
      case '	Évaluation soumise':
        couleur = Colors.green;
        icone = Icons.check_circle_outline;
        break;
      default:
        couleur = Colors.grey;
        icone = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: couleur.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 11, color: couleur),
          const SizedBox(width: 4),
          Text(
            statut,
            style: TextStyle(
              fontSize: 11,
              color: couleur,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
