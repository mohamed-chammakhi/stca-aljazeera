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
    case StatutAnalyse.soumise:
      return const Color(0xFF38835A);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class AnalyseCard extends StatefulWidget {
  final AnalyseLabo analyse;

  const AnalyseCard({super.key, required this.analyse});

  @override
  State<AnalyseCard> createState() => _AnalyseCardState();
}

class _AnalyseCardState extends State<AnalyseCard> {
  bool _expanded = false;
  bool _rapportExpanded = false;

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
            secondChild: _DetailPanel(
              a: a,
              accent: accent,
              rapportExpanded: _rapportExpanded,
              onRapportToggle: () =>
                  setState(() => _rapportExpanded = !_rapportExpanded),
            ),
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
// DETAIL PANEL
// ─────────────────────────────────────────────────────────────────────────────
class _DetailPanel extends StatelessWidget {
  final AnalyseLabo a;
  final Color accent;
  final bool rapportExpanded;
  final VoidCallback onRapportToggle;

  const _DetailPanel({
    required this.a,
    required this.accent,
    required this.rapportExpanded,
    required this.onRapportToggle,
  });

  @override
  Widget build(BuildContext context) {
    final hasAnalyse = a.statut == StatutAnalyse.soumise;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade100, height: 1),

        // ── Sample details ──────────────────────────────────────────────
        if (a.fournisseurNom != null ||
            a.gouvernorat != null ||
            a.collecteurNom != null ||
            a.variete != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Informations de l'échantillon",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 60,
                  runSpacing: 8,
                  children: [
                    _DetailItem('N° échantillon', a.echantillonId),
                    if (a.fournisseurNom != null)
                      _DetailItem('Fournisseur', a.fournisseurNom!),
                    if (a.variete != null) _DetailItem('Variété', a.variete!),
                    if (a.gouvernorat != null)
                      _DetailItem(
                        'Gouvernorat',
                        a.delegation != null
                            ? '${a.gouvernorat} — ${a.delegation}'
                            : a.gouvernorat!,
                      ),
                    if (a.collecteurNom != null)
                      _DetailItem('Collecteur', a.collecteurNom!),
                    if (a.quantiteEstimee != null)
                      _DetailItem('Quantité estimée', '${a.quantiteEstimee} T'),
                  ],
                ),
              ],
            ),
          ),

        // ── "Analyse soumise par … le …" attribution line ───────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 2),
          child: Row(
            children: [
              Icon(Icons.person_outline, size: 13, color: Colors.grey.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    children: [
                      const TextSpan(text: 'Analyse soumise par '),
                      TextSpan(
                        text: a.technicienNom,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      if (a.dateAnalyse.isNotEmpty)
                        TextSpan(text: ' le ${a.dateAnalyse}'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Rapport section ─────────────────────────────────────────────
        GestureDetector(
          onTap: hasAnalyse ? onRapportToggle : null,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  Icons.biotech_outlined,
                  size: 13,
                  color: hasAnalyse ? _green : Colors.grey.shade300,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rapport',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasAnalyse ? _green : Colors.grey.shade300,
                  ),
                ),
                const Spacer(),
                if (hasAnalyse && a.dateAnalyse.isNotEmpty)
                  Text(
                    'Soumis le ${a.dateAnalyse}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: rapportExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: hasAnalyse ? _green : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: hasAnalyse ? _RapportBody(a: a) : _EnAttenteHint(),
          crossFadeState: rapportExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPORT BODY  — criteria table + optional notes
// ─────────────────────────────────────────────────────────────────────────────
class _RapportBody extends StatelessWidget {
  final AnalyseLabo a;
  const _RapportBody({required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _CriteresTable(criteres: a.criteres),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EN ATTENTE HINT
// ─────────────────────────────────────────────────────────────────────────────
class _EnAttenteHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.orange.shade50,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.orange.shade100),
    ),
    child: Row(
      children: [
        Icon(
          Icons.hourglass_top_outlined,
          size: 13,
          color: Colors.orange.shade700,
        ),
        const SizedBox(width: 6),
        Text(
          'Analyse non encore soumise',
          style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
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
