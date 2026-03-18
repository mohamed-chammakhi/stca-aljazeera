// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/bouteille_row.dart
//
// Data model for one row in the bottle table.
// Each row holds its own ref, scellage, and quantité controllers.
// Scellage is a plain TextField — not a dropdown.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController scellageCtrl;
  final TextEditingController qteCtrl;

  BouteilleRow({
    required this.refCtrl,
    required this.scellageCtrl,
    required this.qteCtrl,
  });

  /// Blank row for when the user taps "Ajouter une bouteille"
  factory BouteilleRow.empty() => BouteilleRow(
        refCtrl: TextEditingController(),
        scellageCtrl: TextEditingController(),
        qteCtrl: TextEditingController(),
      );

  /// Seeded row for edit mode — pre-fills from an existing sample
  factory BouteilleRow.fromSample({
    required String ref,
    required String scellage,
    required String qte,
  }) =>
      BouteilleRow(
        refCtrl: TextEditingController(text: ref),
        scellageCtrl: TextEditingController(text: scellage),
        qteCtrl: TextEditingController(text: qte),
      );

  void dispose() {
    refCtrl.dispose();
    scellageCtrl.dispose();
    qteCtrl.dispose();
  }
}
