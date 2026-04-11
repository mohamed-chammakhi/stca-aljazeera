// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/analyse_labo.dart
// PURPOSE : Laboratory analysis model — matches `analyses_labo` +
//           `criteres_analyse` tables.
//
//           Design: criteria are stored as separate rows in `criteres_analyse`
//           (not as named columns). This allows adding/removing COI parameters
//           without a schema migration.
//
//           The `classificationAuto` getter computes the COI classification
//           from named criteria by label lookup — no hardcoded column names.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

// ── Criterion (one row in criteres_analyse) ───────────────────────────────────
class CritereAnalyse {
  final String id;        // UUID PK (set by backend; empty string for new entries)
  final String analyseId; // UUID FK → analyses_labo
  final String label;     // e.g. "Acidité libre"
  double valeur;          // measured value (mutable — user fills it in)
  final String? unite;    // e.g. "%" or "mEq O₂/kg"
  final double? seuilMin; // null = no lower bound
  final double? seuilMax; // null = no upper bound
  // NOTE: `conforme` is a GENERATED ALWAYS column in PostgreSQL.
  // It is never sent in POST/PUT — only read from GET responses.
  final bool? conforme;   // null until the backend computes it

  CritereAnalyse({
    required this.id,
    required this.analyseId,
    required this.label,
    required this.valeur,
    this.unite,
    this.seuilMin,
    this.seuilMax,
    this.conforme,
  });

  /// Local conformity check — mirrors the DB generated column logic.
  bool get conformeLocal {
    if (seuilMin != null && valeur < seuilMin!) return false;
    if (seuilMax != null && valeur > seuilMax!) return false;
    return true;
  }

  factory CritereAnalyse.fromJson(Map<String, dynamic> json) => CritereAnalyse(
    id:        json['id']         as String,
    analyseId: json['analyse_id'] as String,
    label:     json['label']      as String,
    valeur:    (json['valeur']    as num).toDouble(),
    unite:     json['unite']      as String?,
    seuilMin:  (json['seuil_min'] as num?)?.toDouble(),
    seuilMax:  (json['seuil_max'] as num?)?.toDouble(),
    conforme:  json['conforme']   as bool?,
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'analyse_id': analyseId,
    'label':      label,
    'valeur':     valeur,
    'unite':      unite,
    'seuil_min':  seuilMin,
    'seuil_max':  seuilMax,
    // 'conforme' is omitted — it is a DB generated column, never sent.
  };
}

// ── Main analysis model ───────────────────────────────────────────────────────
class AnalyseLabo {
  final String id;              // UUID PK
  final String echantillonId;   // UUID FK → echantillons
  final String technicienId;    // UUID FK → users (role = laboratoire)

  // ── Denormalized display fields (API annotations — not sent on POST/PUT) ────
  final String? echantillonRef;  // e.g. "2026/0001"
  final String? technicienNom;

  String? dateAnalyse;          // ISO 8601 date
  StatutLabo statut;
  String? notes;
  String? photoUrl;              // uploaded photo of the paper analysis report
  String? numeroLot;             // internal lab lot number
  String? origineCampagne;       // harvest campaign, e.g. "2025/2026"
  PrioriteAnalyse priorite;
  String? notesReception;        // observations on reception (seal condition, etc.)
  String? submittedAt;           // ISO 8601 — set by server on submission

  final String createdAt;        // ISO 8601

  List<CritereAnalyse> criteres;

  AnalyseLabo({
    required this.id,
    required this.echantillonId,
    required this.technicienId,
    this.echantillonRef,
    this.technicienNom,
    this.dateAnalyse,
    this.statut = StatutLabo.enAttente,
    this.notes,
    this.photoUrl,
    this.numeroLot,
    this.origineCampagne,
    this.priorite = PrioriteAnalyse.normale,
    this.notesReception,
    this.submittedAt,
    required this.createdAt,
    this.criteres = const [],
  });

  bool get isUrgent     => priorite == PrioriteAnalyse.urgente;
  bool get toutConforme => criteres.every((c) => c.conformeLocal);
  int  get nbNonConformes => criteres.where((c) => !c.conformeLocal).length;

  bool get isComplete =>
      criteres.any((c) => c.label == 'Acidité libre' && c.valeur > 0) &&
      criteres.any((c) => c.label == 'Indice de peroxyde' && c.valeur > 0) &&
      criteres.any((c) => c.label == 'Absorbance K270' && c.valeur > 0) &&
      criteres.any((c) => c.label == 'Absorbance K232' && c.valeur > 0);

  /// Auto-classify based on COI/IOC norms using the criteria list.
  String get classificationAuto {
    double? val(String label) =>
        criteres.where((c) => c.label == label).firstOrNull?.valeur;

    final acidite = val('Acidité libre');
    final peroxyde = val('Indice de peroxyde');
    if (acidite == null || peroxyde == null) return '—';

    final k270 = val('Absorbance K270');
    final k232 = val('Absorbance K232');

    if (acidite <= 0.8 &&
        peroxyde <= 20 &&
        (k270 == null || k270 <= 0.22) &&
        (k232 == null || k232 <= 2.50)) {
      return 'Extra Vierge';
    } else if (acidite <= 2.0 && peroxyde <= 20) {
      return 'Vierge';
    } else {
      return 'Lampante';
    }
  }

  factory AnalyseLabo.fromJson(Map<String, dynamic> json) => AnalyseLabo(
    id:              json['id']              as String,
    echantillonId:   json['echantillon_id']  as String,
    technicienId:    json['technicien_id']   as String,
    echantillonRef:  json['echantillon_ref'] as String?,
    technicienNom:   json['technicien_nom']  as String?,
    dateAnalyse:     json['date_analyse']    as String?,
    statut:          StatutLaboX.fromJson(json['statut'] as String),
    notes:           json['notes']           as String?,
    photoUrl:        json['photo_url']       as String?,
    numeroLot:       json['numero_lot']      as String?,
    origineCampagne: json['origine_campagne'] as String?,
    priorite:        json['priorite'] != null
                       ? PrioriteAnalyseX.fromJson(json['priorite'] as String)
                       : PrioriteAnalyse.normale,
    notesReception:  json['notes_reception'] as String?,
    submittedAt:     json['submitted_at']    as String?,
    createdAt:       json['created_at']      as String,
    criteres:        (json['criteres'] as List?)
                         ?.map((c) => CritereAnalyse.fromJson(c))
                         .toList() ?? [],
  );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<AnalyseLabo> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List).map((e) => AnalyseLabo.fromJson(e)).toList();

  Map<String, dynamic> toJson() => {
    'id':               id,
    'echantillon_id':   echantillonId,
    'technicien_id':    technicienId,
    'date_analyse':     dateAnalyse,
    'statut':           statut.toJson,
    'notes':            notes,
    'photo_url':        photoUrl,
    'numero_lot':       numeroLot,
    'origine_campagne': origineCampagne,
    'priorite':         priorite.toJson,
    'notes_reception':  notesReception,
    'submitted_at':     submittedAt,
    'created_at':       createdAt,
    'criteres':         criteres.map((c) => c.toJson()).toList(),
    // echantillon_ref and technicien_nom are read-only API annotations.
  };
}

// ── Default COI criteria template ────────────────────────────────────────────
// Used when creating a new analysis. Values start at 0.0.
// The `id` and `analyseId` are empty strings here — the backend assigns them.
List<CritereAnalyse> criteresDefaut() => [
  CritereAnalyse(id: '', analyseId: '', label: 'Acidité libre',      valeur: 0.0, unite: '%',           seuilMin: 0.0, seuilMax: 0.8),
  CritereAnalyse(id: '', analyseId: '', label: 'Indice de peroxyde', valeur: 0.0, unite: 'mEq O₂/kg',  seuilMin: 0.0, seuilMax: 20.0),
  CritereAnalyse(id: '', analyseId: '', label: 'Absorbance K232',    valeur: 0.0, unite: '',            seuilMin: 0.0, seuilMax: 2.50),
  CritereAnalyse(id: '', analyseId: '', label: 'Absorbance K270',    valeur: 0.0, unite: '',            seuilMin: 0.0, seuilMax: 0.22),
  CritereAnalyse(id: '', analyseId: '', label: 'ΔK (variation UV)',  valeur: 0.0, unite: '',            seuilMin: -0.01, seuilMax: 0.01),
  CritereAnalyse(id: '', analyseId: '', label: 'Polyphénols totaux', valeur: 0.0, unite: 'mg/kg',       seuilMin: 0.0, seuilMax: null),
  CritereAnalyse(id: '', analyseId: '', label: 'Humidité',           valeur: 0.0, unite: '%',           seuilMin: 0.0, seuilMax: 0.2),
  CritereAnalyse(id: '', analyseId: '', label: 'Impuretés',          valeur: 0.0, unite: '%',           seuilMin: 0.0, seuilMax: 0.1),
];
