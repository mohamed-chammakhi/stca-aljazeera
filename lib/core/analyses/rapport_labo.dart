import 'normes_coi.dart';

/// Un rapport d'analyse tel qu'il est lu — jamais écrit par les rôles qui le
/// consultent. Le laboratoire reste l'unique propriétaire du chemin d'écriture.
class RapportLabo {
  /// Les 28 valeurs mesurées, indexées par les clés de [kTousParametres].
  final Map<String, double?> valeurs;
  final String? numeroCertificat;
  final String? numeroLot;
  final String? dateAnalyse;
  final String? notes;

  const RapportLabo({
    this.valeurs = const {},
    this.numeroCertificat,
    this.numeroLot,
    this.dateAnalyse,
    this.notes,
  });

  double? valeur(String cle) => valeurs[cle];

  String? get classification => classificationCoi(valeurs);

  String get classificationAuto => classification ?? '—';

  List<ParametreAnalyse> get horsNormes => parametresHorsNormes(valeurs);

  bool get estVide => valeurs.values.every((v) => v == null);

  factory RapportLabo.fromJson(Map<String, dynamic> json) {
    return RapportLabo(
      valeurs: {
        for (final parametre in kTousParametres)
          parametre.cle: _lireValeur(
            parametre.cle == 'acidite'
                ? (json['acidite'] ?? json['acidite_libre'])
                : json[parametre.cle],
          ),
      },
      numeroCertificat: json['numero_certificat'] as String?,
      numeroLot: json['numero_lot'] as String?,
      dateAnalyse: _formaterDate(json['date_analyse']),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    for (final parametre in kTousParametres)
      parametre.cle: valeurs[parametre.cle],
    'numero_certificat': numeroCertificat,
    'numero_lot': numeroLot,
    'date_analyse': dateAnalyse,
    'notes': notes,
  };

  static double? _lireValeur(dynamic valeur) {
    if (valeur is num) return valeur.toDouble();
    if (valeur is String) return lireDecimal(valeur);
    return null;
  }

  static String? _formaterDate(dynamic valeur) {
    if (valeur == null) return null;
    final texte = valeur.toString();
    final date = DateTime.tryParse(texte);
    if (date == null) return texte;
    final jour = date.day.toString().padLeft(2, '0');
    final mois = date.month.toString().padLeft(2, '0');
    return '$jour/$mois/${date.year}';
  }
}
