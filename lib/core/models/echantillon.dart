// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/echantillon.dart
// PURPOSE : Shared sample model used by all roles (Dégustateur, CEO, Labo…)
//           Field names use snake_case in JSON to match Django serializer output.
// ═════════════════════════════════════════════════════════════════════════════

class Echantillon {
  // ── Identity ─────────────────────────────────────────────────────────────────
  String id;                  // "2026/0001" — sequential ID shown in UI
  String referenceBouteille; // "CHEMLALI-C1" — written on the physical bottle
  String codeFournisseur;    // supplier name or code, e.g. "SF-17"

  // ── Sample details ────────────────────────────────────────────────────────────
  String? variete;           // olive variety, e.g. "Chemlali"
  String gouvernorat;        // Tunisian governorate
  String? delegation;        // sub-region — optional
  String? quantiteEstimee;   // estimated quantity in tonnes, e.g. "25"
  String dateAjout;          // DD/MM/YYYY — date the sample was registered
  String? collecteurNom;     // collector name — null if added internally
  bool recuPhysiquement;     // true once the bottle physically arrives at company

  // ── Status ────────────────────────────────────────────────────────────────────
  // Degustateur/Labo statuses: 'En attente' | 'En cours' | 'Soumis'
  // CEO statuses: 'Sélectionné' | 'En négociation' | 'Achat confirmé' | 'Refusé'
  String statut;

  // ── Optional media ────────────────────────────────────────────────────────────
  String? photoUrl;
  String? scellage;          // seal / tamper evidence number

  // ── Scheduling ────────────────────────────────────────────────────────────────
  String? dateLivraisonPrevue;  // expected delivery date of the bottle
  String? dateLivraisonStock;   // expected full-stock delivery date (post-purchase)

  // ── Purchase / negotiation (CEO) ──────────────────────────────────────────────
  String? camionReserve;    // truck ID reserved for transport
  String? quantiteLivree;   // actual quantity delivered (tonnes)
  String? montantTotal;     // agreed price, e.g. "8.50 TND/L"
  String? noteInterne;      // internal note visible to Direction only

  Echantillon({
    required this.id,
    required this.referenceBouteille,
    required this.codeFournisseur,
    this.variete,
    required this.gouvernorat,
    this.delegation,
    this.quantiteEstimee,
    required this.dateAjout,
    this.collecteurNom,
    this.recuPhysiquement = false,
    required this.statut,
    this.photoUrl,
    this.scellage,
    this.dateLivraisonPrevue,
    this.dateLivraisonStock,
    this.camionReserve,
    this.quantiteLivree,
    this.montantTotal,
    this.noteInterne,
  });

  factory Echantillon.fromJson(Map<String, dynamic> json) {
    return Echantillon(
      id:                   json['id']                      as String,
      referenceBouteille:   json['reference_bouteille']     as String,
      codeFournisseur:      json['code_fournisseur']        as String,
      variete:              json['variete']                 as String?,
      gouvernorat:          json['gouvernorat']             as String,
      delegation:           json['delegation']              as String?,
      quantiteEstimee:      json['quantite_estimee']        as String?,
      dateAjout:            json['date_ajout']              as String,
      collecteurNom:        json['collecteur_nom']          as String?,
      recuPhysiquement:     (json['recu_physiquement'] as bool?) ?? false,
      statut:               json['statut']                  as String,
      photoUrl:             json['photo_url']               as String?,
      scellage:             json['scellage']                as String?,
      dateLivraisonPrevue:  json['date_livraison_prevue']   as String?,
      dateLivraisonStock:   json['date_livraison_stock']    as String?,
      camionReserve:        json['camion_reserve']          as String?,
      quantiteLivree:       json['quantite_livree']         as String?,
      montantTotal:         json['montant_total']           as String?,
      noteInterne:          json['note_interne']            as String?,
    );
  }

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<Echantillon> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => Echantillon.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id':                    id,
    'reference_bouteille':   referenceBouteille,
    'code_fournisseur':      codeFournisseur,
    'variete':               variete,
    'gouvernorat':           gouvernorat,
    'delegation':            delegation,
    'quantite_estimee':      quantiteEstimee,
    'date_ajout':            dateAjout,
    'collecteur_nom':        collecteurNom,
    'recu_physiquement':     recuPhysiquement,
    'statut':                statut,
    'photo_url':             photoUrl,
    'scellage':              scellage,
    'date_livraison_prevue': dateLivraisonPrevue,
    'date_livraison_stock':  dateLivraisonStock,
    'camion_reserve':        camionReserve,
    'quantite_livree':       quantiteLivree,
    'montant_total':         montantTotal,
    'note_interne':          noteInterne,
  };
}
