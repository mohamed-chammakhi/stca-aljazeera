// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/pages/mes_echantillons/widgets/refus_badge.dart
// PURPOSE : secondary badge showing WHY the sample was refused
//           shown only when statut == StatutCollecteur.refus
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/echantillon_collecteur.dart';

class RefusBadge extends StatelessWidget {
  final TypeRefus typeRefus;
  const RefusBadge({super.key, required this.typeRefus});

  @override
  Widget build(BuildContext context) {
    final isCEO = typeRefus == TypeRefus.refusCEO;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isCEO ? const Color(0xFFFFEBEE) : const Color(0xFFFCE4EC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCEO ? const Color(0xFFEF9A9A) : const Color(0xFFF48FB1),
        ),
      ),
      child: Text(
        isCEO ? 'Refus panel' : 'Négociation échouée',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isCEO ? const Color(0xFFC62828) : const Color(0xFFAD1457),
        ),
      ),
    );
  }
}
