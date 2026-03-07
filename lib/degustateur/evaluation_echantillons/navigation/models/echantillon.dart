// ─────────────────────────────────────────────────────────────────────────────
// FILE : evaluation_echantillons/models/echantillon.dart
// PURPOSE : data model for one échantillon in the evaluation list
// ─────────────────────────────────────────────────────────────────────────────

// enum StatutEchantillon
// → enum = enumeration : a fixed set of named values
// → instead of storing statut as a String like 'En attente'
//   we use an enum so the compiler catches typos at compile time
// → StatutEchantillon.enAttente is safer than 'En attente' (no typo risk)
enum StatutEchantillon { enAttente, enCours, soumis }

class Echantillon {
  final String id; // unique code ex: OL-2024-001
  final String ref;
  final String fournisseur; // supplier name
  final String date; // registration date
  final String variete; // olive variety
  final String? origine; // region — optional (? = can be null)
  final String? photoUrl; // photo URL — optional
  StatutEchantillon
  statut; // not final — statut can change (enAttente → enCours)

  Echantillon({
    required this.id,
    required this.ref,
    required this.fournisseur,
    required this.date,
    required this.variete,
    this.origine, // optional — no required keyword
    this.photoUrl, // optional
    required this.statut,
  });

  // fromJson — used later when Spring Boot sends data
  // factory : special constructor that returns an instance of the class
  factory Echantillon.fromJson(Map<String, dynamic> json) {
    return Echantillon(
      id: json['id'],
      ref: json['ref'],
      fournisseur: json['fournisseur'],
      date: json['dateArrivee'],
      variete: json['variete'],
      origine: json['origine'],
      photoUrl: json['photoUrl'],
      statut: _parseStatut(json['statut']),
    );
  }

  // _parseStatut : converts a String from JSON into a StatutEchantillon enum value
  static StatutEchantillon _parseStatut(String s) {
    switch (s) {
      case 'EN_COURS':
        return StatutEchantillon.enCours;
      case 'SOUMIS':
        return StatutEchantillon.soumis;
      default:
        return StatutEchantillon.enAttente;
    }
  }
}
