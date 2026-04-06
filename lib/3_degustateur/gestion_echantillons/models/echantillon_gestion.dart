// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/models/echantillon_gestion.dart
// PURPOSE : data model for one échantillon in gestion list
// ─────────────────────────────────────────────────────────────────────────────

class EchantillonGestion {
  String id;
  String ref;             // bottle reference
  String codeFournisseur; // supplier name / code
  String variete;         // olive variety
  String dateArrivee;     // DD/MM/YYYY
  String gouvernorat;     // Tunisian governorate (replaces origine)
  String? delegation;     // sub-region — optional, cascades from gouvernorat
  String quantite;        // quantity in tonnes (number only, display adds "T")
  String statut;
  String? photoUrl;
  String? collecteur;     // collector name — optional

  EchantillonGestion({
    required this.id,
    required this.ref,
    required this.codeFournisseur,
    required this.variete,
    required this.dateArrivee,
    required this.gouvernorat,
    this.delegation,
    required this.quantite,
    required this.statut,
    this.photoUrl,
    this.collecteur,
  });

  factory EchantillonGestion.fromJson(Map<String, dynamic> json) {
    return EchantillonGestion(
      id:             json['id']               as String,
      ref:            json['ref']              as String,
      codeFournisseur:json['code_fournisseur'] as String,
      variete:        json['variete']          as String,
      dateArrivee:    json['date_arrivee']     as String,
      gouvernorat:    json['gouvernorat']      as String,
      delegation:     json['delegation']       as String?,
      quantite:       json['quantite']         as String,
      statut:         json['statut']           as String,
      photoUrl:       json['photo_url']        as String?,
      collecteur:     json['collecteur']       as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'ref':              ref,
    'code_fournisseur': codeFournisseur,
    'variete':          variete,
    'date_arrivee':     dateArrivee,
    'gouvernorat':      gouvernorat,
    'delegation':       delegation,
    'quantite':         quantite,
    'statut':           statut,
    'photo_url':        photoUrl,
    'collecteur':       collecteur,
  };
}
