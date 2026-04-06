// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/widgets/analyse_card.dart
// PURPOSE : card displaying one analysis with left accent bar, gradient header,
//           criteria table and actions
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/analyse_labo.dart';
import 'statut_analyse_badge.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);
const Color _cream      = Color(0xFFF9F6EF);
const Color _red        = Color(0xFFC62828);
const Color _redBg      = Color(0xFFFFEBEE);
const Color _greenBg    = Color(0xFFE8F5E9);

class AnalyseCard extends StatefulWidget {
  final AnalyseLabo  analyse;
  final VoidCallback onModifier;
  final VoidCallback onSupprimer;

  const AnalyseCard({
    super.key,
    required this.analyse,
    required this.onModifier,
    required this.onSupprimer,
  });

  @override
  State<AnalyseCard> createState() => _AnalyseCardState();
}

class _AnalyseCardState extends State<AnalyseCard> {
  bool _expanded = false;

  Color _statutColor(StatutAnalyse s) {
    switch (s) {
      case StatutAnalyse.validee:   return _green;
      case StatutAnalyse.envoyee:   return Colors.blue.shade500;
      case StatutAnalyse.enAttente: return Colors.orange.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a           = widget.analyse;
    final accentColor = _statutColor(a.statut);
    // left bar uses conformité for maximum meaning
    final barColor    = a.toutConforme ? accentColor : _red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:      barColor.withValues(alpha: 0.13),
            blurRadius: 12,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── HEADER: left bar + gradient + name + statut badge ────────────
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Left accent bar (conformité color)
                Container(width: 4, color: barColor),

                // Header content
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          barColor.withValues(alpha: 0.07),
                          Colors.white,
                        ],
                        begin: Alignment.centerLeft,
                        end:   Alignment.centerRight,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(12, 14, 14, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // row 1: échantillon name + statut badge
                        Row(children: [
                          const Icon(Icons.science_outlined,
                              color: _oliveGreen, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(a.echantillonNom,
                                style: GoogleFonts.domine(
                                    fontSize:   15,
                                    fontWeight: FontWeight.w700,
                                    color:      _darkText)),
                          ),
                          StatutAnalyseBadge(statut: a.statut),
                        ]),

                        const SizedBox(height: 8),

                        // row 2: id + date + technicien
                        Wrap(
                          spacing:    16,
                          runSpacing: 4,
                          children: [
                            _Meta(icon: Icons.tag,
                                label: a.id),
                            _Meta(icon: Icons.calendar_today_outlined,
                                label: a.dateAnalyse),
                            _Meta(icon: Icons.person_outline,
                                label: a.technicienNom),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // row 3: conformité summary banner
                        _ConformiteBanner(analyse: a),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── DIVIDER ──────────────────────────────────────────────────────
          Divider(color: Colors.grey.shade100, height: 1),

          // ── EXPAND BUTTON ─────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.only(
                bottomLeft:  Radius.circular(14),
                bottomRight: Radius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: _oliveGreen, size: 18),
                const SizedBox(width: 6),
                Text(
                  _expanded
                      ? 'Masquer les critères'
                      : 'Voir les ${a.criteres.length} critères d\'analyse',
                  style: const TextStyle(
                      fontSize:   13,
                      color:      _oliveGreen,
                      fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ),

          // ── CRITERIA TABLE ────────────────────────────────────────────────
          if (_expanded) ...[
            Divider(color: Colors.grey.shade100, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: _CriteresTable(criteres: a.criteres),
            ),

            if (a.notes != null && a.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Container(
                  width:   double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:        _cream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.notes_outlined,
                          size: 13, color: Colors.grey.shade400),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(a.notes!,
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                      ),
                    ],
                  ),
                ),
              ),

            Divider(color: Colors.grey.shade100, height: 1),

            // Action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onModifier,
                    icon:  const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Modifier',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _oliveGreen,
                      side:    BorderSide(
                          color: _oliveGreen.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape:   RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onSupprimer,
                    icon:  const Icon(Icons.delete_outline, size: 15),
                    label: const Text('Supprimer',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                      side:    BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape:   RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Criteria table ────────────────────────────────────────────────────────────
class _CriteresTable extends StatelessWidget {
  final List<CritereAnalyse> criteres;
  const _CriteresTable({required this.criteres});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TableRow(
          critere:  'Critère',
          valeur:   'Valeur',
          seuil:    'Norme',
          conforme: null,
          isHeader: true,
        ),
        ...criteres.map((c) => _TableRow(
          critere:  c.label,
          valeur:   '${c.valeur} ${c.unite}'.trim(),
          seuil:    _seuilLabel(c),
          conforme: c.conforme,
        )),
      ],
    );
  }

  String _seuilLabel(CritereAnalyse c) {
    if (c.seuilMin == null && c.seuilMax == null) return '—';
    if (c.seuilMin != null && c.seuilMax != null) {
      return '${c.seuilMin} – ${c.seuilMax} ${c.unite}'.trim();
    }
    if (c.seuilMax != null) return '≤ ${c.seuilMax} ${c.unite}'.trim();
    return '≥ ${c.seuilMin} ${c.unite}'.trim();
  }
}

class _TableRow extends StatelessWidget {
  final String critere;
  final String valeur;
  final String seuil;
  final bool?  conforme;
  final bool   isHeader;

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

    final indicatorColor = conforme == null
        ? Colors.transparent
        : conforme!
            ? _green
            : _red;

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color:        bg,
        borderRadius: BorderRadius.circular(8),
        border:       Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color:        indicatorColor,
                borderRadius: const BorderRadius.only(
                    topLeft:    Radius.circular(8),
                    bottomLeft: Radius.circular(8)),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Text(critere,
                    style: TextStyle(
                        fontSize:   12,
                        fontWeight: isHeader
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isHeader ? _oliveGreen : _darkText)),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Text(valeur,
                    style: TextStyle(
                        fontSize:   12,
                        fontWeight: FontWeight.w700,
                        color: isHeader
                            ? _oliveGreen
                            : conforme == false
                                ? _red
                                : _green)),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 8),
                child: Text(seuil,
                    style: TextStyle(
                        fontSize: 11,
                        color: isHeader
                            ? _oliveGreen
                            : Colors.grey.shade500)),
              ),
            ),
            if (!isHeader)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  conforme! ? Icons.check_circle : Icons.cancel,
                  color: conforme! ? _green : _red,
                  size:  16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Conformité banner ─────────────────────────────────────────────────────────
class _ConformiteBanner extends StatelessWidget {
  final AnalyseLabo analyse;
  const _ConformiteBanner({required this.analyse});

  @override
  Widget build(BuildContext context) {
    final ok  = analyse.toutConforme;
    final nb  = analyse.nbNonConformes;
    final bg  = ok ? _greenBg : _redBg;
    final col = ok ? _green   : _red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Icon(ok ? Icons.verified_outlined : Icons.warning_amber_outlined,
            color: col, size: 15),
        const SizedBox(width: 6),
        Text(
          ok
              ? 'Tous les critères sont conformes ✓'
              : '$nb critère(s) non conforme(s)',
          style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color:      col),
        ),
      ]),
    );
  }
}

// ── small meta chip ───────────────────────────────────────────────────────────
class _Meta extends StatelessWidget {
  final IconData icon;
  final String   label;
  const _Meta({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade500)),
        ],
      );
}
