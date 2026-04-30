// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/mes_echantillons/widgets/card_widgets/card_info_widgets.dart
//
// Pure display widgets used inside EchantillonComCard body rows.
//
//   CardInfoItem      — icon + label + value (used in 2-column rows)
//   CardRefChip       — green/grey bordered ref badge
//   CardLivraisonBox  — delivery details row (green or grey)
//   CardLivraisonManquante — warning banner when delivery not planned
//   CardRemarquesBox  — notes display
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../models/echantillon_collecteur.dart';
import '../../../widgets/col_colors.dart';

// ── Info item ─────────────────────────────────────────────────────────────────
class CardInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool grey;

  const CardInfoItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.grey = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelCol = grey ? Colors.grey.shade400 : Colors.grey.shade500;
    final valueCol = grey ? Colors.grey.shade400 : (valueColor ?? colDark);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: labelCol),
        const SizedBox(width: 5),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, color: labelCol)),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueCol,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Ref chip ──────────────────────────────────────────────────────────────────
class CardRefChip extends StatelessWidget {
  final String label;
  final bool grey;

  const CardRefChip({super.key, required this.label, required this.grey});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: grey ? Colors.grey.shade100 : colGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: grey ? Colors.grey.shade300 : colGreen.withValues(alpha: 0.2),
      ),
    ),
    child: Text(
      '# ${label.isNotEmpty ? label : "—"}',
      style: TextStyle(
        fontSize: 12,
        color: grey ? Colors.grey.shade400 : colGreen,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ── Livraison box ─────────────────────────────────────────────────────────────
class CardLivraisonBox extends StatelessWidget {
  final PlanificationLivraison livraison; // ← était LivraisonInfo
  final bool grey;

  const CardLivraisonBox({
    super.key,
    required this.livraison,
    required this.grey,
  });

  @override
  Widget build(BuildContext context) {
    final color = grey ? Colors.grey.shade400 : colGreen;
    final bg = grey ? Colors.grey.shade100 : const Color(0xFFE8F5E9);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 14, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              livraison.libelle,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Livraison manquante warning ───────────────────────────────────────────────
class CardLivraisonManquante extends StatelessWidget {
  const CardLivraisonManquante({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Row(
      children: [
        Icon(Icons.warning_amber_outlined, size: 14, color: colOrange),
        SizedBox(width: 7),
        Text(
          'Livraison non planifiée',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colOrange,
          ),
        ),
      ],
    ),
  );
}

// ── Remarques box ─────────────────────────────────────────────────────────────
class CardRemarquesBox extends StatelessWidget {
  final String text;
  final bool grey;

  const CardRemarquesBox({super.key, required this.text, required this.grey});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: grey ? Colors.grey.shade100 : colGreen.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.notes_rounded,
          size: 13,
          color: grey ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: grey ? Colors.grey.shade400 : Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
