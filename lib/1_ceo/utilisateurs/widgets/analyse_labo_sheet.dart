// ═════════════════════════════════════════════════════════════════════════════
// FILE : ceo/utilisateurs/widgets/analyse_labo_sheet.dart
// PURPOSE : Read-only bottom sheet showing a sample's lab analysis
//           Reused in both collecteur and dégustateur detail pages
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _dark  = Color(0xFF1A2E1F);
const Color _olive = Color(0xFF6B8143);

// ── Simple model to pass analysis data without importing labo files ──────────
class AnalyseLaboCeoView {
  final String? classification;
  final double? aciditeLibre;
  final double? indicePeroxyde;
  final double? k232;
  final double? k270;
  final double? deltaK;
  final double? humidite;
  final double? impuretes;
  final double? polyphenolsTotaux;
  final double? tocopherols;
  final double? acideOleique;
  final double? acideLinoleique;
  final double? acidePalmitique;
  final String? dateAnalyse;
  final String? notes;

  const AnalyseLaboCeoView({
    this.classification,
    this.aciditeLibre,
    this.indicePeroxyde,
    this.k232,
    this.k270,
    this.deltaK,
    this.humidite,
    this.impuretes,
    this.polyphenolsTotaux,
    this.tocopherols,
    this.acideOleique,
    this.acideLinoleique,
    this.acidePalmitique,
    this.dateAnalyse,
    this.notes,
  });

  String get classificationAuto {
    if (aciditeLibre == null || indicePeroxyde == null) return '—';
    if (aciditeLibre! <= 0.8 &&
        indicePeroxyde! <= 20 &&
        (k270 == null || k270! <= 0.22) &&
        (k232 == null || k232! <= 2.50)) return 'Extra Vierge';
    if (aciditeLibre! <= 2.0 && indicePeroxyde! <= 20) return 'Vierge';
    return 'Lampante';
  }
}

// ── Entry point ───────────────────────────────────────────────────────────────
void showAnalyseLaboSheet(
  BuildContext context, {
  required String sampleRef,
  required AnalyseLaboCeoView analyse,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AnalyseLaboSheet(sampleRef: sampleRef, analyse: analyse),
  );
}

// ── Chip shown on each card when analysis exists ──────────────────────────────
class AnalyseLaboChip extends StatelessWidget {
  final VoidCallback onTap;
  const AnalyseLaboChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.biotech_outlined, size: 11, color: Colors.teal.shade700),
              const SizedBox(width: 4),
              Text(
                'Analyse labo',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal.shade700,
                ),
              ),
            ],
          ),
        ),
      );
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────
class _AnalyseLaboSheet extends StatelessWidget {
  final String sampleRef;
  final AnalyseLaboCeoView analyse;
  const _AnalyseLaboSheet({required this.sampleRef, required this.analyse});

  @override
  Widget build(BuildContext context) {
    final classif = analyse.classificationAuto;
    final classifColor = _classifColor(classif);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: _cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
          children: [
            // Handle
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Icon(Icons.biotech_outlined,
                      color: Colors.teal.shade700, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analyse de laboratoire',
                        style: GoogleFonts.domine(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      Text(
                        sampleRef,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (analyse.dateAnalyse != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  'Soumis le ${analyse.dateAnalyse}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Classification banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: classifColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: classifColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_outlined,
                      size: 18, color: classifColor),
                  const SizedBox(width: 10),
                  Text(
                    classif,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: classifColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Essential parameters
            _SectionLabel('Paramètres essentiels COI'),
            const SizedBox(height: 8),
            _ParamRow('Acidité libre', analyse.aciditeLibre,
                '% ac. oléique', warn: analyse.aciditeLibre != null && analyse.aciditeLibre! > 0.8),
            _ParamRow('Indice de peroxyde', analyse.indicePeroxyde,
                'meqO₂/kg', warn: analyse.indicePeroxyde != null && analyse.indicePeroxyde! > 20),
            _ParamRow('K₂₃₂', analyse.k232, '',
                warn: analyse.k232 != null && analyse.k232! > 2.50),
            _ParamRow('K₂₇₀', analyse.k270, '',
                warn: analyse.k270 != null && analyse.k270! > 0.22),
            _ParamRow('ΔK', analyse.deltaK, '',
                warn: analyse.deltaK != null && analyse.deltaK! > 0.01),

            // Quality indicators
            if (analyse.polyphenolsTotaux != null ||
                analyse.tocopherols != null ||
                analyse.humidite != null) ...[
              const SizedBox(height: 14),
              _SectionLabel('Indicateurs de qualité'),
              const SizedBox(height: 8),
              _ParamRow('Polyphénols totaux', analyse.polyphenolsTotaux, 'mg/kg'),
              _ParamRow('Tocophérols', analyse.tocopherols, 'mg/kg'),
              _ParamRow('Humidité', analyse.humidite, '%',
                  warn: analyse.humidite != null && analyse.humidite! > 0.2),
              _ParamRow('Impuretés', analyse.impuretes, '%',
                  warn: analyse.impuretes != null && analyse.impuretes! > 0.1),
            ],

            // Fatty acid profile
            if (analyse.acideOleique != null ||
                analyse.acideLinoleique != null ||
                analyse.acidePalmitique != null) ...[
              const SizedBox(height: 14),
              _SectionLabel('Profil en acides gras'),
              const SizedBox(height: 8),
              _ParamRow('Acide oléique', analyse.acideOleique, '%'),
              _ParamRow('Acide linoléique', analyse.acideLinoleique, '%'),
              _ParamRow('Acide palmitique', analyse.acidePalmitique, '%'),
            ],

            // Notes
            if (analyse.notes != null && analyse.notes!.isNotEmpty) ...[
              const SizedBox(height: 14),
              _SectionLabel('Notes du technicien'),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  analyse.notes!,
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _classifColor(String c) {
    if (c == 'Extra Vierge') return _green;
    if (c == 'Vierge') return Colors.orange.shade700;
    if (c == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _olive,
          letterSpacing: 0.4,
        ),
      );
}

class _ParamRow extends StatelessWidget {
  final String label;
  final double? value;
  final String unit;
  final bool warn;
  const _ParamRow(this.label, this.value, this.unit, {this.warn = false});

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox.shrink();
    final color = warn ? Colors.red.shade600 : _dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
          if (warn)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(Icons.warning_amber_rounded,
                  size: 13, color: Colors.red.shade400),
            ),
          Text(
            '${_fmt(value!)} $unit'.trim(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
}
