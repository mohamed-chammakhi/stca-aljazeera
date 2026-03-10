// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/pages/mes_echantillons/widgets/echantillon_collecteur_card.dart
// PURPOSE : card displaying one sample for the collector
//           — archived samples shown in greyscale with lock icon
//           — refused samples show refus badge
//           — confirmed samples show delivery planning button
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/echantillon_collecteur.dart';
import 'statut_collecteur_badge.dart';
import 'refus_badge.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

class EchantillonCollecteurCard extends StatelessWidget {
  final EchantillonCollecteur echantillon;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;
  final VoidCallback? onConfirmerAchat;
  final VoidCallback? onPlanifierLivraison;

  const EchantillonCollecteurCard({
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
    final isArchive = e.isArchive;
    final isRefus = e.isRefus;

    // archived cards are greyscale
    Widget card = Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isArchive ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isArchive ? Border.all(color: Colors.grey.shade300) : null,
        boxShadow: isArchive
            ? null
            : [
                BoxShadow(
                  color: _green.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── HEADER ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // row 1: reference + statut badge + lock if archived
                Row(
                  children: [
                    if (isArchive)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          Icons.lock_outline,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    const Icon(
                      Icons.science_outlined,
                      color: _oliveGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.reference,
                        style: GoogleFonts.domine(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isArchive ? Colors.grey.shade500 : _darkText,
                        ),
                      ),
                    ),
                    StatutCollecteurBadge(statut: e.statut),
                  ],
                ),

                const SizedBox(height: 6),

                // refus badge — only shown when refused
                if (isRefus && e.typeRefus != null) ...[
                  RefusBadge(typeRefus: e.typeRefus!),
                  const SizedBox(height: 6),
                ],

                // refus reason
                if (isRefus &&
                    e.raisonRefus != null &&
                    e.raisonRefus!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e.raisonRefus!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFC62828),
                      ),
                    ),
                  ),

                // meta row
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    _Meta(
                      icon: Icons.calendar_today_outlined,
                      label: e.dateAjout,
                      grey: isArchive,
                    ),
                    _Meta(
                      icon: Icons.store_outlined,
                      label: e.fournisseurNom,
                      grey: isArchive,
                    ),
                    _Meta(
                      icon: Icons.location_on_outlined,
                      label: e.region,
                      grey: isArchive,
                    ),
                    if (e.variete != null)
                      _Meta(
                        icon: Icons.eco_outlined,
                        label: e.variete!,
                        grey: isArchive,
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // bottle image if available
                if (e.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      e.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      color: isArchive ? Colors.grey : null,
                      colorBlendMode: isArchive ? BlendMode.saturation : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // delivery planning info
                if (e.canPlanifier || e.isArchive)
                  if (e.livraison != null && e.livraison!.isComplete)
                    _LivraisonInfo(livraison: e.livraison!, grey: isArchive)
                  else if (!isArchive)
                    _LivraisonManquante(),

                // notes
                if (e.notes != null && e.notes!.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: isArchive
                          ? Colors.grey.shade100
                          : _green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      e.notes!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isArchive
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ),

                const SizedBox(height: 6),
              ],
            ),
          ),

          // archived label band
          if (isArchive) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: const BoxDecoration(
                color: Color(0xFFEEEEEE),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(
                    'Dossier archivé — lecture seule',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ]
          // action buttons — only shown when NOT archived
          else ...[
            Divider(color: Colors.grey.shade100, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: _ActionButtons(
                echantillon: e,
                onModifier: onModifier,
                onSupprimer: onSupprimer,
                onConfirmerAchat: onConfirmerAchat,
                onPlanifierLivraison: onPlanifierLivraison,
              ),
            ),
          ],
        ],
      ),
    );

    return card;
  }
}

// ── Action buttons based on statut ────────────────────────────────────────────
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

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // modifier — only in enTraitement
        if (e.canModify && onModifier != null)
          _Btn(
            label: 'Modifier',
            icon: Icons.edit_outlined,
            color: _oliveGreen,
            onTap: onModifier!,
          ),

        // supprimer — only in enTraitement
        if (e.canDelete && onSupprimer != null)
          _Btn(
            label: 'Supprimer',
            icon: Icons.delete_outline,
            color: Colors.red.shade400,
            onTap: onSupprimer!,
          ),

        // confirmer achat — only in approuveEnNegociation
        if (e.canConfirm && onConfirmerAchat != null)
          _Btn(
            label: 'Confirmer l\'achat',
            icon: Icons.check_circle_outline,
            color: _green,
            onTap: onConfirmerAchat!,
            filled: true,
          ),

        // planifier livraison — only in achatConfirme
        if (e.canPlanifier && onPlanifierLivraison != null)
          _Btn(
            label: 'Planifier livraison',
            icon: Icons.local_shipping_outlined,
            color: _green,
            onTap: onPlanifierLivraison!,
            filled: true,
          ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool filled;

  const _Btn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );

    if (filled) {
      return ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          shape: shape,
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        shape: shape,
      ),
    );
  }
}

// ── Delivery info box ─────────────────────────────────────────────────────────
class _LivraisonInfo extends StatelessWidget {
  final LivraisonInfo livraison;
  final bool grey;
  const _LivraisonInfo({required this.livraison, required this.grey});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: grey ? Colors.grey.shade100 : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 14,
            color: grey ? Colors.grey : _green,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Livraison : ${livraison.date?.day}/${livraison.date?.month}/${livraison.date?.year}'
              '  ${livraison.heure}  —  ${livraison.lieu}',
              style: TextStyle(
                fontSize: 12,
                color: grey ? Colors.grey.shade500 : _green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LivraisonManquante extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_outlined,
            size: 14,
            color: Color(0xFFF57C00),
          ),
          const SizedBox(width: 6),
          Text(
            'Livraison non planifiée',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFF57C00),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Meta chip ────────────────────────────────────────────────────────────────
class _Meta extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool grey;
  const _Meta({required this.icon, required this.label, this.grey = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 12,
        color: grey ? Colors.grey.shade400 : Colors.grey.shade400,
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: grey ? Colors.grey.shade400 : Colors.grey.shade500,
        ),
      ),
    ],
  );
}
