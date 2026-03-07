// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/models/echantillon_gestion.dart
// PURPOSE : defines what an EchantillonGestion IS — data only, no design
// ─────────────────────────────────────────────────────────────────────────────

class EchantillonGestion {
  String id;
  String ref;
  String fournisseur;
  String variete;
  String dateArrivee;
  String origine;
  String quantite;
  String statut;
  String? photoUrl;

  EchantillonGestion({
    required this.id,
    required this.ref,
    required this.fournisseur,
    required this.variete,
    required this.dateArrivee,
    required this.origine,
    required this.quantite,
    required this.statut,
    this.photoUrl,
  });

  // Used later when Spring Boot sends JSON data
  // Example JSON : {"id": "OL-2024-001", "fournisseur": "Domaine Bel-Air", ...}
  factory EchantillonGestion.fromJson(Map<String, dynamic> json) {
    return EchantillonGestion(
      id: json['id'],
      ref: json['ref'],
      fournisseur: json['fournisseur'],
      variete: json['variete'],
      dateArrivee: json['dateArrivee'],
      origine: json['origine'],
      quantite: json['quantite'],
      statut: json['statut'],
      photoUrl: json['photoUrl'],
    );
  }
}
