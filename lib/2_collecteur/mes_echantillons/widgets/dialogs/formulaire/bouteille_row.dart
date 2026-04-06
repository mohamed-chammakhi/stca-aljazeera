// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/bouteille_row.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController varieteCtrl; // ← NEW
  final TextEditingController scellageCtrl;
  final TextEditingController qteCtrl;

  BouteilleRow({
    required this.refCtrl,
    required this.varieteCtrl,
    required this.scellageCtrl,
    required this.qteCtrl,
  });

  /// Blank row for when the user taps "Ajouter une bouteille"
  factory BouteilleRow.empty() => BouteilleRow(
    refCtrl: TextEditingController(),
    varieteCtrl: TextEditingController(),
    scellageCtrl: TextEditingController(),
    qteCtrl: TextEditingController(),
  );

  /// Seeded row for edit mode — pre-fills from an existing sample
  factory BouteilleRow.fromSample({
    required String ref,
    required String variete,
    required String scellage,
    required String qte,
  }) => BouteilleRow(
    refCtrl: TextEditingController(text: ref),
    varieteCtrl: TextEditingController(text: variete),
    scellageCtrl: TextEditingController(text: scellage),
    qteCtrl: TextEditingController(text: qte),
  );

  void dispose() {
    refCtrl.dispose();
    varieteCtrl.dispose();
    scellageCtrl.dispose();
    qteCtrl.dispose();
  }
}
