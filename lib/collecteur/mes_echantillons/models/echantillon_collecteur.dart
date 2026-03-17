// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/mes_echantillons/models/echantillon_collecteur.dart
// CHANGE  : + delegation field (nullable String) for map coloring
//           Everything else is identical to the existing version.
// ═════════════════════════════════════════════════════════════════════════════

// ── Statuts ───────────────────────────────────────────────────────────────────
enum StatutCollecteur {
  enTraitement, // just added — awaiting CEO review
  approuveEnNegociation, // CEO approved — price negotiation ongoing
  achatConfirme, // collector confirmed the purchase
  refus, // refused (by panel or failed negotiation)
  archive, // read-only, permanently closed
}

// ── Type de refus ─────────────────────────────────────────────────────────────
enum TypeRefus {
  refusPanel, // refused by tasting panel
  negociationEchouee, // negotiation failed — signaled by collector
}

// ── Livraison info ────────────────────────────────────────────────────────────
class LivraisonInfo {
  final DateTime? date;
  final String? heure;
  final String? lieu;

  LivraisonInfo({this.date, this.heure, this.lieu});

  bool get isComplete =>
      date != null &&
      heure != null &&
      heure!.isNotEmpty &&
      lieu != null &&
      lieu!.isNotEmpty;
}

// ── Main model ────────────────────────────────────────────────────────────────
class EchantillonCollecteur {
  // ── Never changes after creation ─────────────────────────────────────────
  final String id;
  final String ref; // formatted "2025/0001"
  final String collecteurId;
  final String collecteurNom;

  // ── Bordereau fields — editable by the collecteur ─────────────────────────
  String gouvernorat; // required — picked from 24 gouvernorat dropdown
  String? delegation; // ← NEW — optional, cascading from gouvernorat
  String? cite;
  //         when set → GeoService.markVisited() fires
  String codeFournisseur;
  String referenceBouteille;
  String? scellage;
  bool achatConfirme;
  String? camionReservee;
  String? remarques;

  // ── Operational fields ────────────────────────────────────────────────────
  String dateAjout;
  String? quantiteEstimee;
  String? variete;
  String? imageUrl;

  // ── Status & refus ────────────────────────────────────────────────────────
  StatutCollecteur statut;
  TypeRefus? typeRefus;
  String? raisonRefus;

  // ── Livraison ─────────────────────────────────────────────────────────────
  LivraisonInfo? livraison;

  EchantillonCollecteur({
    required this.id,
    required this.ref,
    required this.gouvernorat,
    required this.codeFournisseur,
    required this.referenceBouteille,
    required this.dateAjout,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
    this.delegation,
    this.cite, // ← NEW, optional
    this.scellage,
    this.achatConfirme = false,
    this.camionReservee,
    this.remarques,
    this.quantiteEstimee,
    this.variete,
    this.imageUrl,
    this.typeRefus,
    this.raisonRefus,
    this.livraison,
  });

  // ── Computed permissions ──────────────────────────────────────────────────
  bool get isArchive => statut == StatutCollecteur.archive;
  bool get isRefus => statut == StatutCollecteur.refus;
  bool get canModify => statut == StatutCollecteur.enTraitement;
  bool get canDelete => statut == StatutCollecteur.enTraitement;
  bool get canConfirm => statut == StatutCollecteur.approuveEnNegociation;
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;

  bool get cansignalerEchecNegociation =>
      statut == StatutCollecteur.approuveEnNegociation;

  // ── Display helpers ───────────────────────────────────────────────────────
  String get displayName => referenceBouteille;

  String get fournisseurRegion => '$codeFournisseur — $gouvernorat';

  /// Full location label — shows délégation when available
  String get locationLabel {
    if (cite != null && cite!.isNotEmpty) {
      return '$cite, $delegation, $gouvernorat';
    }
    if (delegation != null && delegation!.isNotEmpty) {
      return '$delegation, $gouvernorat';
    }
    return gouvernorat ?? '';
  }
}
