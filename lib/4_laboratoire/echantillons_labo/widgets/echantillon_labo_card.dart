// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/echantillon_labo_card.dart
// PURPOSE : Expandable card for a lab sample — accent bar for analysis status,
//           inline icon actions, expandable detail panel with all attributes.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/echantillon_labo.dart';
import '../../analyse_labo.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);

Color _accentColor(StatutAnalyse s) {
  switch (s) {
    case StatutAnalyse.enAttente:
      return const Color(0xFF3A6EA5);
    case StatutAnalyse.enCours:
      return const Color(0xFFD07B2F);
    case StatutAnalyse.soumis:
      return const Color(0xFF38835A);
  }
}

class EchantillonLaboCard extends StatefulWidget {
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
  State<EchantillonLaboCard> createState() => _EchantillonLaboCardState();
}

class _EchantillonLaboCardState extends State<EchantillonLaboCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final e = widget.echantillon;
    final hasAnalyse = e.analyse != null;
    final accent = _accentColor(e.statutAnalyse);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header (always visible) ──────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Thick left accent bar
                  Container(width: 4, color: accent),

                  // Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Row 1: bottle ref + qty pill + chevron ──────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  e.referenceBouteille.isNotEmpty
                                      ? e.referenceBouteille
                                      : '—',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (e.quantiteEstimee != null &&
                                  e.quantiteEstimee!.isNotEmpty) ...[
                                _QuantityPill(quantite: e.quantiteEstimee!),
                                const SizedBox(width: 8),
                              ],
                              AnimatedRotation(
                                turns: _expanded ? 0.5 : 0.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 2),

                          // ── Row 2: ref + action icons (only when expanded)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                e.ref,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const Spacer(),
                              if (_expanded) ...[
                                if (!hasAnalyse)
                                  Tooltip(
                                    message: 'Ajouter une analyse',
                                    child: _SmallIconBtn(
                                      icon: Icons.add_circle_outline,
                                      color: _green,
                                      onTap: widget.onAjouterAnalyse ?? () {},
                                    ),
                                  ),
                                if (hasAnalyse) ...[
                                  Tooltip(
                                    message: 'Voir rapport',
                                    child: _SmallIconBtn(
                                      icon: Icons.visibility_outlined,
                                      color: _green,
                                      onTap: widget.onVoirAnalyse ?? () {},
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Tooltip(
                                    message: 'Modifier',
                                    child: _SmallIconBtn(
                                      icon: Icons.edit_outlined,
                                      color: Colors.orange.shade700,
                                      onTap: widget.onModifierAnalyse ?? () {},
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable detail panel ──────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(e: e, accentColor: accent),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL ICON BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _SmallIconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: Padding(
      padding: const EdgeInsets.all(5),
      child: Icon(icon, size: 18, color: color),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// QUANTITY PILL
// ─────────────────────────────────────────────────────────────────────────────
class _QuantityPill extends StatelessWidget {
  final String quantite;
  const _QuantityPill({required this.quantite});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _olive.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(7),
      border: Border.all(color: _olive.withValues(alpha: 0.22)),
    ),
    child: Text(
      'Qté : $quantite T',
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _olive,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL PANEL — expandable with all lab attributes + analysis summary
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final EchantillonLabo e;
  final Color accentColor;

  const _DetailPanel({required this.e, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade100, height: 1),
        Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 90,
                runSpacing: 10,
                children: [
                  _DetailItem('N° échantillon', e.ref),
                  _DetailItem('Réf. bouteille', e.referenceBouteille),
                  _DetailItem('Gouvernorat', e.gouvernorat),
                  _DetailItem('Fournisseur', e.codeFournisseur),
                  _DetailItem('Collecteur', e.collecteurNom),
                  _DetailItem('Date arrivée', e.dateArrivee),
                  if (e.variete != null && e.variete!.isNotEmpty)
                    _DetailItem('Variété', e.variete!),
                  if (e.numeroLot != null)
                    _DetailItem('N° lot', e.numeroLot!),
                  if (e.origineCampagne != null)
                    _DetailItem('Campagne', e.origineCampagne!),
                  _DetailItem(
                    'Priorité',
                    e.priorite == PrioriteLabo.urgente ? 'Urgente' : 'Normale',
                  ),
                ],
              ),

              // ── Analysis summary (if submitted) ────────────────────────
              if (e.analyse != null) ...[
                const SizedBox(height: 12),
                _AnalyseSummaryStrip(analyse: e.analyse!),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DETAIL ITEM
// ─────────────────────────────────────────────────────────────────────────────
class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem(this.label, this.value);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFFAAAAAA),
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: _dark,
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ANALYSIS SUMMARY STRIP
// ─────────────────────────────────────────────────────────────────────────────
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
        color: classifColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: classifColor.withValues(alpha: 0.15)),
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
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: color,
      ),
    ),
  );
}
