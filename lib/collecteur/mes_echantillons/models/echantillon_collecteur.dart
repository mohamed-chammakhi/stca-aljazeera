// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/models/echantillon_collecteur.dart
//
// STATUS WORKFLOW (non-reversible, strictly sequential):
//
//   receptionne    → sample registered and received, evaluation in progress
//   enNegociation  → CEO validated; collector negotiating with supplier
//   achatConfirme  → negotiation succeeded; collector must plan delivery
//
// Notes:
//   • There is no "refuse" status. If the CEO rejects a sample it simply
//     never moves to enNegociation — it stays at receptionne on the
//     collector's side with no action available.
//   • If negotiation fails the sample stays frozen at enNegociation
//     with no action available. No status change occurs.
// ═════════════════════════════════════════════════════════════════════════════

// ── Status enum ───────────────────────────────────────────────────────────────
enum StatutCollecteur {
  receptionne, // was: enTraitement
  enNegociation, // was: valideANegocier
  achatConfirme,
}

// ── Delivery info ─────────────────────────────────────────────────────────────
class LivraisonInfo {
  DateTime date;
  String heure;
  String lieu;

  LivraisonInfo({required this.date, required this.heure, required this.lieu});

  /// True when all fields are filled — used by the card to decide whether to
  /// show the delivery summary box or the "non planifiée" warning banner.
  bool get isComplete => heure.trim().isNotEmpty && lieu.trim().isNotEmpty;
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
  });

  // ── Permission helpers ────────────────────────────────────────────────────

  /// Edit and delete allowed only while evaluation is still in progress.
  bool get canModify => statut == StatutCollecteur.receptionne;
  bool get canDelete => statut == StatutCollecteur.receptionne;

  /// Confirm purchase available only once CEO has sent to negotiation.
  bool get canConfirm => statut == StatutCollecteur.enNegociation;

  /// Delivery planning available once purchase is confirmed.
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;
}
