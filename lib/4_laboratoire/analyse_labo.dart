// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/models/analyse_labo.dart
// PURPOSE : Core data model for a laboratory analysis report
// ═════════════════════════════════════════════════════════════════════════════

enum StatutAnalyse { enAttente, enCours, soumis }

class AnalyseLabo {
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
}
