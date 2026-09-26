// =============================================================================
// FILE    : core/models/fournisseur.dart
// PURPOSE : Supplier model, shared by every role that reads supplier data.
// =============================================================================

class Fournisseur {
  final String id; // UUID PK
  String nom;
  String? region;
  String? delegation;
  String? telephone;
  String? email;
  String? adresse;
  String? notes;
  String? datePremiereContact; // ISO 8601 date
  final int nbEchantillonsSoumis;
  final int nbAchatsConfirmes;

  Fournisseur({
    required this.id,
    required this.nom,
    this.region,
    this.delegation,
    this.telephone,
    this.email,
    this.adresse,
    this.notes,
    this.datePremiereContact,
    this.nbEchantillonsSoumis = 0,
    this.nbAchatsConfirmes = 0,
  });

  double get tauxConversion => nbEchantillonsSoumis == 0
      ? 0
      : (nbAchatsConfirmes / nbEchantillonsSoumis) * 100;

  factory Fournisseur.fromJson(Map<String, dynamic> json) => Fournisseur(
    id: json['id'] as String,
    nom: json['nom'] as String,
    region: json['region'] as String?,
    delegation: json['delegation'] as String?,
    telephone: json['telephone'] as String?,
    email: json['email'] as String?,
    adresse: json['adresse'] as String?,
    notes: json['notes'] as String?,
    datePremiereContact: json['date_premiere_contact'] as String?,
    nbEchantillonsSoumis: (json['nb_echantillons_soumis'] as int?) ?? 0,
    nbAchatsConfirmes: (json['nb_achats_confirmes'] as int?) ?? 0,
  );

  static List<Fournisseur> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => Fournisseur.fromJson(e as Map<String, dynamic>))
          .toList();

  Map<String, dynamic> toJson() => {
    'id': id,
    'nom': nom,
    'region': region,
    'delegation': delegation,
    'telephone': telephone,
    'email': email,
    'adresse': adresse,
    'notes': notes,
    'date_premiere_contact': datePremiereContact,
  };
}

String libelleFournisseur(Fournisseur fournisseur) {
  final nom = fournisseur.nom.trim();
  final region = fournisseur.region?.trim() ?? '';
  final delegation = fournisseur.delegation?.trim() ?? '';

  if (region.isEmpty) return nom;
  if (delegation.isEmpty) return '$nom — $region';
  return '$nom — $region ($delegation)';
}
