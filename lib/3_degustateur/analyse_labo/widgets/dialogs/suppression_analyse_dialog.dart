// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/widgets/dialogs/suppression_analyse_dialog.dart
// PURPOSE : confirmation dialog before deleting an analysis
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/analyse_labo.dart';

Future<void> showSuppressionAnalyseDialog(
  BuildContext context, {
  required AnalyseLabo  analyse,
  required VoidCallback onConfirmer,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(children: [
        Icon(Icons.warning_amber_rounded,
            color: Colors.red.shade400, size: 22),
        const SizedBox(width: 8),
        const Text('Supprimer l\'analyse',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ]),
      content: Text(
        'Voulez-vous vraiment supprimer l\'analyse de\n'
        '"${analyse.echantillonNom}" ?\n\nCette action est irréversible.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text('Annuler',
              style: TextStyle(
                  color:      Colors.grey.shade500,
                  fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            elevation:       0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Supprimer',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}
