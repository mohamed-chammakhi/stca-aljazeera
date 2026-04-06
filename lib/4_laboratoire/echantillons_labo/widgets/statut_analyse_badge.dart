// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/statut_analyse_badge.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../analyse_labo.dart';

class StatutAnalyseBadge extends StatelessWidget {
  final StatutAnalyse statut;
  const StatutAnalyseBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final config = _badgeConfig(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // ← CRITICAL: don't expand
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: config.dot,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: config.text,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _badgeConfig(StatutAnalyse s) {
    switch (s) {
      case StatutAnalyse.enAttente:
        return _BadgeConfig(
          label: 'En attente',
          bg: const Color(0xFFFFF3E0),
          border: const Color(0xFFFFCC80),
          dot: Colors.orange,
          text: Colors.orange.shade800,
        );
      case StatutAnalyse.enCours:
        return _BadgeConfig(
          label: 'En cours',
          bg: const Color(0xFFE3F2FD),
          border: const Color(0xFF90CAF9),
          dot: Colors.blue,
          text: Colors.blue.shade800,
        );
      case StatutAnalyse.soumis:
        return _BadgeConfig(
          label: 'Analyse soumise',
          bg: const Color(0xFFE8F5E9),
          border: const Color(0xFFA5D6A7),
          dot: const Color(0xFF38835A),
          text: const Color(0xFF2E6B47),
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final Color bg, border, dot, text;
  const _BadgeConfig({
    required this.label,
    required this.bg,
    required this.border,
    required this.dot,
    required this.text,
  });
}
