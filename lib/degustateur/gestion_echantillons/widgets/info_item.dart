// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/info_item.dart
// PURPOSE : one reusable info block — icon + label above + value below
// REUSABLE : used 4 times inside echantillon_card (fournisseur, variete,
//            origine, quantite) — define once, reuse everywhere
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class InfoItem extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;
  final Color valueColor;

  const InfoItem({
    super.key,
    this.icon,
    required this.label,
    required this.value,
    this.valueColor = _darkText, // default color if not provided
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: _oliveGreen),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small grey label above (ex: "Fournisseur")
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
              ),
              // Actual value below (ex: "Domaine Bel-Air")
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // "..." if too long
              ),
            ],
          ),
        ),
      ],
    );
  }
}
