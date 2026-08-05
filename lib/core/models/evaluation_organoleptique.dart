// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/models/evaluation_organoleptique.dart
// PURPOSE : Sensory/organoleptic evaluation — one row per (sample × taster).
//           Matches the `evaluations_organoleptiques` table.
//           UNIQUE constraint: (echantillon_id, tasteur_id) — enforced at DB level.
// ═════════════════════════════════════════════════════════════════════════════

import 'enums.dart';

class EvaluationOrganoleptique {
  final String id;             // UUID PK
  final String echantillonId;  // UUID FK → echantillons
  final String tasteurId;      // UUID FK → users (role = degustateur)
  final String? sessionId;     // UUID FK → sessions_degustation (nullable)

  // ── Denormalized display fields (API annotations — not sent on POST/PUT) ────
  final String? tasteurNom;    // taster's full name — for display in CEO view

  // ── Niveau 1 — catégorie réglementaire COI ────────────────────────────────────
  ClassificationHuile classification;

  // ── Niveau 2 — classe interne PR-48 (§6 : huiles extra vierges uniquement) ────
  ClasseInterne? classeInterne;
  /// Vrai quand la grille §8 ne rendait aucune classe et que le dégustateur
  /// a choisi la sienne.
  bool classeInterneManuelle;
  /// Motif « hors grille » figé au moment du choix (traçabilité §14).
  String? classeInterneMotif;
  String? classeInterneChoisieLe;   // ISO 8601, posé par le serveur
  /// Critère « profil harmonieux » (§8) / « priorité à l'équilibre » (§9),
  /// que le PR-48 ne chiffre pas — c'est le dégustateur qui juge.
  bool profilNonHarmonieux;

  final String soumisLe;       // ISO 8601 — set by the server on submission

  // ── Positive attributes (échelle 0–5 — PR-48) ─────────────────────────────────
  double? fruite;
  TypeFruite typeFruite;
  double? amertume;
  double? piquant;

  // ── Defect attributes (COI scale 0–10; 0 = absent) ────────────────────────────
  double? chome;
  double? moisi;
  double? vinaigre;
  double? gele;
  double? rance;
  double? autresDefaut;
  String? autresDefautNom;

  String? commentaire;

  EvaluationOrganoleptique({
    required this.id,
    required this.echantillonId,
    required this.tasteurId,
    this.sessionId,
    this.tasteurNom,
    required this.classification,
    this.classeInterne,
    this.classeInterneManuelle = false,
    this.classeInterneMotif,
    this.classeInterneChoisieLe,
    this.profilNonHarmonieux = false,
    required this.soumisLe,
    this.fruite,
    this.typeFruite = TypeFruite.vert,
    this.amertume,
    this.piquant,
    this.chome,
    this.moisi,
    this.vinaigre,
    this.gele,
    this.rance,
    this.autresDefaut,
    this.autresDefautNom,
    this.commentaire,
  });

  /// The dominant defect intensity (median of all defect values).
  double get medianeDefauts {
    final vals = [
      chome    ?? 0.0,
      moisi    ?? 0.0,
      vinaigre ?? 0.0,
      gele     ?? 0.0,
      rance    ?? 0.0,
      autresDefaut ?? 0.0,
    ];
    return vals.reduce((a, b) => a > b ? a : b);
  }

  factory EvaluationOrganoleptique.fromJson(Map<String, dynamic> json) =>
      EvaluationOrganoleptique(
        id:              json['id']                as String,
        echantillonId:   json['echantillon_id']    as String,
        tasteurId:       json['tasteur_id']         as String,
        sessionId:       json['session_id']         as String?,
        tasteurNom:      json['tasteur_nom']        as String?,
        classification:  ClassificationHuileX.fromJson(json['classification'] as String),
        classeInterne:   ClasseInterneX.fromJson(json['classe_interne'] as String?),
        classeInterneManuelle:
                         (json['classe_interne_manuelle'] as bool?) ?? false,
        classeInterneMotif:    json['classe_interne_motif']      as String?,
        classeInterneChoisieLe: json['classe_interne_choisie_le'] as String?,
        profilNonHarmonieux:
                         (json['profil_non_harmonieux'] as bool?) ?? false,
        soumisLe:        json['soumis_le']          as String,
        fruite:          (json['fruite']            as num?)?.toDouble(),
        typeFruite:      TypeFruiteX.fromJson(json['type_fruite'] as String?),
        amertume:        (json['amertume']          as num?)?.toDouble(),
        piquant:         (json['piquant']           as num?)?.toDouble(),
        chome:           (json['chome']             as num?)?.toDouble(),
        moisi:           (json['moisi']             as num?)?.toDouble(),
        vinaigre:        (json['vinaigre']          as num?)?.toDouble(),
        gele:            (json['gele']              as num?)?.toDouble(),
        rance:           (json['rance']             as num?)?.toDouble(),
        autresDefaut:    (json['autres_defaut']      as num?)?.toDouble(),
        autresDefautNom: json['autres_defaut_nom']   as String?,
        commentaire:     json['commentaire']         as String?,
      );

  /// For paginated Django list responses: { "count": N, "results": [...] }
  static List<EvaluationOrganoleptique> fromJsonList(Map<String, dynamic> json) =>
      (json['results'] as List)
          .map((e) => EvaluationOrganoleptique.fromJson(e))
          .toList();

  Map<String, dynamic> toJson() => {
    'id':               id,
    'echantillon_id':   echantillonId,
    'tasteur_id':        tasteurId,
    'session_id':        sessionId,
    'classification':   classification.toJson,
    'classe_interne':          classeInterne?.toJson ?? '',
    'classe_interne_manuelle': classeInterneManuelle,
    'classe_interne_motif':    classeInterneMotif ?? '',
    'profil_non_harmonieux':   profilNonHarmonieux,
    'soumis_le':        soumisLe,
    'fruite':           fruite,
    'type_fruite':      typeFruite.toJson,
    'amertume':         amertume,
    'piquant':          piquant,
    'chome':            chome,
    'moisi':            moisi,
    'vinaigre':         vinaigre,
    'gele':             gele,
    'rance':            rance,
    'autres_defaut':    autresDefaut,
    'autres_defaut_nom': autresDefautNom,
    'commentaire':      commentaire,
    // tasteur_nom is a read-only API annotation — not sent on POST/PUT.
  };
}
