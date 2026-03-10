// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/models/echantillon_collecteur.dart
// PURPOSE : data model for a sample added by a collector
// ═════════════════════════════════════════════════════════════════════════════

enum StatutCollecteur {
  enTraitement,        // just added by collector
  approuveEnNegociation, // CEO gave approval
  achatConfirme,       // collector confirmed purchase
  refus,               // refused (CEO or commercial)
  archive,             // read-only, permanently closed
}

enum TypeRefus {
  refusCEO,            // refused after panel evaluation
  refusCommercial,     // failed negotiation
}

class LivraisonInfo {
  DateTime? date;
  String?   heure;
  String?   lieu;

  LivraisonInfo({this.date, this.heure, this.lieu});

  bool get isComplete =>
      date != null && heure != null && lieu != null;
}

class EchantillonCollecteur {
  final String   id;
  String         reference;
  String         dateAjout;       // DD/MM/YYYY
  String         fournisseurNom;
  String         fournisseurId;
  String         region;
  String?        variete;
  String?        quantiteEstimee;
  String?        imageUrl;        // bottle photo
  String?        notes;
  StatutCollecteur statut;
  TypeRefus?     typeRefus;
  String?        raisonRefus;
  LivraisonInfo? livraison;
  final String   collecteurId;
  final String   collecteurNom;

  EchantillonCollecteur({
    required this.id,
    required this.reference,
    required this.dateAjout,
    required this.fournisseurNom,
    required this.fournisseurId,
    required this.region,
    required this.statut,
    required this.collecteurId,
    required this.collecteurNom,
    this.variete,
    this.quantiteEstimee,
    this.imageUrl,
    this.notes,
    this.typeRefus,
    this.raisonRefus,
    this.livraison,
  });

  bool get isArchive   => statut == StatutCollecteur.archive;
  bool get isRefus     => statut == StatutCollecteur.refus;
  bool get canModify   => statut == StatutCollecteur.enTraitement;
  bool get canDelete   => statut == StatutCollecteur.enTraitement;
  bool get canConfirm  =>
      statut == StatutCollecteur.approuveEnNegociation;
  bool get canPlanifier =>
      statut == StatutCollecteur.achatConfirme;
}
