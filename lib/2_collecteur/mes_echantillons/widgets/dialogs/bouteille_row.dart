import 'dart:typed_data';

import 'package:flutter/material.dart';

class BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController varieteCtrl;
  final TextEditingController numCiterneCtrl;
  final TextEditingController qteCtrl;
  Uint8List? photoBytes;
  String? photoName;

  BouteilleRow({
    required this.refCtrl,
    required this.varieteCtrl,
    required this.numCiterneCtrl,
    required this.qteCtrl,
    this.photoBytes,
    this.photoName,
  });

  factory BouteilleRow.empty() => BouteilleRow(
    refCtrl: TextEditingController(),
    varieteCtrl: TextEditingController(),
    numCiterneCtrl: TextEditingController(),
    qteCtrl: TextEditingController(),
  );

  factory BouteilleRow.fromSample({
    required String referenceBouteille,
    required String variete,
    required String numCiterne,
    required String qte,
  }) => BouteilleRow(
    refCtrl: TextEditingController(text: referenceBouteille),
    varieteCtrl: TextEditingController(text: variete),
    numCiterneCtrl: TextEditingController(text: numCiterne),
    qteCtrl: TextEditingController(text: qte),
  );

  void dispose() {
    refCtrl.dispose();
    varieteCtrl.dispose();
    numCiterneCtrl.dispose();
    qteCtrl.dispose();
  }
}
