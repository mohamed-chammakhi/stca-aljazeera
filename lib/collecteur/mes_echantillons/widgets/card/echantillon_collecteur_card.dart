// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/widgets/card/echantillon_collecteur_card.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_collecteur.dart';
import '../statut_collecteur_badge.dart';
import '../dialogs/formulaire/planification_livraison.dart'; // ← ajouté

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

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
            color: _green.withValues(alpha: 0.07),
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
                    color: _green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withValues(alpha: 0.25)),
                  ),
                  child: e.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(e.imageUrl!, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: _green.withValues(alpha: 0.5),
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
                          color: _darkText,
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
                              fontSize: 11,
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
            _RefChip(label: e.referenceBouteille),

            const SizedBox(height: 10),

            // ── Gouvernorat + Délégation ───────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.location_on_outlined,
                    label: 'Gouvernorat',
                    value: e.gouvernorat,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
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
                  child: _InfoItem(
                    icon: Icons.storefront_outlined,
                    label: 'Fournisseur',
                    value: e.codeFournisseur,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
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
                  child: _InfoItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Quantité estimée',
                    value: e.quantiteEstimee ?? '—',
                    valueColor: _oliveGreen,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.verified_outlined,
                    label: 'Scellage',
                    value: e.scellage ?? '—',
                  ),
                ),
              ],
            ),

            // ── Livraison block — only visible when purchase is confirmed ──
            if (e.canPlanifier) ...[
              const SizedBox(height: 10),
              if (e.livraison != null && e.livraison!.isComplete)
                _LivraisonBox(livraison: e.livraison!)
              else
                const _LivraisonManquante(),
            ],

            // ── Remarques ──────────────────────────────────────────────────
            if (e.remarques != null && e.remarques!.isNotEmpty) ...[
              const SizedBox(height: 10),
              _RemarquesBox(text: e.remarques!),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── Footer : action buttons ────────────────────────────────────
            _ActionButtons(
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTION BUTTONS
// ─────────────────────────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;

  const _ActionButtons({
    required this.echantillon,
    this.onModifier,
    this.onSupprimer,
    this.onConfirmerAchat,
    this.onPlanifierLivraison,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;

    if (e.canModify) {
      return Row(
        children: [
          Expanded(
            child: _OutlineBtn(
              label: 'Modifier',
              icon: Icons.edit_outlined,
              color: _oliveGreen,
              onTap: onModifier ?? () {},
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _OutlineBtn(
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

    if (e.canConfirm && onConfirmerAchat != null) {
      return _FilledBtn(
        label: "Confirmer l'achat",
        icon: Icons.check_circle_outline,
        onTap: onConfirmerAchat!,
      );
    }

    if (e.canPlanifier && onPlanifierLivraison != null) {
      return _FilledBtn(
        label: 'Planifier la livraison',
        icon: Icons.local_shipping_outlined,
        onTap: onPlanifierLivraison!,
      );
    }

    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BUTTON HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _OutlineBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _OutlineBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        color: bgColor ?? color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: borderColor ?? color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _FilledBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _FilledBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 13, color: Colors.grey.shade500),
      const SizedBox(width: 5),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor ?? _darkText,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REF CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _RefChip extends StatelessWidget {
  final String label;
  const _RefChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _green.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _green.withValues(alpha: 0.2)),
    ),
    child: Text(
      '# ${label.isNotEmpty ? label : "—"}',
      style: const TextStyle(
        fontSize: 12,
        color: _green,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVRAISON BOX
// ─────────────────────────────────────────────────────────────────────────────
class _LivraisonBox extends StatelessWidget {
  final PlanificationLivraison livraison;
  const _LivraisonBox({required this.livraison});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFE8F5E9),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_shipping_outlined, size: 14, color: _green),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            livraison.libelle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _green,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVRAISON MANQUANTE
// ─────────────────────────────────────────────────────────────────────────────
class _LivraisonManquante extends StatelessWidget {
  const _LivraisonManquante();

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
        Icon(Icons.warning_amber_outlined, size: 14, color: Color(0xFFF57C00)),
        SizedBox(width: 7),
        Text(
          'Livraison non planifiée',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF57C00),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REMARQUES BOX
// ─────────────────────────────────────────────────────────────────────────────
class _RemarquesBox extends StatelessWidget {
  final String text;
  const _RemarquesBox({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _green.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.notes_rounded, size: 13, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
