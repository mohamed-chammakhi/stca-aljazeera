import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../normes_coi.dart';
import '../rapport_labo.dart';

/// Les titres des trois tableaux, dans l'ordre de [kTableauxAnalyse].
const List<String> kTitresTableauxAnalyse = [
  'Résultats principaux',
  'Composition en stérols',
  'Acides gras',
];

class TableauRapportLabo extends StatelessWidget {
  final RapportLabo rapport;
  final bool groupeParTableau;

  const TableauRapportLabo({
    super.key,
    required this.rapport,
    this.groupeParTableau = false,
  });

  @override
  Widget build(BuildContext context) {
    if (rapport.estVide) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: groupeParTableau ? _tableauxGroupes() : _tableau(kTousParametres),
    );
  }

  Widget _tableauxGroupes() {
    final groupesVisibles = <int>[
      for (var i = 0; i < kTableauxAnalyse.length; i++)
        if (kTableauxAnalyse[i].any((p) => rapport.valeur(p.cle) != null)) i,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (
          var position = 0;
          position < groupesVisibles.length;
          position++
        ) ...[
          if (position > 0) const SizedBox(height: 14),
          Text(
            kTitresTableauxAnalyse[groupesVisibles[position]],
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kOlive,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          _tableau(kTableauxAnalyse[groupesVisibles[position]]),
        ],
      ],
    );
  }

  Widget _tableau(List<ParametreAnalyse> parametres) {
    final valeursSaisies = [
      for (final p in parametres)
        if (rapport.valeur(p.cle) != null) p,
    ];

    return Column(
      children: [
        const LabTableRow(
          label: 'Critère',
          value: 'Valeur',
          norm: 'Norme',
          conforme: null,
          isHeader: true,
        ),
        const SizedBox(height: 2),
        for (final p in valeursSaisies)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: LabTableRow(
              label: p.label,
              value: formatValeurUnite(rapport.valeur(p.cle), p.unite),
              norm: p.norme,
              conforme: conformite(
                p,
                rapport.valeur(p.cle),
                valeurs: rapport.valeurs,
              ),
            ),
          ),
      ],
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
    super.key,
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

class AlerteHorsNormes extends StatelessWidget {
  final List<ParametreAnalyse> parametres;

  const AlerteHorsNormes({super.key, required this.parametres});

  @override
  Widget build(BuildContext context) {
    final rouge = Colors.red.shade700;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: rouge.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rouge.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: rouge),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  parametres.length == 1
                      ? '1 paramètre hors norme COI'
                      : '${parametres.length} paramètres hors norme COI',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: rouge,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  parametres.map((p) => p.label).join(', '),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BandeauClassification extends StatelessWidget {
  final String classification;

  const BandeauClassification({super.key, required this.classification});

  @override
  Widget build(BuildContext context) {
    final couleur = _couleurClassification(classification);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_outlined, size: 18, color: couleur),
          const SizedBox(width: 10),
          Text(
            classification,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }

  static Color _couleurClassification(String classification) {
    if (classification == 'Extra Vierge') return kGreen;
    if (classification == 'Vierge') return Colors.orange.shade700;
    if (classification == 'Lampante') return Colors.red.shade600;
    return Colors.grey.shade500;
  }
}
