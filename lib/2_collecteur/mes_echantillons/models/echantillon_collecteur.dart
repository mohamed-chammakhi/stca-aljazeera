// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/models/echantillon_collecteur.dart
// ═════════════════════════════════════════════════════════════════════════════

export '../../../../../core/models/enums.dart' show StatutCollecteur;
import '../../../../../core/models/enums.dart' show StatutCollecteur;

// ── Display helpers (used by model and UI layers) ─────────────────────────────
String fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String fmtDateHeure(DateTime d) {
  final base = fmtDate(d);
  if (d.hour == 0 && d.minute == 0) return base;
  return '$base à ${d.hour.toString().padLeft(2, '0')}h${d.minute.toString().padLeft(2, '0')}';
}

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

  factory PlanificationLivraison.fromJson(Map<String, dynamic> json) =>
      PlanificationLivraison._(
        dateExacte: json['date_exacte'] != null
            ? DateTime.parse(json['date_exacte'] as String)
            : null,
        heure: json['heure'] as String? ?? '',
        lieu: json['lieu'] as String? ?? '',
        camion: json['camion'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'date_exacte': dateExacte?.toIso8601String(),
    'heure': heure,
    'lieu': lieu,
    'camion': camion,
  };

  bool get isComplete => dateExacte != null && heure.isNotEmpty;

  String get libelle {
    final parts = <String>[];
    if (dateExacte != null) parts.add(fmtDate(dateExacte!));
    if (heure.isNotEmpty) parts.add(heure);
    if (lieu.isNotEmpty) parts.add(lieu);
    return parts.join('  ·  ');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ECHANTILLON COLLECTEUR
// ─────────────────────────────────────────────────────────────────────────────
class EchantillonCollecteur {
  String id;
  String numero;

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
  DateTime? dateArriveeEchantillon;

  // Physical receipt (set by taster when sample arrives at company)
  bool recuPhysiquement;
  DateTime? dateReceptionEchantillon;

  // Negotiation details (communicated by CEO after approval)
  String? budgetNegociation;
  // Stock delivery window desired by CEO — may be a range or a single date
  DateTime? dateStockSouhaiteeDebut;
  DateTime? dateStockSouhaiteeFin;

  // Confirmed purchase details (filled by collector when confirming)
  String? prixFinal;
  String? camionLivraison;

  // Metadata
  String? remarques;
  DateTime dateAjout;

  String? imageUrl;
  String collecteurId;
  String collecteurNom;

  // Status
  StatutCollecteur statut;

  EchantillonCollecteur({
    required this.id,
    required this.numero,
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
    this.dateStockSouhaiteeDebut,
    this.dateStockSouhaiteeFin,
    this.prixFinal,
    this.camionLivraison,
    this.remarques,
    required this.dateAjout,
    this.imageUrl,
    required this.collecteurId,
    required this.collecteurNom,
    required this.statut,
  });

  factory EchantillonCollecteur.fromJson(Map<String, dynamic> json) =>
      EchantillonCollecteur(
        id: json['id'] as String,
        numero: json['numero'] as String,
        gouvernorat: json['gouvernorat'] as String,
        delegation: json['delegation'] as String?,
        cite: json['cite'] as String?,
        codeFournisseur: json['code_fournisseur'] as String? ?? '',
        referenceBouteille: json['reference_bouteille'] as String? ?? '',
        scellage: json['scellage'] as String?,
        quantiteEstimee: json['quantite_estimee'] as String?,
        variete: json['variete'] as String?,
        achatConfirme: json['statut_collecteur'] == 'achat_confirme',
        livraison: null,
        dateArriveeEchantillon: json['date_arrivee_echantillon'] != null
            ? DateTime.parse(json['date_arrivee_echantillon'] as String)
            : null,
        recuPhysiquement: json['recu_physiquement'] as bool? ?? false,
        dateReceptionEchantillon: null,
        budgetNegociation: json['budget_negociation']?.toString(),
        dateStockSouhaiteeDebut: null,
        dateStockSouhaiteeFin: null,
        prixFinal: json['prix_final']?.toString(),
        camionLivraison: json['camion_reserve'] as String?,
        remarques: json['remarques'] as String?,
        dateAjout: DateTime.parse(json['date_ajout'] as String),
        imageUrl: json['image_url'] as String?,
        collecteurId: json['collecteur']?.toString() ?? '',
        collecteurNom: json['collecteur_nom'] as String? ?? '',
        statut: StatutCollecteur.values.byName(json['statut_collecteur'] as String),
      );

  Map<String, dynamic> toJson() => {
    'gouvernorat': gouvernorat,
    'delegation': delegation ?? '',
    'cite': cite ?? '',
    'reference_bouteille': referenceBouteille,
    'scellage': scellage ?? '',
    'quantite_estimee': quantiteEstimee ?? '',
    'variete': variete ?? '',
    'statut_collecteur': statut.name,
    'date_arrivee_echantillon': dateArriveeEchantillon?.toIso8601String(),
    'recu_physiquement': recuPhysiquement,
    'budget_negociation': budgetNegociation,
    'prix_final': prixFinal,
    'camion_reserve': camionLivraison ?? '',
    'remarques': remarques ?? '',
    'image_url': imageUrl ?? '',
  };

  // Handles Django paginated format: { "count": N, "results": [...] }
  static List<EchantillonCollecteur> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => EchantillonCollecteur.fromJson(e as Map<String, dynamic>))
          .toList();

  bool get canModify => statut == StatutCollecteur.receptionne;
  bool get canDelete =>
      statut == StatutCollecteur.receptionne && !recuPhysiquement;
  bool get canConfirm => statut == StatutCollecteur.enNegociation;
  bool get canPlanifier => statut == StatutCollecteur.achatConfirme;
  bool get canScheduleArrivee =>
      statut == StatutCollecteur.receptionne && !recuPhysiquement;
}
