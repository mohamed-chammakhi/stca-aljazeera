// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/mes_echantillons/widgets/card_widgets/card_action_buttons.dart
//
// Renders the correct set of action buttons for a given sample status.
// Also contains CardArchiveFooter for archived samples.
//
// Status → buttons:
//   enTraitement          → Modifier + Supprimer
//   approuveEnNegociation → Confirmer l'achat + Négociation non aboutie
//   achatConfirme         → Planifier la livraison
//   refus / archive       → nothing (or archive footer)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../models/echantillon_collecteur.dart';
import 'card_theme.dart';
import 'card_buttons.dart';

// ── Main action buttons dispatcher ───────────────────────────────────────────
class CardActionButtons extends StatelessWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;
  final VoidCallback? onEchecNegociation;

  const CardActionButtons({
    super.key,
    required this.echantillon,
    this.onModifier,
    this.onSupprimer,
    this.onConfirmerAchat,
    this.onPlanifierLivraison,
    this.onEchecNegociation,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    // ── enTraitement: Modifier + Supprimer ───────────────────────────────────
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

    // ── approuveEnNegociation: Confirm + Signal failure ──────────────────────
    if (e.cansignalerEchecNegociation) {
      return Column(
        children: [
          if (onConfirmerAchat != null)
            CardFilledBtn(
              label: "Confirmer l'achat",
              icon: Icons.check_circle_outline,
              onTap: onConfirmerAchat!,
            ),
          if (onConfirmerAchat != null && onEchecNegociation != null)
            const SizedBox(height: 8),
          if (onEchecNegociation != null)
            CardOutlineBtn(
              label: 'Négociation non aboutie',
              icon: Icons.handshake_outlined,
              color: kOrange,
              bgColor: kOrange.withValues(alpha: 0.07),
              borderColor: kOrange.withValues(alpha: 0.35),
              onTap: onEchecNegociation!,
            ),
        ],
      );
    }

    // ── achatConfirme: Planifier livraison ───────────────────────────────────
    if (e.canPlanifier && onPlanifierLivraison != null) {
      return CardFilledBtn(
        label: 'Planifier la livraison',
        icon: Icons.local_shipping_outlined,
        onTap: onPlanifierLivraison!,
      );
    }

    return const SizedBox.shrink();
  }
}

// ── Archive footer ────────────────────────────────────────────────────────────
class CardArchiveFooter extends StatelessWidget {
  const CardArchiveFooter({super.key});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(Icons.lock_outline,
              size: 13, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            'Dossier archivé — lecture seule',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      );
}
