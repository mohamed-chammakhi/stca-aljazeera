// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/widgets/statut_echantillon_badge.dart
// PURPOSE : Colored badge for sample status visible to the CEO
// STATUSES : En cours (blue) | A négocier (orange) | Achat confirmé (green) | Refusé (red)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

enum StatutEchantillonCeo {
  enCours,
  aNegocier,
  achatConfirme,
  refuse,
}

class StatutEchantillonCeoBadge extends StatelessWidget {
  final StatutEchantillonCeo statut;

  const StatutEchantillonCeoBadge({super.key, required this.statut});

  @override
  Widget build(BuildContext context) {
    final config = _config(statut);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: config.color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 11, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.label,
            style: TextStyle(
              fontSize: 11,
              color: config.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusConfig _config(StatutEchantillonCeo s) {
    switch (s) {
      case StatutEchantillonCeo.enCours:
        return _StatusConfig(
          label: 'En cours',
          color: Colors.blue.shade600,
          icon: Icons.hourglass_empty_rounded,
        );
      case StatutEchantillonCeo.aNegocier:
        return _StatusConfig(
          label: 'À négocier',
          color: Colors.orange.shade700,
          icon: Icons.handshake_outlined,
        );
      case StatutEchantillonCeo.achatConfirme:
        return _StatusConfig(
          label: 'Achat confirmé',
          color: const Color(0xFF38835A),
          icon: Icons.check_circle_outline,
        );
      case StatutEchantillonCeo.refuse:
        return _StatusConfig(
          label: 'Refusé',
          color: Colors.red.shade600,
          icon: Icons.cancel_outlined,
        );
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusConfig({
    required this.label,
    required this.color,
    required this.icon,
  });
}
