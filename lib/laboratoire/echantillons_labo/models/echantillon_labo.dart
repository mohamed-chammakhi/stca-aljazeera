// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/models/echantillon_labo.dart
// PURPOSE : Lab sample model — lab-specific attributes only (no logistics)
// ═════════════════════════════════════════════════════════════════════════════

import '../../analyse_labo.dart';

class EchantillonLabo {
  final String id;
  final String ref;

  // ── Origin ────────────────────────────────────────────────────────────────
  final String gouvernorat;
  final String codeFournisseur;
  final String collecteurNom;

  // ── Bottle / sample identity ──────────────────────────────────────────────
  final String referenceBouteille;
  final String? variete;
  final String? quantiteEstimee; // estimated batch tonnage (info only)

  // ── Reception ─────────────────────────────────────────────────────────────
  final String dateArrivee; // date the bottle arrived at the lab
  final String? numeroLot; // internal lab lot number (optional)
  final String? origineCampagne; // harvest campaign, e.g. "2025/2026"

  // ── Lab priority / notes ──────────────────────────────────────────────────
  final PrioriteLabo priorite;
  final String? notesReception; // observations on reception (e.g. seal ok?)

  // ── Analysis ──────────────────────────────────────────────────────────────
  AnalyseLabo? analyse;

  EchantillonLabo({
    required this.id,
    required this.ref,
    required this.gouvernorat,
    required this.codeFournisseur,
    required this.collecteurNom,
    required this.referenceBouteille,
    this.variete,
    this.quantiteEstimee,
    required this.dateArrivee,
    this.numeroLot,
    this.origineCampagne,
    this.priorite = PrioriteLabo.normale,
    this.notesReception,
    this.analyse,
  });

  StatutAnalyse get statutAnalyse => analyse?.statut ?? StatutAnalyse.enAttente;

  bool get analyseComplete => analyse?.isComplete ?? false;

  bool get isUrgent => priorite == PrioriteLabo.urgente;
}

/// Lab-specific priority — has nothing to do with delivery logistics
enum PrioriteLabo { normale, urgente }
