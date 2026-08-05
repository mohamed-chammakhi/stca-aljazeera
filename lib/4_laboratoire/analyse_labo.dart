// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/analyse_labo.dart
// PURPOSE : Le rapport d'analyse du laboratoire, tel qu'il est imprimé.
//
// Les 28 valeurs mesurées ne sont plus 28 champs nommés : elles vivent dans
// une table indexée par clé de paramètre. La liste des paramètres, leur ordre
// et leurs seuils sont décrits une seule fois, dans core/analyses/normes_coi.dart.
// Ajouter un paramètre ne touche donc plus ce fichier.
// ═════════════════════════════════════════════════════════════════════════════

import '../core/analyses/normes_coi.dart';
import '../core/models/enums.dart' show StatutLabo, StatutLaboX;

/// Alias kept for callers within this module.
/// All new code should use StatutLabo from core/models/enums.dart directly.
typedef StatutAnalyse = StatutLabo;

class AnalyseLabo {
  String? id;
  String echantillonId;
  String echantillonRef;

  // ── Identification du certificat ──────────────────────────────────────────
  // Ce que porte l'en-tête du rapport papier et que l'échantillon ne connaît
  // pas déjà. L'importateur, la facture et les adresses concernent la vente à
  // l'export, pas la décision d'achat : ils restent sur le papier.
  String? numeroCertificat;
  String? numeroLot;
  String? dateDebutAnalyse; // aaaa-mm-jj
  String? dateFinAnalyse; // aaaa-mm-jj
  int? quantiteMl;

  /// Les 28 valeurs mesurées, par clé de paramètre — voir [kTousParametres].
  final Map<String, double?> valeurs;

  // ── Métadonnées ───────────────────────────────────────────────────────────
  StatutAnalyse statut;
  String? dateAnalyse;
  String? technicienId;
  String? notes;
  String? imageRapportUrl; // photo du rapport papier, conservée comme preuve

  AnalyseLabo({
    this.id,
    required this.echantillonId,
    required this.echantillonRef,
    Map<String, double?>? valeurs,
    this.numeroCertificat,
    this.numeroLot,
    this.dateDebutAnalyse,
    this.dateFinAnalyse,
    this.quantiteMl,
    this.statut = StatutAnalyse.enAttente,
    this.dateAnalyse,
    this.technicienId,
    this.notes,
    this.imageRapportUrl,
  }) : valeurs = {...?valeurs};

  double? valeur(String cle) => valeurs[cle];

  // Raccourcis vers les quatre grandeurs qui décident du classement. Ce sont
  // les seules lues ailleurs dans l'app.
  double? get aciditeLibre => valeurs['acidite'];
  double? get indicePeroxyde => valeurs['indice_peroxyde'];
  double? get k232 => valeurs['k232'];
  double? get k270 => valeurs['k270'];

  /// Classement COI déduit des valeurs. `null` tant que les quatre grandeurs
  /// obligatoires ne sont pas toutes renseignées.
  String? get classification => classificationCoi(valeurs);

  /// Ce qu'affiche un écran : le classement, ou un tiret s'il est indécidable.
  /// Les paramètres saisis qui sortent de la norme COI.
  ///
  /// Une valeur peut sortir de la norme sans que le classement change —
  /// c'est le cas des stérols et des acides gras, qui trahissent un mélange
  /// plutôt qu'une dégradation. C'est ce qui déclenche l'alerte au directeur.
  List<ParametreAnalyse> get horsNormes => parametresHorsNormes(valeurs);

  bool get isComplete =>
      kParametresObligatoires.every((cle) => valeurs[cle] != null);

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return lireDecimal(value);
    return null;
  }

  static int? _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static StatutAnalyse _statutFromJson(dynamic value) {
    final raw = value as String? ?? 'en_attente';
    switch (raw) {
      case 'enAttente':
        return StatutAnalyse.enAttente;
      case 'enCours':
        return StatutAnalyse.enCours;
      default:
        try {
          return StatutLaboX.fromJson(raw);
        } catch (_) {
          return StatutAnalyse.enAttente;
        }
    }
  }

  factory AnalyseLabo.fromJson(Map<String, dynamic> json) => AnalyseLabo(
    id: json['id'] as String?,
    echantillonId:
        (json['echantillon_id'] ?? json['echantillon'] ?? '') as String,
    echantillonRef: (json['echantillon_ref'] ?? '') as String,
    valeurs: {
      for (final p in kTousParametres)
        // 'acidite_libre' est l'ancien nom du même champ, encore renvoyé par
        // l'API à côté de 'acidite'.
        p.cle: _double(
          p.cle == 'acidite'
              ? (json['acidite'] ?? json['acidite_libre'])
              : json[p.cle],
        ),
    },
    numeroCertificat: json['numero_certificat'] as String?,
    numeroLot: json['numero_lot'] as String?,
    dateDebutAnalyse: json['date_debut_analyse'] as String?,
    dateFinAnalyse: json['date_fin_analyse'] as String?,
    quantiteMl: _int(json['quantite_ml']),
    statut: _statutFromJson(json['statut']),
    dateAnalyse: json['date_analyse'] as String?,
    technicienId: json['technicien_id'] as String?,
    notes: json['notes'] as String?,
    imageRapportUrl: (json['image_rapport_url'] ?? json['photo']) as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'echantillon': echantillonId,
    'echantillon_id': echantillonId,
    'echantillon_ref': echantillonRef,
    for (final p in kTousParametres) p.cle: valeurs[p.cle],
    'numero_certificat': numeroCertificat,
    'numero_lot': numeroLot,
    'date_debut_analyse': dateDebutAnalyse,
    'date_fin_analyse': dateFinAnalyse,
    'quantite_ml': quantiteMl,
    'statut': statut.toJson,
    'date_analyse': dateAnalyse,
    'technicien_id': technicienId,
    'notes': notes,
    'image_rapport_url': imageRapportUrl,
    // 'classification' n'est pas envoyé : le serveur le déduit des valeurs.
  };
}
