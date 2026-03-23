// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/mes_echantillons/widgets/card_widgets/card_action_buttons.dart
//
// Renders the correct set of action buttons for a given sample status.
//
// Status → buttons:
//   receptionne    → Modifier + Supprimer
//   enNegociation  → Confirmer l'achat only
//                    (if negotiation fails, card stays frozen — no button)
//   achatConfirme  → Planifier la livraison
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../models/echantillon_collecteur.dart';
import 'card_theme.dart';
import 'card_buttons.dart';

class CardActionButtons extends StatelessWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;

  const CardActionButtons({
    super.key,
    required this.echantillon,
    this.onModifier,
    this.onSupprimer,
    this.onConfirmerAchat,
    this.onPlanifierLivraison,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    // ── receptionne: Modifier + Supprimer ────────────────────────────────────
    if (e.canModify) {
      return Row(
        children: [
          Expanded(
            child: CardOutlineBtn(
              label: 'Modifier',
              icon: Icons.edit_outlined,
              color: kOliveGreen,
              onTap: onModifier ?? () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CardOutlineBtn(
              label: 'Supprimer',
              icon: Icons.delete_outline,
              color: Colors.red.shade400,
              bgColor: Colors.red.shade50,
              borderColor: Colors.red.shade200,
              onTap: onSupprimer ?? () {},
            ),
          ),
        ],
      );
    }

    // ── enNegociation: Confirmer l'achat only ────────────────────────────────
    // No "négociation non aboutie" button — a failed negotiation simply
    // leaves the card frozen at this status with no available action.
    if (e.canConfirm && onConfirmerAchat != null) {
      return CardFilledBtn(
        label: "Confirmer l'achat",
        icon: Icons.check_circle_outline,
        onTap: onConfirmerAchat!,
      );
    }

    // ── achatConfirme: Planifier la livraison ─────────────────────────────────
    if (e.canPlanifier && onPlanifierLivraison != null) {
      return CardFilledBtn(
        label: 'Planifier la livraison',
        icon: Icons.local_shipping_outlined,
        onTap: onPlanifierLivraison!,
      );
    }

    // ── enNegociation with no confirm callback, or any other frozen state ─────
    return const SizedBox.shrink();
  }
}
