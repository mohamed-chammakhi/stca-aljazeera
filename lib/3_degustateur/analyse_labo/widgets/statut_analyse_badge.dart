// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/widgets/statut_analyse_badge.dart
// PURPOSE : colored badge for analysis status
//           🟡 En attente / 🔵 Envoyée
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/analyse_labo.dart';

class StatutAnalyseBadge extends StatelessWidget {
  final StatutAnalyse statut;
  const StatutAnalyseBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final cfg = _cfg(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: cfg.bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(color: cfg.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(cfg.label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600, color: cfg.text)),
        ],
      ),
    );
  }
}

class _Cfg {
  final Color bg, dot, text;
  final String label;
  const _Cfg(this.bg, this.dot, this.text, this.label);
}

_Cfg _cfg(StatutAnalyse s) {
  switch (s) {
    case StatutAnalyse.enAttente:
      return const _Cfg(Color(0xFFFFF8E1), Color(0xFFF9A825),
          Color(0xFFF9A825), 'En attente');
    case StatutAnalyse.envoyee:
      return const _Cfg(Color(0xFFE3F2FD), Color(0xFF1E88E5),
          Color(0xFF1E88E5), 'Envoyée');
  }
}
