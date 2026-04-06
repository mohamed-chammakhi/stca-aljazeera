// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/echantillon_labo_card.dart
// PURPOSE : Card widget for a single lab sample — shows key info,
//           analysis summary, and action buttons.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/echantillon_labo.dart';
import 'statut_analyse_badge.dart';
import '../../analyse_labo.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

class EchantillonLaboCard extends StatelessWidget {
  final EchantillonLabo echantillon;
  final VoidCallback? onAjouterAnalyse;
  final VoidCallback? onVoirAnalyse;
  final VoidCallback? onModifierAnalyse;

  const EchantillonLaboCard({
    super.key,
    required this.echantillon,
    this.onAjouterAnalyse,
    this.onVoirAnalyse,
    this.onModifierAnalyse,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    final hasAnalyse = e.analyse != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.07),
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
            // ── ROW 1 : Icon + Ref + Statut badge ─────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flask icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _green.withOpacity(0.25)),
                  ),
                  child: Icon(
                    Icons.science_outlined,
                    size: 22,
                    color: _green.withOpacity(0.7),
                  ),
                ),
                const SizedBox(width: 12),
                // Ref bottle name + ref number — FLEXIBLE, won't overflow
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.referenceBouteille,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _darkText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      // Ref chip — constrained to not overflow
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '# ${e.ref}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge — fixed, never pushed off
                StatutAnalyseBadge(statut: e.statutAnalyse),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── ROW 2 : Gouvernorat + Fournisseur ─────────────────────────
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
                    icon: Icons.storefront_outlined,
                    label: 'Fournisseur',
                    value: e.codeFournisseur,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── ROW 3 : Arrivée + Variété + Quantité ──────────────────────
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Arrivée',
                    value: e.dateArrivee,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.eco_outlined,
                    label: 'Variété',
                    value: e.variete ?? '—',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.water_drop_outlined,
                    label: 'Quantité',
                    value: e.quantiteEstimee ?? '—',
                    valueColor: _green,
                  ),
                ),
              ],
            ),

            // ── Collecteur row ─────────────────────────────────────────────
            if (e.collecteurNom != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Collecteur : ${e.collecteurNom}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],

            // ── Analysis summary strip (if analyse exists) ─────────────────
            if (hasAnalyse) ...[
              const SizedBox(height: 10),
              _AnalyseSummaryStrip(analyse: e.analyse!),
            ],

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 10),

            // ── Action buttons ─────────────────────────────────────────────
            if (!hasAnalyse)
              _AddAnalyseButton(onTap: onAjouterAnalyse)
            else
              Row(
                children: [
                  Expanded(
                    child: _OutlineActionButton(
                      icon: Icons.visibility_outlined,
                      label: 'Voir rapport',
                      color: _green,
                      onTap: onVoirAnalyse,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _OutlineActionButton(
                      icon: Icons.edit_outlined,
                      label: 'Modifier',
                      color: Colors.orange.shade700,
                      onTap: onModifierAnalyse,
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

// ── Analysis summary strip ─────────────────────────────────────────────────
class _AnalyseSummaryStrip extends StatelessWidget {
  final AnalyseLabo analyse;
  const _AnalyseSummaryStrip({required this.analyse});

  @override
  Widget build(BuildContext context) {
    final classif = analyse.classificationAuto;
    final classifColor = classif == 'Extra Vierge'
        ? _green
        : classif == 'Vierge'
        ? Colors.orange.shade700
        : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: classifColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: classifColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_outlined, size: 15, color: classifColor),
          const SizedBox(width: 6),
          Text(
            classif,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: classifColor,
            ),
          ),
          const Spacer(),
          if (analyse.aciditeLibre != null)
            _MiniChip(
              'Acidité: ${analyse.aciditeLibre!.toStringAsFixed(2)}%',
              classifColor,
            ),
          if (analyse.indicePeroxyde != null) ...[
            const SizedBox(width: 6),
            _MiniChip(
              'Peroxyde: ${analyse.indicePeroxyde!.toStringAsFixed(1)}',
              classifColor,
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniChip(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

// ── Info item (icon + label + value) ─────────────────────────────────────────
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, size: 11, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
          ),
        ],
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: valueColor ?? const Color(0xFF1A2E1F),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

// ── Add analyse button (full-width green) ────────────────────────────────────
class _AddAnalyseButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _AddAnalyseButton({this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text(
            'Ajouter une analyse',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Outlined action button ────────────────────────────────────────────────────
class _OutlineActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _OutlineActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
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
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
