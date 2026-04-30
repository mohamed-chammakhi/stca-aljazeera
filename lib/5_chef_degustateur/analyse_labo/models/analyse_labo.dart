// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/models/analyse_labo.dart
// PURPOSE : data model for one laboratoire analysis linked to an echantillon
// ═════════════════════════════════════════════════════════════════════════════

// ── Statut enum ───────────────────────────────────────────────────────────────
enum StatutAnalyse { enAttente, soumise }

// ── Résultat d'un critère (label + valeur + unité + conformité) ───────────────
class CritereAnalyse {
  final String label; // ex: "Acidité libre"
  double valeur; // ex: 0.3
  final String unite; // ex: "%" or "mEq O2/kg"
  final double? seuilMin; // null = pas de seuil min
  final double? seuilMax; // null = pas de seuil max

  CritereAnalyse({
    required this.label,
    required this.valeur,
    required this.unite,
    this.seuilMin,
    this.seuilMax,
  });

  factory CritereAnalyse.fromJson(Map<String, dynamic> json) => CritereAnalyse(
    label: json['label'] as String,
    valeur: (json['valeur'] as num).toDouble(),
    unite: json['unite'] as String,
    seuilMin: json['seuil_min'] != null ? (json['seuil_min'] as num).toDouble() : null,
    seuilMax: json['seuil_max'] != null ? (json['seuil_max'] as num).toDouble() : null,
  );

  Map<String, dynamic> toJson() => {
    'label': label,
    'valeur': valeur,
    'unite': unite,
    'seuil_min': seuilMin,
    'seuil_max': seuilMax,
  };

  /// true if value is within allowed range
  bool get conforme {
    if (seuilMin != null && valeur < seuilMin!) return false;
    if (seuilMax != null && valeur > seuilMax!) return false;
    return true;
  }
}

// ── Main model ────────────────────────────────────────────────────────────────
class AnalyseLabo {
  final String id;
  String echantillonId; // linked echantillon ID
  String echantillonNom; // display name for the echantillon
  String dateAnalyse; // DD/MM/YYYY
  String technicienNom; // who performed the analysis
  StatutAnalyse statut;
  String? notes;

  // the list of criteria + their values
  List<CritereAnalyse> criteres;

  AnalyseLabo({
    required this.id,
    required this.echantillonId,
    required this.echantillonNom,
    required this.dateAnalyse,
    required this.technicienNom,
    required this.statut,
    required this.criteres,
    this.notes,
  });

  factory AnalyseLabo.fromJson(Map<String, dynamic> json) => AnalyseLabo(
    id: json['id'] as String,
    echantillonId: json['echantillon_id'] as String,
    echantillonNom: json['echantillon_nom'] as String,
    dateAnalyse: json['date_analyse'] as String,
    technicienNom: json['technicien_nom'] as String,
    statut: json['statut'] == 'soumise' ? StatutAnalyse.soumise : StatutAnalyse.enAttente,
    criteres: (json['criteres'] as List).map((c) => CritereAnalyse.fromJson(c as Map<String, dynamic>)).toList(),
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'echantillon_id': echantillonId,
    'echantillon_nom': echantillonNom,
    'date_analyse': dateAnalyse,
    'technicien_nom': technicienNom,
    'statut': statut == StatutAnalyse.soumise ? 'soumise' : 'en_attente',
    'criteres': criteres.map((c) => c.toJson()).toList(),
    'notes': notes,
  };

  /// true if ALL criteria are within their allowed range
  bool get toutConforme => criteres.every((c) => c.conforme);

  /// count of non-conforming criteria
  int get nbNonConformes => criteres.where((c) => !c.conforme).length;
}

// ── Default criteria template for olive oil (IOC/COI norms) ──────────────────
// Used when creating a new analysis — values are set to 0.0 initially
List<CritereAnalyse> criteresDefaut() => [
  CritereAnalyse(
    label: 'Acidité libre',
    valeur: 0.0,
    unite: '%',
    seuilMin: 0.0,
    seuilMax: 0.8, // ≤ 0.8% → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'Indice de peroxyde',
    valeur: 0.0,
    unite: 'mEq O₂/kg',
    seuilMin: 0.0,
    seuilMax: 20.0, // ≤ 20 mEq O₂/kg → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'Absorbance K232',
    valeur: 0.0,
    unite: '',
    seuilMin: 0.0,
    seuilMax: 2.50, // ≤ 2.50 → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'Absorbance K270',
    valeur: 0.0,
    unite: '',
    seuilMin: 0.0,
    seuilMax: 0.22, // ≤ 0.22 → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'ΔK (variation UV)',
    valeur: 0.0,
    unite: '',
    seuilMin: -0.01,
    seuilMax: 0.01, // |ΔK| ≤ 0.01 → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'Polyphénols totaux',
    valeur: 0.0,
    unite: 'mg/kg',
    seuilMin: 0.0,
    seuilMax: null, // pas de seuil max — informatif
  ),
  CritereAnalyse(
    label: 'Humidité',
    valeur: 0.0,
    unite: '%',
    seuilMin: 0.0,
    seuilMax: 0.2, // ≤ 0.2% → Extra vierge (COI)
  ),
  CritereAnalyse(
    label: 'Impuretés',
    valeur: 0.0,
    unite: '%',
    seuilMin: 0.0,
    seuilMax: 0.1, // ≤ 0.1% → Extra vierge (COI)
  ),
];
