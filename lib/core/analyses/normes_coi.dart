// ═════════════════════════════════════════════════════════════════════════════
// FILE : core/analyses/normes_coi.dart
//
// Les 28 paramètres du rapport d'analyse, dans l'ordre exact où ils sont
// imprimés, avec les seuils du Conseil oléicole international pour l'huile
// d'olive extra vierge.
//
// ⚠️ Le rapport papier n'imprime AUCUNE norme : il ne donne que les valeurs
// mesurées. Les seuils ci-dessous viennent donc de la norme COI, pas du
// document. C'est ce fichier — et lui seul — qu'il faut corriger si le
// laboratoire en rectifie un.
//
// Miroir Python : backend_new/analyses/normes_coi.py — les clés doivent rester
// identiques des deux côtés.
// ═════════════════════════════════════════════════════════════════════════════

/// Un paramètre mesuré du rapport.
class ParametreAnalyse {
  /// Clé technique — identique en base, dans le JSON et dans le miroir Python.
  final String cle;

  /// Libellé français affiché dans le formulaire.
  final String label;

  /// Unité affichée à droite de la valeur. Vide pour les grandeurs sans unité
  /// (K₂₃₂, ΔK, écart ECN42).
  final String unite;

  final double? min;
  final double? max;

  /// Contrainte que deux bornes ne savent pas exprimer (le stigmastérol doit
  /// rester sous le campestérol). Purement indicatif ici : la vérification est
  /// faite par [conformite], qui a accès aux autres valeurs.
  final String? relation;

  const ParametreAnalyse({
    required this.cle,
    required this.label,
    this.unite = '',
    this.min,
    this.max,
    this.relation,
  });

  /// Ce qui s'affiche dans la colonne « Norme COI ».
  String get norme {
    if (relation != null) return relation!;
    if (min != null && max != null) return '${_n(min!)} – ${_n(max!)}';
    if (max != null) return '≤ ${_n(max!)}';
    if (min != null) return '≥ ${_n(min!)}';
    return '—';
  }

  /// Ce paramètre a-t-il un seuil à respecter ?
  bool get aUneNorme => min != null || max != null || relation != null;

  static String _n(double v) {
    final s = v.toStringAsFixed(2);
    return s.endsWith('.00') ? v.toStringAsFixed(0) : s;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLEAU 1 — Résultats principaux
// ─────────────────────────────────────────────────────────────────────────────
const List<ParametreAnalyse> kParametresPrincipaux = [
  ParametreAnalyse(
    cle: 'acidite',
    label: 'Acidité libre',
    unite: '% ac. oléique',
    max: 0.80,
  ),
  ParametreAnalyse(
    cle: 'indice_peroxyde',
    label: 'Indice de peroxyde',
    unite: 'meqO₂/kg',
    max: 20.0,
  ),
  ParametreAnalyse(cle: 'k232', label: 'K₂₃₂', max: 2.50),
  ParametreAnalyse(cle: 'k270', label: 'K₂₇₀', max: 0.22),
  ParametreAnalyse(cle: 'delta_k', label: 'ΔK', max: 0.01),
  ParametreAnalyse(
    cle: 'humidite',
    label: 'Humidité et matières volatiles',
    unite: '%',
    max: 0.20,
  ),
  ParametreAnalyse(
    cle: 'impuretes',
    label: 'Impuretés insolubles',
    unite: '%',
    max: 0.10,
  ),
  ParametreAnalyse(
    cle: 'ecn42',
    label: 'Écart ECN42 (réel / théorique)',
    max: 0.20,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// TABLEAU 2 — Composition en stérols (% des stérols totaux)
// ─────────────────────────────────────────────────────────────────────────────
const List<ParametreAnalyse> kSterols = [
  ParametreAnalyse(
    cle: 'cholesterol',
    label: 'Cholestérol',
    unite: '%',
    max: 0.50,
  ),
  ParametreAnalyse(
    cle: 'brassicasterol',
    label: 'Brassicastérol',
    unite: '%',
    max: 0.10,
  ),
  ParametreAnalyse(
    cle: 'campesterol',
    label: 'Campestérol',
    unite: '%',
    max: 4.00,
  ),
  ParametreAnalyse(
    cle: 'stigmasterol',
    label: 'Stigmastérol',
    unite: '%',
    relation: '< campestérol',
  ),
  ParametreAnalyse(
    cle: 'beta_sitosterol_apparent',
    label: 'β-sitostérol apparent',
    unite: '%',
    min: 93.00,
  ),
  ParametreAnalyse(
    cle: 'delta_7_stigmastenol',
    label: 'Δ7-stigmasténol',
    unite: '%',
    max: 0.50,
  ),
  // Le COI ne fixe pas de limite pour ce stérol : il est relevé, pas jugé.
  ParametreAnalyse(
    cle: 'delta_7_avenasterol',
    label: 'Δ7-avénastérol',
    unite: '%',
  ),
  ParametreAnalyse(
    cle: 'erythrodiol_uvaol',
    label: 'Érythrodiol et uvaol',
    unite: '%',
    max: 4.50,
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// TABLEAU 3 — Esters méthyliques d'acides gras (%)
// ─────────────────────────────────────────────────────────────────────────────
const List<ParametreAnalyse> kAcidesGras = [
  ParametreAnalyse(
    cle: 'acide_palmitique',
    label: 'Acide palmitique (C16:0)',
    unite: '%',
    min: 7.50,
    max: 20.00,
  ),
  ParametreAnalyse(
    cle: 'acide_palmitoleique',
    label: 'Acide palmitoléique (C16:1)',
    unite: '%',
    min: 0.30,
    max: 3.50,
  ),
  ParametreAnalyse(
    cle: 'acide_heptadecanoique',
    label: 'Acide heptadécanoïque (C17:0)',
    unite: '%',
    max: 0.40,
  ),
  ParametreAnalyse(
    cle: 'acide_heptadecenoique',
    label: 'Acide heptadécénoïque (C17:1)',
    unite: '%',
    max: 0.60,
  ),
  ParametreAnalyse(
    cle: 'acide_stearique',
    label: 'Acide stéarique (C18:0)',
    unite: '%',
    min: 0.50,
    max: 5.00,
  ),
  ParametreAnalyse(
    cle: 'acide_oleique',
    label: 'Acide oléique (C18:1)',
    unite: '%',
    min: 55.00,
    max: 83.00,
  ),
  ParametreAnalyse(
    cle: 'acide_linoleique',
    label: 'Acide linoléique (C18:2)',
    unite: '%',
    min: 2.50,
    max: 21.00,
  ),
  ParametreAnalyse(
    cle: 'acide_linolenique',
    label: 'Acide linolénique (C18:3)',
    unite: '%',
    max: 1.00,
  ),
  ParametreAnalyse(
    cle: 'acide_arachidique',
    label: 'Acide arachidique (C20:0)',
    unite: '%',
    max: 0.60,
  ),
  ParametreAnalyse(
    cle: 'acide_gadoleique',
    label: 'Acide gadoléique (C20:1)',
    unite: '%',
    max: 0.50,
  ),
  ParametreAnalyse(
    cle: 'trans_c18_1',
    label: 'Isomères trans C18:1',
    unite: '%',
    max: 0.05,
  ),
  ParametreAnalyse(
    cle: 'trans_c18_2_c18_3',
    label: 'Isomères trans C18:2 et C18:3',
    unite: '%',
    max: 0.05,
  ),
];

/// Les 28 paramètres, dans l'ordre du rapport.
const List<List<ParametreAnalyse>> kTableauxAnalyse = [
  kParametresPrincipaux,
  kSterols,
  kAcidesGras,
];

List<ParametreAnalyse> get kTousParametres => [
  for (final t in kTableauxAnalyse) ...t,
];

/// Les quatre valeurs sans lesquelles une analyse ne peut pas être soumise.
/// Ce sont celles qui décident du classement COI.
const List<String> kParametresObligatoires = [
  'acidite',
  'indice_peroxyde',
  'k232',
  'k270',
];

// ─────────────────────────────────────────────────────────────────────────────
// LECTURE DES VALEURS
// ─────────────────────────────────────────────────────────────────────────────

/// Lit un nombre saisi ou imprimé.
///
/// Le rapport du laboratoire écrit ses décimales avec une **virgule**
/// (`0,30`, `0,003`). Le clavier du téléphone, lui, produit souvent un point.
/// Les deux doivent aboutir au même nombre.
double? lireDecimal(String? texte) {
  if (texte == null) return null;
  final t = texte.trim().replaceAll(',', '.').replaceAll(' ', '');
  if (t.isEmpty) return null;
  return double.tryParse(t);
}

/// Écrit une valeur mesurée comme le rapport l'imprime.
///
/// Deux décimales partout, sauf sous 0,01 où deux ne diraient plus rien : le
/// ΔK vaut 0,003 et doit rester lisible.
String formatValeur(double v) {
  final abs = v.abs();
  return v.toStringAsFixed(abs > 0 && abs < 0.01 ? 3 : 2);
}

/// La valeur suivie de son unité, ou un tiret si elle n'a pas été saisie.
String formatValeurUnite(double? v, String unite) {
  if (v == null) return '—';
  return unite.isEmpty ? formatValeur(v) : '${formatValeur(v)} $unite';
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFORMITÉ
// ─────────────────────────────────────────────────────────────────────────────

/// Ce paramètre respecte-t-il la norme COI ?
///
/// Rend `null` quand la question ne se pose pas : valeur non saisie, ou
/// paramètre sans seuil (le Δ7-avénastérol est relevé, jamais jugé).
///
/// [valeurs] sert aux seuils qui dépendent d'un autre paramètre — aujourd'hui
/// le seul cas est le stigmastérol, qui doit rester sous le campestérol.
bool? conformite(
  ParametreAnalyse p,
  double? valeur, {
  Map<String, double?> valeurs = const {},
}) {
  if (valeur == null || !p.aUneNorme) return null;

  if (p.cle == 'stigmasterol') {
    final campesterol = valeurs['campesterol'];
    if (campesterol == null) return null;
    return valeur < campesterol;
  }

  if (p.min != null && valeur < p.min!) return false;
  if (p.max != null && valeur > p.max!) return false;
  return true;
}

/// Les paramètres saisis qui sortent de la norme.
List<ParametreAnalyse> parametresHorsNormes(Map<String, double?> valeurs) => [
  for (final p in kTousParametres)
    if (conformite(p, valeurs[p.cle], valeurs: valeurs) == false) p,
];

/// Classement COI déduit des valeurs saisies.
///
/// Rend `null` tant que les quatre paramètres obligatoires ne sont pas tous
/// renseignés — c'est-à-dire tant que la question n'a pas de réponse.
///
/// Le classement reste fondé sur les quatre grandeurs de dégradation
/// (acidité, peroxyde, K₂₃₂, K₂₇₀). Les stérols et les acides gras servent à
/// détecter un mélange ou une fraude, pas à mesurer la qualité : ils
/// alimentent l'alerte « hors normes », jamais le classement.
String? classificationCoi(Map<String, double?> valeurs) {
  final acidite = valeurs['acidite'];
  final peroxyde = valeurs['indice_peroxyde'];
  final k232 = valeurs['k232'];
  final k270 = valeurs['k270'];

  if (acidite == null || peroxyde == null || k232 == null || k270 == null) {
    return null;
  }

  if (acidite <= 0.80 && peroxyde <= 20 && k232 <= 2.50 && k270 <= 0.22) {
    return 'Extra Vierge';
  }
  if (acidite <= 2.00 && peroxyde <= 20 && k232 <= 2.60 && k270 <= 0.25) {
    return 'Vierge';
  }
  return 'Lampante';
}
