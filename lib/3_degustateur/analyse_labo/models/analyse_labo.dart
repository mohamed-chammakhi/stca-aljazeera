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

  // Sample detail fields — populated from linked Echantillon for display
  final String? fournisseurNom;
  final String? gouvernorat;
  final String? delegation;
  final String? collecteurNom;
  final String? variete;
  final String? quantiteEstimee;

  // Dates for filtering — DD/MM/YYYY format
  final String? dateEnregistrement;   // sample registration date
  final String? dateReceptionPhysique; // date sample physically arrived

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
    this.fournisseurNom,
    this.gouvernorat,
    this.delegation,
    this.collecteurNom,
    this.variete,
    this.quantiteEstimee,
    this.dateEnregistrement,
    this.dateReceptionPhysique,
  });

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
