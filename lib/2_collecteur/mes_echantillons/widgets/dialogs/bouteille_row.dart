import 'dart:typed_data';

import 'package:flutter/material.dart';

class BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController varieteCtrl;
  final TextEditingController numCiterneCtrl;
  final TextEditingController qteCtrl;
  final TextEditingController remarqueCtrl;
  Uint8List? photoBytes;
  String? photoName;

  BouteilleRow({
    required this.refCtrl,
    required this.varieteCtrl,
    required this.numCiterneCtrl,
    required this.qteCtrl,
    required this.remarqueCtrl,
    this.photoBytes,
    this.photoName,
  });

  factory BouteilleRow.empty() => BouteilleRow(
    refCtrl: TextEditingController(),
    varieteCtrl: TextEditingController(),
    numCiterneCtrl: TextEditingController(),
    qteCtrl: TextEditingController(),
    remarqueCtrl: TextEditingController(),
  );

  factory BouteilleRow.fromSample({
    required String referenceBouteille,
    required String variete,
    required String numCiterne,
    required String qte,
    required String remarque,
  }) => BouteilleRow(
    refCtrl: TextEditingController(text: referenceBouteille),
    varieteCtrl: TextEditingController(text: variete),
    numCiterneCtrl: TextEditingController(text: numCiterne),
    qteCtrl: TextEditingController(text: qte),
    remarqueCtrl: TextEditingController(text: remarque),
  );

  void dispose() {
    refCtrl.dispose();
    varieteCtrl.dispose();
    numCiterneCtrl.dispose();
    qteCtrl.dispose();
    remarqueCtrl.dispose();
  }
}
