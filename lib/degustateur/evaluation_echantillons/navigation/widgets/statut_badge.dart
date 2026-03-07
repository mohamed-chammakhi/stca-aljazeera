// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/widgets/statut_badge.dart
// PURPOSE : colored badge showing En attente / En cours / Soumis
// receives : statut enum value — displays matching color + icon + text
// reusable in any page that shows échantillon status
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../models/echantillon.dart';

class StatutBadge extends StatelessWidget {
  final StatutEchantillon statut;

  const StatutBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    // Declare variables — will be set inside switch
    Color    couleur;
    String   texte;
    IconData icone;

    // switch : checks statut against each case
    // unlike String comparison, enum switch is exhaustive —
    // the compiler warns if you forget a case
    switch (statut) {
      case StatutEchantillon.enAttente:
        couleur = Colors.orange;
        texte   = 'En attente';
        icone   = Icons.hourglass_empty_rounded;
        break;
      case StatutEchantillon.enCours:
        couleur = Colors.blue;
        texte   = 'En cours';
        icone   = Icons.edit_outlined;
        break;
      case StatutEchantillon.soumis:
        couleur = Colors.green;
        texte   = 'Soumis';
        icone   = Icons.check_circle_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        couleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: couleur.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // shrinks to fit content
        children: [
          Icon(icone, size: 12, color: couleur),
          const SizedBox(width: 4),
          Text(
            texte,
            style: TextStyle(
              fontSize:   11,
              color:      couleur,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
