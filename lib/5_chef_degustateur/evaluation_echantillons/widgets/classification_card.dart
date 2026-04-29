import 'package:flutter/material.dart';
import '../../widgets/chef_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET — ClassificationCard
// Affiche la classification COI en temps réel
// Extrait de FormulaireEvaluationPage._buildClassificationCard()
// ─────────────────────────────────────────────────────────────────────────────
class ClassificationCard extends StatelessWidget {
  // ── Classification result ────────────────────────────────────────────────
  final String classificationLabel;
  final String classificationDescription;
  final Color classificationColor;
  final Color classificationBg;
  final Color classificationBorder;
  final IconData classificationIcon;

  // ── Positive attribute values (for summary pills) ────────────────────────
  final double fruite;
  final bool fruiteVert;
  final double amer;
  final double piquant;

  // ── Negative attribute values (for summary pills) ────────────────────────
  final double chome;
  final double moisi;
  final double vinaigre;
  final double gele;
  final double rance;
  final double autresDefaut;

  // ── Mediane défauts (shown in header) ───────────────────────────────────
  final double medianeDefauts;

  const ClassificationCard({
    super.key,
    required this.classificationLabel,
    required this.classificationDescription,
    required this.classificationColor,
    required this.classificationBg,
    required this.classificationBorder,
    required this.classificationIcon,
    required this.fruite,
    required this.fruiteVert,
    required this.amer,
    required this.piquant,
    required this.chome,
    required this.moisi,
    required this.vinaigre,
    required this.gele,
    required this.rance,
    required this.autresDefaut,
    required this.medianeDefauts,
  });

  Widget _valuePill(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(1)}',
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: classificationBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: classificationBorder, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                classificationIcon,
                color: classificationColor,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Classification COI',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // ── Médiane défaut ──
              Text(
                'Méd. défaut: ${medianeDefauts.toStringAsFixed(1)}',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            classificationLabel,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: classificationColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            classificationDescription,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 12),

          // ── Résumé des valeurs ──
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (fruite > 0)
                _valuePill(
                  'Fruité ${fruiteVert ? "Vert" : "Mûr"}',
                  fruite,
                  chefGreen,
                ),
              if (amer > 0) _valuePill('Amer', amer, chefOlive),
              if (piquant > 0) _valuePill('Piquant', piquant, chefOlive),
              if (chome > 0) _valuePill('Chômé', chome, Colors.orange),
              if (moisi > 0) _valuePill('Moisi', moisi, Colors.orange),
              if (vinaigre > 0) _valuePill('Vinaigré', vinaigre, Colors.red),
              if (gele > 0) _valuePill('Gelé', gele, Colors.red),
              if (rance > 0) _valuePill('Rance', rance, Colors.red),
              if (autresDefaut > 0)
                _valuePill('Autre', autresDefaut, Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
