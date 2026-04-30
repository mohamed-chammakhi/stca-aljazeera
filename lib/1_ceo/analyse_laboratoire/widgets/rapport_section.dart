// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/analyse_laboratoire/widgets/rapport_section.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../../utilisateurs/models/echantillon_ceo_view.dart';
import '../models/lab_row.dart';

const Color _teal = Color(0xFF00796B);

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP  — shared pattern across pages
// Active "Tout"    → solid gray (#757575) bg + white text
// Active status    → tinted bg + colored text
// Inactive any     → light gray bg + gray text
// ─────────────────────────────────────────────────────────────────────────────
class LaboFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color activeBg;
  final Color activeFg;
  final VoidCallback onTap;

  const LaboFilterChip({
    required this.label,
    required this.isActive,
    required this.activeBg,
    required this.activeFg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color inactiveBg = Color(0xFFF0F0F0);
    const Color inactiveFg = Color(0xFF9E9E9E);

    final bg = isActive ? activeBg : inactiveBg;
    final fg = isActive ? activeFg : inactiveFg;
    final borderColor = isActive
        ? activeFg.withValues(alpha: activeFg == Colors.white ? 0.0 : 0.3)
        : const Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RAPPORT SECTION  — bottom slot for labo cards
// ─────────────────────────────────────────────────────────────────────────────
class RapportSection extends StatelessWidget {
  final EchantillonCeoView echantillon;
  final bool hasAnalyse;
  final bool isExpanded;
  final VoidCallback onToggle;

  const RapportSection({
    required this.echantillon,
    required this.hasAnalyse,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final e = echantillon;
    return Column(
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  Icons.biotech_outlined,
                  size: 13,
                  color: hasAnalyse ? _teal : Colors.grey.shade300,
                ),
                const SizedBox(width: 6),
                Text(
                  'Rapport laboratoire',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
                const Spacer(),
                if (hasAnalyse && e.analyse!.dateAnalyse != null)
                  Text(
                    'Soumis le ${e.analyse!.dateAnalyse!}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: hasAnalyse ? _teal : Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: hasAnalyse
              ? RapportBlock(analyse: e.analyse!)
              : EnAttenteHint(),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class RapportBlock extends StatelessWidget {
  final AnalyseLaboCeoView analyse;
  const RapportBlock({super.key, required this.analyse});

  List<LabRow> _buildRows(AnalyseLaboCeoView a) {
    final rows = <LabRow>[];
    if (a.aciditeLibre != null) {
      final v = a.aciditeLibre!;
      rows.add(LabRow(
        label: 'Acidité libre',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.80 %',
        conforme: v <= 0.80,
      ));
    }
    if (a.indicePeroxyde != null) {
      final v = a.indicePeroxyde!;
      rows.add(LabRow(
        label: 'Ind. de peroxyde',
        value: '${v.toStringAsFixed(1)} meqO₂/kg',
        norm: '≤ 20',
        conforme: v <= 20,
      ));
    }
    if (a.k232 != null) {
      final v = a.k232!;
      rows.add(LabRow(
        label: 'K₂₃₂',
        value: v.toStringAsFixed(2),
        norm: '≤ 2.50',
        conforme: v <= 2.50,
      ));
    }
    if (a.k270 != null) {
      final v = a.k270!;
      rows.add(LabRow(
        label: 'K₂₇₀',
        value: v.toStringAsFixed(2),
        norm: '≤ 0.22',
        conforme: v <= 0.22,
      ));
    }
    if (a.deltaK != null) {
      final v = a.deltaK!;
      rows.add(LabRow(
        label: 'ΔK',
        value: v.toStringAsFixed(3),
        norm: '≤ 0.01',
        conforme: v <= 0.01,
      ));
    }
    if (a.polyphenolsTotaux != null) {
      rows.add(LabRow(
        label: 'Polyphénols totaux',
        value: '${a.polyphenolsTotaux!.toStringAsFixed(0)} mg/kg',
        norm: '—',
      ));
    }
    if (a.humidite != null) {
      final v = a.humidite!;
      rows.add(LabRow(
        label: 'Humidité',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.20 %',
        conforme: v <= 0.20,
      ));
    }
    if (a.impuretes != null) {
      final v = a.impuretes!;
      rows.add(LabRow(
        label: 'Impuretés',
        value: '${v.toStringAsFixed(2)} %',
        norm: '≤ 0.10 %',
        conforme: v <= 0.10,
      ));
    }
    if (a.acideOleique != null) {
      rows.add(LabRow(
        label: 'Acide oléique',
        value: '${a.acideOleique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.acideLinoleique != null) {
      rows.add(LabRow(
        label: 'Acide linoléique',
        value: '${a.acideLinoleique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.acidePalmitique != null) {
      rows.add(LabRow(
        label: 'Acide palmitique',
        value: '${a.acidePalmitique!.toStringAsFixed(1)} %',
        norm: '—',
      ));
    }
    if (a.tocopherols != null) {
      rows.add(LabRow(
        label: 'Tocophérols',
        value: '${a.tocopherols!.toStringAsFixed(0)} mg/kg',
        norm: '—',
      ));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final a = analyse;
    final rows = _buildRows(a);
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabTableRow(
            label: 'Critère',
            value: 'Valeur',
            norm: 'Norme',
            conforme: null,
            isHeader: true,
          ),
          const SizedBox(height: 2),
          ...rows.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: LabTableRow(
                label: r.label,
                value: r.value,
                norm: r.norm,
                conforme: r.conforme,
              ),
            ),
          ),
          if (a.notes != null && a.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
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

class LabTableRow extends StatelessWidget {
  final String label;
  final String value;
  final String norm;
  final bool? conforme;
  final bool isHeader;

  const LabTableRow({
    required this.label,
    required this.value,
    required this.norm,
    required this.conforme,
    this.isHeader = false,
  });

  static const Color _redVal = Color(0xFFC62828);
  static const Color _redBg = Color(0xFFFFEBEE);
  static const Color _tableOlive = Color(0xFF6B8143);
  static const Color _tableGreen = Color(0xFF38835A);

  @override
  Widget build(BuildContext context) {
    final bg = isHeader
        ? const Color(0xFFF1F8F4)
        : conforme == false
        ? _redBg
        : Colors.white;

    final barColor = isHeader
        ? Colors.transparent
        : conforme == false
        ? _redVal
        : _tableGreen;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
                    color: isHeader ? _tableOlive : kDark,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isHeader
                        ? _tableOlive
                        : conforme == false
                        ? _redVal
                        : _tableGreen,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: Colors.grey.shade100),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                child: Text(
                  norm,
                  style: TextStyle(
                    fontSize: 11,
                    color: isHeader ? _tableOlive : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
            if (!isHeader && conforme != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  conforme! ? Icons.check_circle : Icons.cancel,
                  color: conforme! ? _tableGreen : _redVal,
                  size: 13,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EnAttenteHint extends StatelessWidget {
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
        Text(
          'Analyse non encore soumise',
          style: TextStyle(fontSize: 13, color: Colors.orange.shade800),
        ),
      ],
    ),
  );
}
