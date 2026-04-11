// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/homepage/widgets/action_card_ceo.dart
// PURPOSE : Card for urgent actions requiring CEO attention
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/action_item_ceo.dart';

class ActionCardCeo extends StatelessWidget {
  final ActionItemCeo item;
  final VoidCallback? onPrimaryAction;
  final String primaryLabel;
  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;

  const ActionCardCeo({
    super.key,
    required this.item,
    this.onPrimaryAction,
    required this.primaryLabel,
    this.onSecondaryAction,
    this.secondaryLabel,
  });

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  Color get _accentColor {
    if (item.urgent) return Colors.red.shade600;
    switch (item.type) {
      case ActionTypeCeo.approbationEchantillon:
        return Colors.orange.shade700;
      case ActionTypeCeo.demandeSuppressionCollecteur:
        return Colors.red.shade500;
      case ActionTypeCeo.sessionEnCours:
        return Colors.blue.shade600;
      case ActionTypeCeo.livraisonNonPlanifiee:
        return Colors.orange.shade600;
    }
  }

  IconData get _accentIcon {
    switch (item.type) {
      case ActionTypeCeo.approbationEchantillon:
        return Icons.science_outlined;
      case ActionTypeCeo.demandeSuppressionCollecteur:
        return Icons.delete_outline;
      case ActionTypeCeo.sessionEnCours:
        return Icons.wine_bar_outlined;
      case ActionTypeCeo.livraisonNonPlanifiee:
        return Icons.local_shipping_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentColor.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_accentIcon, color: _accentColor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.titre,
                  style: GoogleFonts.domine(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ),
              if (item.urgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'URGENT',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Description ─────────────────────────────────────────────────
          Text(
            item.description,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),

          if (item.acteur != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline, size: 12, color: Colors.grey.shade400),
                const SizedBox(width: 4),
                Text(
                  item.acteur!,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // ── Action buttons ───────────────────────────────────────────────
          Row(
            children: [
              if (onPrimaryAction != null)
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPrimaryAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      primaryLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              if (onSecondaryAction != null && secondaryLabel != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondaryAction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      secondaryLabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
