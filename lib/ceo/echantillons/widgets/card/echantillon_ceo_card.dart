// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/echantillons/widgets/card/echantillon_ceo_card.dart
// PURPOSE : Sample card for the CEO — shows all collector info + status actions
// DESIGN   : Mirrors EchantillonComCard from collecteur module
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_ceo.dart';
import '../../../widgets/statut_echantillon_badge.dart';

const Color _kGreen = Color(0xFF38835A);
const Color _kOliveGreen = Color(0xFF6B8143);
const Color _kDarkText = Color(0xFF1A2E1F);
const Color _kOrange = Color(0xFFF57C00);

class EchantillonCeoCard extends StatelessWidget {
  final EchantillonCeo echantillon;
  final VoidCallback? onApprouver;
  final VoidCallback? onRefuser;
  final VoidCallback? onVoirDetails;
  final VoidCallback? onExaminerSuppression; // deletion request review

  const EchantillonCeoCard({
    super.key,
    required this.echantillon,
    this.onApprouver,
    this.onRefuser,
    this.onVoirDetails,
    this.onExaminerSuppression,
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
            color: _kGreen.withOpacity(0.07),
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
            // ── ROW 1 : Image + ID + Badge ────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _kGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _kGreen.withOpacity(0.25)),
                  ),
                  child: e.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Image.network(e.imageUrl!, fit: BoxFit.cover),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 22,
                          color: _kGreen.withOpacity(0.5),
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
                          color: _kDarkText,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                StatutEchantillonCeoBadge(statut: e.statut),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            // ── Ref chip ──────────────────────────────────────────────────
            _RefChip(label: e.referenceBouteille),
            const SizedBox(height: 10),

            // ── Gouvernorat + Collecteur ──────────────────────────────────
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
                    icon: Icons.person_outline,
                    label: 'Collecteur',
                    value: e.collecteurNom,
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

            // ── Quantité + Scellage ───────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Quantité estimée',
                    value: e.quantiteEstimee ?? '—',
                    valueColor: _kOliveGreen,
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

            // ── Delivery info if available ────────────────────────────────
            if (e.hasLivraison) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 14,
                      color: _kGreen,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${e.livraisonDate} à ${e.livraisonHeure} — ${e.livraisonLieu}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Refusal reason ────────────────────────────────────────────
            if (e.statut == StatutEchantillonCeo.refuse &&
                e.refusCommentaire != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, size: 13, color: Colors.red.shade400),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.refusCommentaire!,
                        style: TextStyle(fontSize: 12, color: Colors.red.shade600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── Remarques ─────────────────────────────────────────────────
            if (e.remarques != null && e.remarques!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.remarques!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── Action Buttons ────────────────────────────────────────────
            if (e.statut == StatutEchantillonCeo.enCours)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onApprouver,
                      icon: const Icon(Icons.check, size: 15),
                      label: const Text(
                        'Approuver',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRefuser,
                      icon: Icon(Icons.close, size: 15, color: Colors.red.shade500),
                      label: Text(
                        'Refuser',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.red.shade500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onVoirDetails,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                        vertical: 9,
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onVoirDetails,
                    icon: const Icon(Icons.info_outline, size: 15),
                    label: const Text('Voir détails', style: TextStyle(fontSize: 12)),
                    style: TextButton.styleFrom(
                      foregroundColor: _kOliveGreen,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ── Private helpers matching collecteur card_info_widgets pattern ─────────────

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
  Widget build(BuildContext context) {
    return Row(
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
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? _kDarkText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RefChip extends StatelessWidget {
  final String label;
  const _RefChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _kGreen.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: _kGreen.withOpacity(0.2)),
    ),
    child: Text(
      '# ${label.isNotEmpty ? label : "—"}',
      style: const TextStyle(
        fontSize: 12,
        color: _kGreen,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );
}
