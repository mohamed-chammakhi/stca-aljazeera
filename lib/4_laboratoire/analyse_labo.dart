// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/models/analyse_labo.dart
// PURPOSE : Core data model for a laboratory analysis report
// ═════════════════════════════════════════════════════════════════════════════

import '../core/models/enums.dart' show StatutLabo, StatutLaboX;

/// Alias kept for callers within this module.
/// All new code should use StatutLabo from core/models/enums.dart directly.
typedef StatutAnalyse = StatutLabo;

class AnalyseLabo {
  String? id;
  String echantillonId;
  String echantillonRef;

  // ── Physicochemical parameters (COI / IOC standard) ──────────────────────
  double? aciditeLibre; // Free acidity (%  oleic acid) — max 0.8 for EV
  double? indicePeroxyde; // Peroxide value (meqO2/kg)    — max 20 for EV
  double? k232; // UV absorbance K232            — max 2.50 for EV
  double? k270; // UV absorbance K270            — max 0.22 for EV
  double? deltaK; // Delta-K                       — max 0.01 for EV
  double? humidite; // Moisture & volatiles (%)      — max 0.2
  double? impuretes; // Insoluble impurities (%)      — max 0.1
  double? polyphenolsTotaux; // Total polyphenols (mg/kg) — quality indicator
  double? tocopherols; // Tocopherols (mg/kg)       — quality indicator

  // ── Fatty acid profile (optional advanced panel) ──────────────────────────
  double? acideOleique; // Oleic acid C18:1 (%)  — 55–83 normal range
  double? acideLinoleique; // Linoleic acid C18:2 (%)
  double? acidePalmitique; // Palmitic acid C16:0 (%)

  // ── Classification result (auto-computed) ─────────────────────────────────
  String? classification; // "Extra Vierge" / "Vierge" / "Lampante"

  // ── Metadata ──────────────────────────────────────────────────────────────
  StatutAnalyse statut;
  String? dateAnalyse;
  String? technicienId;
  String? notes;
  String? imageRapportUrl; // photo of scanned paper report (optional)

  AnalyseLabo({
    this.id,
    required this.echantillonId,
    required this.echantillonRef,
    this.aciditeLibre,
    this.indicePeroxyde,
    this.k232,
    this.k270,
    this.deltaK,
    this.humidite,
    this.impuretes,
    this.polyphenolsTotaux,
    this.tocopherols,
    this.acideOleique,
    this.acideLinoleique,
    this.acidePalmitique,
    this.classification,
    this.statut = StatutAnalyse.enAttente,
    this.dateAnalyse,
    this.technicienId,
    this.notes,
    this.imageRapportUrl,
  });

  // ── Auto-classify based on COI norms ─────────────────────────────────────
  String get classificationAuto {
    if (aciditeLibre == null || indicePeroxyde == null) return '—';
    if (aciditeLibre! <= 0.8 &&
        indicePeroxyde! <= 20 &&
        (k270 == null || k270! <= 0.22) &&
        (k232 == null || k232! <= 2.50)) {
      return 'Extra Vierge';
    } else if (aciditeLibre! <= 2.0 && indicePeroxyde! <= 20) {
      return 'Vierge';
    } else {
      return 'Lampante';
    }
  }

  bool get isComplete =>
      aciditeLibre != null &&
      indicePeroxyde != null &&
      k270 != null &&
      k232 != null;

  static double? _double(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
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
    aciditeLibre: _double(json['acidite_libre'] ?? json['acidite']),
    indicePeroxyde: _double(json['indice_peroxyde']),
    k232: _double(json['k232']),
    k270: _double(json['k270']),
    deltaK: _double(json['delta_k']),
    humidite: _double(json['humidite']),
    impuretes: _double(json['impuretes']),
    polyphenolsTotaux: _double(json['polyphenols_totaux']),
    tocopherols: _double(json['tocopherols']),
    acideOleique: _double(json['acide_oleique']),
    acideLinoleique: _double(json['acide_linoleique']),
    acidePalmitique: _double(json['acide_palmitique']),
    classification: json['classification'] as String?,
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
    'acidite': aciditeLibre,
    'acidite_libre': aciditeLibre,
    'indice_peroxyde': indicePeroxyde,
    'k232': k232,
    'k270': k270,
    'delta_k': deltaK,
    'humidite': humidite,
    'impuretes': impuretes,
    'polyphenols_totaux': polyphenolsTotaux,
    'tocopherols': tocopherols,
    'acide_oleique': acideOleique,
    'acide_linoleique': acideLinoleique,
    'acide_palmitique': acidePalmitique,
    'classification': classification,
    'statut': statut.toJson,
    'date_analyse': dateAnalyse,
    'technicien_id': technicienId,
    'notes': notes,
    'image_rapport_url': imageRapportUrl,
  };
}
