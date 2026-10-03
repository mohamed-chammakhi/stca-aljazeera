import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../analyses/rapport_labo.dart';
import '../analyses/widgets/tableau_rapport_labo.dart';
import '../theme/app_colors.dart';
import '../utils/date_utils.dart';

void showAnalyseLaboSheet(
  BuildContext context, {
  required String sampleRef,
  required RapportLabo analyse,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AnalyseLaboSheet(sampleRef: sampleRef, analyse: analyse),
  );
}

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

class _AnalyseLaboSheet extends StatelessWidget {
  final String sampleRef;
  final RapportLabo analyse;

  const _AnalyseLaboSheet({required this.sampleRef, required this.analyse});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: kCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: ListView(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 16),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Icon(
                    Icons.biotech_outlined,
                    color: Colors.teal.shade700,
                    size: 18,
                  ),
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
                          color: kDark,
                        ),
                      ),
                      Text(
                        sampleRef,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
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
                  'Soumis le ${DegDateUtils.formaterDateHeureOuTiret(analyse.dateAnalyse)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                ),
              ),
            ],
            const SizedBox(height: 16),
            BandeauClassification(classification: analyse.classificationAuto),
            if (analyse.horsNormes.isNotEmpty) ...[
              const SizedBox(height: 10),
              AlerteHorsNormes(parametres: analyse.horsNormes),
            ],
            const SizedBox(height: 18),
            TableauRapportLabo(rapport: analyse, groupeParTableau: true),
            if (analyse.notes != null && analyse.notes!.isNotEmpty) ...[
              const SizedBox(height: 2),
              const Text(
                'Notes du technicien',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kOlive,
                  letterSpacing: 0.4,
                ),
              ),
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
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
