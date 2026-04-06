// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/widgets/card/echantillon_collecteur_card.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_collecteur.dart';
import '../statut_collecteur_badge.dart';
import '../dialogs/formulaire/planification_livraison.dart';
import 'card_theme.dart';
import 'card_info_widgets.dart';
import 'card_action_buttons.dart';

class EchantillonComCard extends StatelessWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;

  const EchantillonComCard({
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

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kGreen.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ROW 1 : Photo + ID + Statut badge ──────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kGreen.withValues(alpha: 0.25)),
                  ),
                  child: e.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(e.imageUrl!, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: kGreen.withValues(alpha: 0.5),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.ref,
                        style: GoogleFonts.domine(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 11,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ajouté le ${e.dateAjout}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatutCollecteurBadge(statut: e.statut),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // ── Ref bouteille chip ─────────────────────────────────────────
            CardRefChip(label: e.referenceBouteille, grey: false),

            const SizedBox(height: 10),

            // ── Gouvernorat + Délégation ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Gouvernorat',
                    value: e.gouvernorat,
                  ),
                ),
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Délégation',
                    value: e.delegation ?? '—',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Fournisseur + Variété ──────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.storefront_outlined,
                    label: 'Fournisseur',
                    value: e.codeFournisseur,
                  ),
                ),
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.eco_outlined,
                    label: 'Variété',
                    value: e.variete ?? '—',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ── Quantité + Scellage ────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Quantité estimée',
                    value: e.quantiteEstimee ?? '—',
                    valueColor: kOliveGreen,
                  ),
                ),
                Expanded(
                  child: CardInfoItem(
                    icon: Icons.verified_outlined,
                    label: 'Scellage',
                    value: e.scellage ?? '—',
                  ),
                ),
              ],
            ),

            // ── Livraison block ────────────────────────────────────────────
            if (e.canPlanifier) ...[
              const SizedBox(height: 10),
              if (e.livraison != null && e.livraison!.isComplete)
                CardLivraisonBox(livraison: e.livraison!, grey: false)
              else
                const CardLivraisonManquante(),
            ],

            // ── Remarques ──────────────────────────────────────────────────
            if (e.remarques != null && e.remarques!.isNotEmpty) ...[
              const SizedBox(height: 10),
              CardRemarquesBox(text: e.remarques!, grey: false),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── Footer : action buttons ────────────────────────────────────
            CardActionButtons(
              echantillon: e,
              onModifier: onModifier,
              onSupprimer: onSupprimer,
              onConfirmerAchat: onConfirmerAchat,
              onPlanifierLivraison: onPlanifierLivraison,
            ),
          ],
        ),
      ),
    );
  }
}
