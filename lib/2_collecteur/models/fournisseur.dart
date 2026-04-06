// ═════════════════════════════════════════════════════════════════════════════
// FILE    : collecteur/models/fournisseur.dart
// PURPOSE : supplier data model — independent from echantillon
//           survives even if all echantillons are deleted
// ═════════════════════════════════════════════════════════════════════════════

class Fournisseur {
  final String id;
  String       nom;
  String       region;
  String?      telephone;
  String?      email;
  String?      adresse;
  String?      notes;
  final String datePremiereContact; // DD/MM/YYYY
  int          nbEchantillonsSoumis;
  int          nbAchatsConfirmes;

  Fournisseur({
    required this.id,
    required this.nom,
    required this.region,
    required this.datePremiereContact,
    this.telephone,
    this.email,
    this.adresse,
    this.notes,
    this.nbEchantillonsSoumis = 0,
    this.nbAchatsConfirmes    = 0,
  });

  double get tauxConversion => nbEchantillonsSoumis == 0
      ? 0
      : (nbAchatsConfirmes / nbEchantillonsSoumis) * 100;
}
