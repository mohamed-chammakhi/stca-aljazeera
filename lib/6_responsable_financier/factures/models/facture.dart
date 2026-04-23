// ═════════════════════════════════════════════════════════════════════════════
// FILE : 6_responsable_financier/factures/models/facture.dart
// ═════════════════════════════════════════════════════════════════════════════

enum StatutFacture { brouillon, emise, payee }

extension StatutFactureX on StatutFacture {
  String get toJson {
    switch (this) {
      case StatutFacture.brouillon: return 'brouillon';
      case StatutFacture.emise:     return 'emise';
      case StatutFacture.payee:     return 'payee';
    }
  }

  String get label {
    switch (this) {
      case StatutFacture.brouillon: return 'Brouillon';
      case StatutFacture.emise:     return 'Émise';
      case StatutFacture.payee:     return 'Payée';
    }
  }

  static StatutFacture fromJson(String s) {
    switch (s) {
      case 'brouillon': return StatutFacture.brouillon;
      case 'emise':     return StatutFacture.emise;
      case 'payee':     return StatutFacture.payee;
      default: throw ArgumentError('Unknown statut_facture: $s');
    }
  }
}

class Facture {
  final String id;              // UUID
  final String numeroFacture;   // e.g. "FAC-2026-0012"
  final String achatId;         // linked echantillon/achat ID
  final String referenceBouteille;
  final String fournisseur;
  final String gouvernorat;
  final double quantiteT;
  final double prixUnitaireTnd; // DT/tonne
  final double montantTotal;    // quantiteT × prixUnitaireTnd
  StatutFacture statut;
  final String dateCreation;    // dd/MM/yyyy
  String? dateEmission;
  String? datePaiement;
  String? notes;

  Facture({
    required this.id,
    required this.numeroFacture,
    required this.achatId,
    required this.referenceBouteille,
    required this.fournisseur,
    required this.gouvernorat,
    required this.quantiteT,
    required this.prixUnitaireTnd,
    required this.montantTotal,
    required this.statut,
    required this.dateCreation,
    this.dateEmission,
    this.datePaiement,
    this.notes,
  });

  factory Facture.fromJson(Map<String, dynamic> json) => Facture(
    id:                  json['id']                   as String,
    numeroFacture:       json['numero_facture']        as String,
    achatId:             json['achat_id']              as String,
    referenceBouteille:  json['reference_bouteille']   as String,
    fournisseur:         json['fournisseur']            as String,
    gouvernorat:         json['gouvernorat']            as String,
    quantiteT:           (json['quantite_t'] as num).toDouble(),
    prixUnitaireTnd:     (json['prix_unitaire_tnd'] as num).toDouble(),
    montantTotal:        (json['montant_total'] as num).toDouble(),
    statut:              StatutFactureX.fromJson(json['statut'] as String),
    dateCreation:        json['date_creation']         as String,
    dateEmission:        json['date_emission']         as String?,
    datePaiement:        json['date_paiement']         as String?,
    notes:               json['notes']                 as String?,
  );

  Map<String, dynamic> toJson() => {
    'id':                 id,
    'numero_facture':     numeroFacture,
    'achat_id':           achatId,
    'reference_bouteille': referenceBouteille,
    'fournisseur':        fournisseur,
    'gouvernorat':        gouvernorat,
    'quantite_t':         quantiteT,
    'prix_unitaire_tnd':  prixUnitaireTnd,
    'montant_total':      montantTotal,
    'statut':             statut.toJson,
    'date_creation':      dateCreation,
    'date_emission':      dateEmission,
    'date_paiement':      datePaiement,
    'notes':              notes,
  };

  String get montantFormate =>
      '${montantTotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ')} DT';
}

// ── Mock data — TODO: remove when backend is ready ────────────────────────────
final List<Facture> mockFactures = [
  Facture(
    id: 'fac-001',
    numeroFacture: 'FAC-2026-0001',
    achatId: 'OL-2024-001',
    referenceBouteille: 'REF-2024-0341',
    fournisseur: 'FOUR-001',
    gouvernorat: 'Sfax',
    quantiteT: 12.0,
    prixUnitaireTnd: 4200,
    montantTotal: 50400,
    statut: StatutFacture.emise,
    dateCreation: '10/03/2026',
    dateEmission: '11/03/2026',
    notes: 'Livraison confirmée, camion TUN-448',
  ),
  Facture(
    id: 'fac-002',
    numeroFacture: 'FAC-2026-0002',
    achatId: 'OL-2024-002',
    referenceBouteille: 'REF-2024-0342',
    fournisseur: 'FOUR-003',
    gouvernorat: 'Bizerte',
    quantiteT: 8.5,
    prixUnitaireTnd: 4350,
    montantTotal: 36975,
    statut: StatutFacture.brouillon,
    dateCreation: '15/03/2026',
  ),
  Facture(
    id: 'fac-003',
    numeroFacture: 'FAC-2026-0003',
    achatId: 'OL-2024-003',
    referenceBouteille: 'REF-2024-0343',
    fournisseur: 'FOUR-007',
    gouvernorat: 'Kairouan',
    quantiteT: 20.0,
    prixUnitaireTnd: 3900,
    montantTotal: 78000,
    statut: StatutFacture.payee,
    dateCreation: '01/02/2026',
    dateEmission: '03/02/2026',
    datePaiement: '20/02/2026',
  ),
];
