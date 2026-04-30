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

  factory EchantillonLabo.fromJson(Map<String, dynamic> json) => EchantillonLabo(
    id:                 json['id']                 as String,
    ref:                json['ref']                as String,
    gouvernorat:        json['gouvernorat']         as String,
    codeFournisseur:    json['code_fournisseur']    as String,
    collecteurNom:      json['collecteur_nom']      as String,
    referenceBouteille: json['reference_bouteille'] as String,
    variete:            json['variete']             as String?,
    quantiteEstimee:    json['quantite_estimee']    as String?,
    dateArrivee:        json['date_arrivee']        as String,
    numeroLot:          json['numero_lot']          as String?,
    origineCampagne:    json['origine_campagne']    as String?,
    priorite: PrioriteLabo.values.firstWhere(
      (p) => p.name == (json['priorite'] as String? ?? 'normale'),
      orElse: () => PrioriteLabo.normale,
    ),
    notesReception: json['notes_reception'] as String?,
    analyse: json['analyse'] != null
        ? AnalyseLabo.fromJson(json['analyse'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id':                  id,
    'ref':                 ref,
    'gouvernorat':         gouvernorat,
    'code_fournisseur':    codeFournisseur,
    'collecteur_nom':      collecteurNom,
    'reference_bouteille': referenceBouteille,
    'variete':             variete,
    'quantite_estimee':    quantiteEstimee,
    'date_arrivee':        dateArrivee,
    'numero_lot':          numeroLot,
    'origine_campagne':    origineCampagne,
    'priorite':            priorite.name,
    'notes_reception':     notesReception,
    'analyse':             analyse?.toJson(),
  };
}

/// Lab-specific priority — has nothing to do with delivery logistics
enum PrioriteLabo { normale, urgente }
