// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/models/echantillon.dart
// PURPOSE : data model for one échantillon in the evaluation list
// ─────────────────────────────────────────────────────────────────────────────

enum StatutEchantillon { enAttente, enCours, soumis }

class Echantillon {
  final String id;
  final String ref;
  final String fournisseur;
  final String date;
  final String variete;
  final String? gouvernorat;  // Tunisian governorate (replaces origine)
  final String? delegation;   // sub-region — optional, cascades from gouvernorat
  final String? photoUrl;
  final String? quantite;     // quantity in tonnes
  final String? collecteur;   // collector name — optional
  StatutEchantillon statut;   // not final — statut can change
  String? classification;     // set when soumis (e.g. 'Extra Vierge', 'Vierge')

  Echantillon({
    required this.id,
    required this.ref,
    required this.fournisseur,
    required this.date,
    required this.variete,
    this.gouvernorat,
    this.delegation,
    this.photoUrl,
    this.quantite,
    this.collecteur,
    required this.statut,
    this.classification,
  });

  factory Echantillon.fromJson(Map<String, dynamic> json) {
    return Echantillon(
      id:             json['id']             as String,
      ref:            json['ref']            as String,
      fournisseur:    json['fournisseur']    as String,
      date:           json['date_arrivee']   as String,
      variete:        json['variete']        as String,
      gouvernorat:    json['gouvernorat']    as String?,
      delegation:     json['delegation']     as String?,
      photoUrl:       json['photo_url']      as String?,
      quantite:       json['quantite']       as String?,
      collecteur:     json['collecteur']     as String?,
      statut:         _parseStatut(json['statut'] as String),
      classification: json['classification'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'ref':            ref,
    'fournisseur':    fournisseur,
    'date_arrivee':   date,
    'variete':        variete,
    'gouvernorat':    gouvernorat,
    'delegation':     delegation,
    'photo_url':      photoUrl,
    'quantite':       quantite,
    'collecteur':     collecteur,
    'statut':         _statutToString(statut),
    'classification': classification,
  };

  static StatutEchantillon _parseStatut(String s) {
    switch (s) {
      case 'EN_COURS': return StatutEchantillon.enCours;
      case 'SOUMIS':   return StatutEchantillon.soumis;
      default:         return StatutEchantillon.enAttente;
    }
  }

  static String _statutToString(StatutEchantillon s) {
    switch (s) {
      case StatutEchantillon.enCours: return 'EN_COURS';
      case StatutEchantillon.soumis:  return 'SOUMIS';
      default:                        return 'EN_ATTENTE';
    }
  }
}
