import 'package:flutter/material.dart';
import '../widgets/analyse_labo_sheet.dart';

// ── Status enum ───────────────────────────────────────────────────────────────
enum StatutCeoView { selectionne, enNegociation, achatConfirme, refuse }

// ── Classification enum ───────────────────────────────────────────────────────
enum ClassificationHuile { extraVierge, vierge, viergeOrdinaire, lampante }

extension ClassificationHuileLabel on ClassificationHuile {
  String get label {
    switch (this) {
      case ClassificationHuile.extraVierge:
        return 'Extra Vierge';
      case ClassificationHuile.vierge:
        return 'Vierge';
      case ClassificationHuile.viergeOrdinaire:
        return 'Vierge Ordinaire';
      case ClassificationHuile.lampante:
        return 'Lampante';
    }
  }

  int get colorValue {
    switch (this) {
      case ClassificationHuile.extraVierge:
        return 0xFF38835A;
      case ClassificationHuile.vierge:
        return 0xFFF57C00;
      case ClassificationHuile.viergeOrdinaire:
        return 0xFFE64A19;
      case ClassificationHuile.lampante:
        return 0xFFD32F2F;
    }
  }
}

// ── Full evaluation model — all COI criteria ──────────────────────────────────
class EvaluationTasteur {
  final String tasteurId;
  final String tasteurNom;
  final ClassificationHuile classification;
  final DateTime soumisLe;

  // Attributs positifs
  final double? fruite;
  final bool fruiteVert; // true = Vert, false = Mûr
  final double? amertume;
  final double? piquant;

  // Attributs négatifs (défauts)
  final double? chome;
  final double? moisi;
  final double? vinaigre;
  final double? gele;
  final double? rance;
  final double? autresDefaut;
  final String? autresDefautNom;

  final String? commentaire;
  final String? defauts; // legacy

  const EvaluationTasteur({
    required this.tasteurId,
    required this.tasteurNom,
    required this.classification,
    required this.soumisLe,
    this.fruite,
    this.fruiteVert = true,
    this.amertume,
    this.piquant,
    this.chome,
    this.moisi,
    this.vinaigre,
    this.gele,
    this.rance,
    this.autresDefaut,
    this.autresDefautNom,
    this.commentaire,
    this.defauts,
  });

  double get medianeDefauts {
    final vals = [
      chome ?? 0.0,
      moisi ?? 0.0,
      vinaigre ?? 0.0,
      gele ?? 0.0,
      rance ?? 0.0,
      autresDefaut ?? 0.0,
    ];
    return vals.reduce((a, b) => a > b ? a : b);
  }
}

// ── Sample view model ─────────────────────────────────────────────────────────
class EchantillonCeoView {
  /// Sequential sample ID shown everywhere in the UI.
  /// Format: "YYYY/NNNN"  e.g. "2026/0001"
  final String id;

  /// Bottle reference written by the collector on the physical bottle.
  /// Examples: "CHEMLALI-C1", "ZALMATI-07-B", "CHETOUI-C3"
  final String referenceBouteille;

  final String gouvernorat;
  final String? delegation;
  final String codeFournisseur;
  final String? scellage;
  final String? variete;
  final String? quantiteEstimee;
  final String dateAjout;
  final String? dateLivraisonPrevue;
  final String? dateArriveeEchantillon;
  final String? collecteurNom;
  bool recuPhysiquement;
  StatutCeoView statut;
  final int totalTasteurs;
  final List<EvaluationTasteur> evaluations;
  final AnalyseLaboCeoView? analyse;
  String? raisonRefus;
  String? budgetNegociation;
  String? quantiteCibleT;
  String? camionReserve;
  String? noteInterne;
  bool stockArrive;
  String? dateLivraisonStock;
  String? remarques;

  EchantillonCeoView({
    required this.id,
    required this.referenceBouteille,
    required this.gouvernorat,
    this.delegation,
    required this.codeFournisseur,
    this.scellage,
    this.variete,
    this.quantiteEstimee,
    required this.dateAjout,
    this.dateLivraisonPrevue,
    this.dateArriveeEchantillon,
    this.collecteurNom,
    this.recuPhysiquement = false,
    required this.statut,
    required this.totalTasteurs,
    this.evaluations = const [],
    this.analyse,
    this.raisonRefus,
    this.budgetNegociation,
    this.quantiteCibleT,
    this.camionReserve,
    this.noteInterne,
    this.stockArrive = false,
    this.dateLivraisonStock,
    this.remarques,
  });

  int get nombreEvaluations => evaluations.length;
  bool get tousEvalue => evaluations.length >= totalTasteurs;

  ClassificationHuile? get classificationMajoritaire {
    if (evaluations.isEmpty) return null;
    final counts = <ClassificationHuile, int>{};
    for (final e in evaluations) {
      counts[e.classification] = (counts[e.classification] ?? 0) + 1;
    }
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
