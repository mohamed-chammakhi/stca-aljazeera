// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/fournisseur.dart
// PURPOSE : Supplier model — matches the `fournisseurs` table.
//           Moved to core/ because the CEO and collector both need it.
//           The file at 2_collecteur/models/fournisseur.dart is now deprecated;
//           import from here instead.
// ═════════════════════════════════════════════════════════════════════════════

class Fournisseur {
  final String id;               // UUID PK
  String codeFournisseur;        // unique short code, e.g. "SF-42"
  String nom;
  String? region;
  String? telephone;
  String? email;
  String? adresse;
  String? notes;
  String? datePremiereContact;   // ISO 8601 date
  // Read-only counters — computed by the backend, not sent on POST/PUT.
  final int nbEchantillonsSoumis;
  final int nbAchatsConfirmes;

  Fournisseur({
    required this.id,
    required this.codeFournisseur,
    required this.nom,
    this.region,
    this.telephone,
    this.email,
    this.adresse,
    this.notes,
    this.datePremiereContact,
    this.nbEchantillonsSoumis = 0,
    this.nbAchatsConfirmes    = 0,
  });

  /// Conversion rate: % of submitted samples that resulted in a confirmed purchase.
  double get tauxConversion => nbEchantillonsSoumis == 0
      ? 0
      : (nbAchatsConfirmes / nbEchantillonsSoumis) * 100;

  factory Fournisseur.fromJson(Map<String, dynamic> json) => Fournisseur(
    id:                    json['id']                     as String,
    codeFournisseur:       json['code_fournisseur']       as String,
    nom:                   json['nom']                    as String,
    region:                json['region']                 as String?,
    telephone:             json['telephone']              as String?,
    email:                 json['email']                  as String?,
    adresse:               json['adresse']                as String?,
    notes:                 json['notes']                  as String?,
    datePremiereContact:   json['date_premiere_contact']  as String?,
    nbEchantillonsSoumis:  (json['nb_echantillons_soumis'] as int?) ?? 0,
    nbAchatsConfirmes:     (json['nb_achats_confirmes']    as int?) ?? 0,
  );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<Fournisseur> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => Fournisseur.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id':                   id,
    'code_fournisseur':     codeFournisseur,
    'nom':                  nom,
    'region':               region,
    'telephone':            telephone,
    'email':                email,
    'adresse':              adresse,
    'notes':                notes,
    'date_premiere_contact': datePremiereContact,
    // nb_echantillons_soumis and nb_achats_confirmes are read-only counters
    // computed by the backend — not sent on POST/PUT.
  };
}
