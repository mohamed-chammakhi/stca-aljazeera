// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/dialogs/analyse_dialog.dart
// PURPOSE : Entry-point bottom sheet — choose Manual entry or Scan.
//           Manual → delegates to formulaire_analyse_labo_dialog.dart
//           Scan   → delegates to scan_rapport_dialog.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../analyse_labo.dart';
import '../../models/echantillon_labo.dart';
import 'scan_rapport_dialog.dart';
import 'formulaire_analyse_labo_dialog.dart';

const Color _green    = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT  — shown when "Ajouter / Modifier une analyse" is tapped
// ─────────────────────────────────────────────────────────────────────────────
void showAnalyseChoiceSheet(
  BuildContext context, {
  required EchantillonLabo echantillon,
  AnalyseLabo? existing,
  required OnAnalyseSave onSave,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (_) => _ChoiceSheet(
      echantillon: echantillon,
      existing:    existing,
      onSave:      onSave,
    ),
  );
}

class _ChoiceSheet extends StatelessWidget {
  final EchantillonLabo echantillon;
  final AnalyseLabo?    existing;
  final OnAnalyseSave onSave;

  const _ChoiceSheet({
    required this.echantillon,
    this.existing,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ajouter un rapport d\'analyse',
            style: TextStyle(
              fontSize: 17, fontWeight: FontWeight.w800, color: _darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            echantillon.referenceBouteille,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 28),

          _OptionTile(
            icon:     Icons.document_scanner_outlined,
            title:    'Scanner le rapport papier',
            subtitle: 'Prenez une photo du rapport imprimé — les valeurs seront extraites automatiquement',
            color:    const Color(0xFF1565C0),
            onTap: () {
              Navigator.pop(context);
              showScanRapportDialog(context, echantillon: echantillon, onSave: onSave);
            },
          ),
          const SizedBox(height: 12),

          _OptionTile(
            icon:     Icons.edit_note_outlined,
            title:    'Saisir manuellement',
            subtitle: 'Remplissez les champs un par un selon les résultats du laboratoire',
            color:    _green,
            onTap: () {
              Navigator.pop(context);
              showFormulaireAnalyseLaboDialog(
                context,
                echantillonRef: echantillon.referenceBouteille,
                echantillonId:  echantillon.id,
                analyse:        existing,
                // Manual entry has no photo — drop the optional photo args.
                onSave:         (analyse) => onSave(analyse),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800, color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 14, color: color.withOpacity(0.6)),
        ],
      ),
    ),
  );
}
