// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/pages/mes_echantillons/models/echantillon_collecteur.dart
// ═════════════════════════════════════════════════════════════════════════════

export '../../../../../core/models/enums.dart' show StatutCollecteur;
import '../../../../../core/models/enums.dart' show StatutCollecteur;

// ─────────────────────────────────────────────────────────────────────────────
// PLANIFICATION LIVRAISON — stock delivery scheduling (post achatConfirme)
// ─────────────────────────────────────────────────────────────────────────────
class PlanificationLivraison {
  final DateTime? dateExacte;
  final String heure;
  final String lieu;
  final String? camion;

  PlanificationLivraison._({
    this.dateExacte,
    required this.heure,
    required this.lieu,
    this.camion,
  });

  factory PlanificationLivraison.exact({
    required DateTime date,
    required String heure,
    required String lieu,
    String? camion,
  }) => PlanificationLivraison._(
    dateExacte: date,
    heure: heure,
    lieu: lieu,
    camion: camion,
  );

  bool get isComplete => dateExacte != null && heure.isNotEmpty;

  String get libelle {
    final parts = <String>[];
    if (dateExacte != null) {
      parts.add(
        '${dateExacte!.day.toString().padLeft(2, '0')}/'
        '${dateExacte!.month.toString().padLeft(2, '0')}/'
        '${dateExacte!.year}',
      );
    }
    if (heure.isNotEmpty) parts.add(heure);
    if (lieu.isNotEmpty) parts.add(lieu);
    return parts.join('  ·  ');
  }
}

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
  PlanificationLivraison? livraison;

  // Sample delivery date (when the bottle is expected at the company)
  String? dateArriveeEchantillon;

  // Physical receipt (set by taster when sample arrives at company)
  bool recuPhysiquement;
  String? dateReceptionEchantillon; // "03/03/2026" — filled by taster

  // Negotiation details (communicated by CEO after approval)
  String? budgetNegociation;    // e.g. "9.50 TND/L"
  String? dateStockSouhaitee;   // e.g. "01/04/2026 - 15/04/2026"

  // Confirmed purchase details (filled by collector when confirming)
  String? prixFinal;       // e.g. "9.20 TND/L"
  String? camionLivraison; // e.g. "CAM-07"

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
    this.livraison,
    this.dateArriveeEchantillon,
    this.recuPhysiquement = false,
    this.dateReceptionEchantillon,
    this.budgetNegociation,
    this.dateStockSouhaitee,
    this.prixFinal,
    this.camionLivraison,
    this.remarques,
    required this.dateAjout,
    this.imageUrl,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
  });

  // Free edit+delete when receptionne and not yet received at company
  bool get canModify => statut == StatutCollecteur.receptionne;
  bool get canDelete => statut == StatutCollecteur.receptionne && !recuPhysiquement;
  bool get canConfirm => statut == StatutCollecteur.enNegociation;
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;
  // Scheduling sample-bottle arrival is only available before it's received
  bool get canScheduleArrivee =>
      statut == StatutCollecteur.receptionne && !recuPhysiquement;
}
