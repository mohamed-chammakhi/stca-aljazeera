// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/widgets/statut_badge.dart
// PURPOSE : colored badge showing session statut
//           🟡 Planifiée / 🔵 En cours / 🟢 Terminée
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/session_degustation.dart';

class StatutSessionBadge extends StatelessWidget {
  final StatutSession statut;

  const StatutSessionBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final config = _config(statut);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        config.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              color: config.dot, shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: TextStyle(
              fontSize:   11,
              fontWeight: FontWeight.w600,
              color:      config.text,
            ),
          ),
        ],
      ),
    );
  }
}

// ── config helper ─────────────────────────────────────────────────────────────
class _BadgeConfig {
  final Color  bg;
  final Color  dot;
  final Color  text;
  final String label;
  const _BadgeConfig(this.bg, this.dot, this.text, this.label);
}

_BadgeConfig _config(StatutSession s) {
  switch (s) {
    case StatutSession.enAttenteValidation:
      return _BadgeConfig(
        const Color(0xFFF5F5F5),
        const Color(0xFF9E9E9E),
        const Color(0xFF9E9E9E),
        'En attente',
      );
    case StatutSession.planifiee:
      return _BadgeConfig(
        const Color(0xFFFFF8E1),
        const Color(0xFFF9A825),
        const Color(0xFFF9A825),
        'Planifiée',
      );
    case StatutSession.enCours:
      return _BadgeConfig(
        const Color(0xFFE3F2FD),
        const Color(0xFF1E88E5),
        const Color(0xFF1E88E5),
        'En cours',
      );
    case StatutSession.terminee:
      return _BadgeConfig(
        const Color(0xFFE8F5E9),
        const Color(0xFF38835A),
        const Color(0xFF38835A),
        'Terminée',
      );
  }
}
