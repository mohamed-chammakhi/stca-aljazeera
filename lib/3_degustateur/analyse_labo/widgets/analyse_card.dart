// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/widgets/analyse_card.dart
// PURPOSE : Expandable card for one lab analysis — accent bar, header,
//           collapsible criteria table, edit action.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/analyse_labo.dart';

const Color _dark = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);
const Color _green = Color(0xFF38835A);
const Color _redVal = Color(0xFFC62828);
const Color _redBg = Color(0xFFFFEBEE);

Color _accentColor(StatutAnalyse s) {
  switch (s) {
    case StatutAnalyse.enAttente:
      return const Color(0xFFD07B2F);
    case StatutAnalyse.envoyee:
      return const Color(0xFF3A6EA5);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;
  final VoidCallback? onModifier;
  final VoidCallback? onSupprimer;

  const AnalyseCard({
    super.key,
    required this.analyse,
    this.onModifier,
    this.onSupprimer,
  });

  @override
  State<AnalyseCard> createState() => _AnalyseCardState();
}

class _AnalyseCardState extends State<AnalyseCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.analyse;
    final accent = _accentColor(a.statut);

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
          // ── Header (always visible) ─────────────────────────────────────
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left accent bar (status color)
                  Container(width: 4, color: accent),

                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(13, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Row 1: name + statut pill + chevron
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  a.echantillonNom,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _dark,
                                    letterSpacing: -0.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
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

                          const SizedBox(height: 4),

                          // Row 2: meta info + action icons (expanded)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.tag,
                                size: 11,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                a.id,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 10),

                              const Spacer(),
                              if (_expanded &&
                                  (widget.onModifier != null ||
                                      widget.onSupprimer != null)) ...[
                                if (widget.onModifier != null)
                                  Tooltip(
                                    message: 'Modifier',
                                    child: _SmallIconBtn(
                                      icon: Icons.edit_outlined,
                                      color: _olive,
                                      onTap: widget.onModifier!,
                                    ),
                                  ),
                                if (widget.onModifier != null)
                                  const SizedBox(width: 2),
                                if (widget.onSupprimer != null)
                                  Tooltip(
                                    message: 'Supprimer',
                                    child: _SmallIconBtn(
                                      icon: Icons.delete_outline,
                                      color: Colors.red.shade300,
                                      onTap: widget.onSupprimer!,
                                    ),
                                  ),
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

          // ── Expandable detail panel ─────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _DetailPanel(a: a, accent: accent),
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
// DETAIL PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final AnalyseLabo a;
  final Color accent;
  const _DetailPanel({required this.a, required this.accent});

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
              // Technicien row
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Technicien : ',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    a.technicienNom,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _dark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Criteria table
              _CriteresTable(criteres: a.criteres),

              // Notes (optional)
              if (a.notes != null && a.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notes_outlined,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          a.notes!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CRITERIA TABLE
// ─────────────────────────────────────────────────────────────────────────────
class _CriteresTable extends StatelessWidget {
  final List<CritereAnalyse> criteres;
  const _CriteresTable({required this.criteres});

  String _seuilLabel(CritereAnalyse c) {
    if (c.seuilMin == null && c.seuilMax == null) return '—';
    if (c.seuilMin != null && c.seuilMax != null) {
      return '${c.seuilMin}–${c.seuilMax} ${c.unite}'.trim();
    }
    if (c.seuilMax != null) return '≤ ${c.seuilMax} ${c.unite}'.trim();
    return '≥ ${c.seuilMin} ${c.unite}'.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header row
        _TableRow(
          critere: 'Critère',
          valeur: 'Valeur',
          seuil: 'Norme',
          conforme: null,
          isHeader: true,
        ),
        ...criteres.map(
          (c) => _TableRow(
            critere: c.label,
            valeur: '${c.valeur} ${c.unite}'.trim(),
            seuil: _seuilLabel(c),
            conforme: c.conforme,
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final String critere;
  final String valeur;
  final String seuil;
  final bool? conforme;
  final bool isHeader;

  const _TableRow({
    required this.critere,
    required this.valeur,
    required this.seuil,
    required this.conforme,
    this.isHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isHeader
        ? const Color(0xFFF1F8F4)
        : conforme == false
        ? _redBg
        : Colors.white;

    final indicatorColor = isHeader || conforme == null
        ? Colors.transparent
        : conforme!
        ? _green
        : _redVal;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left micro-bar (conformité indicator)
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            // Critère label
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: Text(
                  critere,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                    color: isHeader ? _olive : _dark,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            // Valeur
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: Text(
                  valeur,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHeader
                        ? _olive
                        : conforme == false
                        ? _redVal
                        : _green,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            // Norme
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
                child: Text(
                  seuil,
                  style: TextStyle(
                    fontSize: 11,
                    color: isHeader ? _olive : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            // Conformité icon
            if (!isHeader && conforme != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  conforme! ? Icons.check_circle : Icons.cancel,
                  color: conforme! ? _green : _redVal,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
