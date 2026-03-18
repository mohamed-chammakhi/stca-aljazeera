// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/models/echantillon_collecteur.dart
//
// STATUS WORKFLOW (non-reversible, strictly sequential):
//
//   enTraitement       → sample registered, panel/lab evaluation in progress
//   valideANegocier    → CEO approved; collector must negotiate with supplier
//   achatConfirme      → negotiation succeeded; collector must plan delivery
//   refuse             → CEO/panel rejection OR negotiation failed
//
// "archive" has been removed — it is not relevant to the collector's workflow.
// ═════════════════════════════════════════════════════════════════════════════

// ── Status enum ──────────────────────────────────────────────────────────────
enum StatutCollecteur {
  enTraitement,
  valideANegocier, // was: approuveEnNegociation
  achatConfirme,
  refuse, // was: refus
}

// ── Refusal sub-type ─────────────────────────────────────────────────────────
enum TypeRefus {
  refusPanel, // panel or CEO rejected the sample on quality grounds
  negociationEchouee, // collector could not reach a commercial agreement
}

// ── Delivery info ─────────────────────────────────────────────────────────────
class LivraisonInfo {
  DateTime date;
  String heure;
  String lieu;

  LivraisonInfo({required this.date, required this.heure, required this.lieu});
}

// ── Main model ────────────────────────────────────────────────────────────────
class EchantillonCollecteur {
  String id;
  String ref;

  // Location
  String gouvernorat;
  String? delegation;
  String? cite;

  // Supplier
  String codeFournisseur;

  // Bottle
  String referenceBouteille;
  String? scellage;
  String? quantiteEstimee;
  String? variete;

  // Purchase
  bool achatConfirme;
  String? camionReservee;
  LivraisonInfo? livraison;

  // Metadata
  String? remarques;
  String dateAjout;
  String? imageUrl;
  String collecteurId;
  String collecteurNom;

  // Status
  StatutCollecteur statut;
  TypeRefus? typeRefus;
  String? raisonRefus;

  EchantillonCollecteur({
    required this.id,
    required this.ref,
    required this.gouvernorat,
    this.delegation,
    this.cite,
    required this.codeFournisseur,
    required this.referenceBouteille,
    this.scellage,
    this.quantiteEstimee,
    this.variete,
    required this.achatConfirme,
    this.camionReservee,
    this.livraison,
    this.remarques,
    required this.dateAjout,
    this.imageUrl,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
    this.typeRefus,
    this.raisonRefus,
  });

  // ── Permission helpers used by the card and the page ──────────────────────

  /// Edit is allowed only while evaluation is still in progress.
  bool get canModify => statut == StatutCollecteur.enTraitement;

  /// Free delete within 30 min; after that a CEO-approved request is needed.
  /// Blocked once the sample has been evaluated (any status beyond enTraitement).
  bool get canDelete => statut == StatutCollecteur.enTraitement;

  /// Confirm purchase is available only after CEO validation.
  bool get canConfirm => statut == StatutCollecteur.valideANegocier;

  /// Delivery planning becomes available once the purchase is confirmed.
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;

  /// Collector can signal a failed negotiation only while in valideANegocier.
  bool get cansignalerEchecNegociation =>
      statut == StatutCollecteur.valideANegocier;
}
