// ═════════════════════════════════════════════════════════════════════════════
// FILE    : laboratoire/echantillons_labo/widgets/dialogs/formulaire_analyse_labo_dialog.dart
// PURPOSE : Saisie d'un rapport d'analyse, dans l'ordre exact où le
//           laboratoire l'imprime : identification du certificat, puis les
//           trois tableaux (résultats principaux, stérols, acides gras).
//
//           Les libellés, unités, seuils et l'ordre viennent tous de
//           core/analyses/normes_coi.dart. Ce fichier ne connaît aucun
//           paramètre par son nom : en ajouter un ne le touche pas.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../analyse_labo.dart';
import '../../../../core/analyses/normes_coi.dart';
import '../../../../core/theme/app_colors.dart';

String _todayLabel() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/${now.year}';
}

/// Les titres des trois tableaux, dans l'ordre de [kTableauxAnalyse].
const List<String> _titresTableaux = [
  'Résultats principaux',
  'Composition en stérols',
  'Acides gras',
];

/// Ce que chaque tableau mesure, dit en une ligne. Le technicien recopie un
/// papier : il doit reconnaître la section d'un coup d'œil.
const List<String> _sousTitresTableaux = [
  'Acidité, UV, peroxyde, humidité, impuretés, ECN42',
  '% des stérols totaux',
  '% des esters méthyliques',
];

Future<void> showFormulaireAnalyseLaboDialog(
  BuildContext context, {
  required String echantillonRef,
  required String echantillonId,
  AnalyseLabo? analyse, // null = création, non-null = modification ou lecture
  bool readOnly = false,
  required ValueChanged<AnalyseLabo> onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FormulaireSheet(
      echantillonRef: echantillonRef,
      echantillonId: echantillonId,
      analyse: analyse,
      readOnly: readOnly,
      onSave: onSave,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireSheet extends StatefulWidget {
  final String echantillonRef;
  final String echantillonId;
  final AnalyseLabo? analyse;
  final bool readOnly;
  final ValueChanged<AnalyseLabo> onSave;

  const _FormulaireSheet({
    required this.echantillonRef,
    required this.echantillonId,
    required this.analyse,
    required this.readOnly,
    required this.onSave,
  });

  @override
  State<_FormulaireSheet> createState() => _FormulaireSheetState();
}

class _FormulaireSheetState extends State<_FormulaireSheet> {
  /// Un champ de saisie par paramètre, indexé par sa clé.
  late final Map<String, TextEditingController> _champs;

  late final TextEditingController _certificatCtrl;
  late final TextEditingController _lotCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _debutCtrl;
  late final TextEditingController _finCtrl;
  late final TextEditingController _notesCtrl;

  /// Un seul tableau ouvert à la fois : les 28 lignes d'un coup seraient
  /// illisibles sur un téléphone. Les résultats principaux sont ouverts au
  /// départ — ce sont eux qui décident du classement.
  final Set<int> _tableauxOuverts = {0};

  @override
  void initState() {
    super.initState();
    final a = widget.analyse;

    _champs = {
      for (final p in kTousParametres)
        p.cle: TextEditingController(
          text: a?.valeur(p.cle) != null ? formatValeur(a!.valeur(p.cle)!) : '',
        ),
    };

    _certificatCtrl = TextEditingController(text: a?.numeroCertificat ?? '');
    _lotCtrl = TextEditingController(text: a?.numeroLot ?? '');
    _quantiteCtrl = TextEditingController(text: a?.quantiteMl?.toString() ?? '');
    _debutCtrl = TextEditingController(text: a?.dateDebutAnalyse ?? '');
    _finCtrl = TextEditingController(text: a?.dateFinAnalyse ?? '');
    _notesCtrl = TextEditingController(text: a?.notes ?? '');

    if (!widget.readOnly) {
      // Le classement et les alertes se recalculent à chaque frappe : le
      // technicien voit tout de suite l'effet de la valeur qu'il recopie.
      for (final c in _champs.values) {
        c.addListener(_rafraichir);
      }
    }
  }

  void _rafraichir() {
    if (mounted) setState(() {});
  }

  /// Les valeurs actuellement saisies, telles que la table des normes les lit.
  Map<String, double?> get _valeurs => {
    for (final e in _champs.entries) e.key: lireDecimal(e.value.text),
  };

  void _handleSave() {
    final valeurs = _valeurs;
    final manquants = kParametresObligatoires
        .where((cle) => valeurs[cle] == null)
        .map((cle) => kTousParametres.firstWhere((p) => p.cle == cle).label)
        .toList();

    if (manquants.isNotEmpty) {
      // On nomme ce qui manque : « remplissez les champs obligatoires »
      // obligerait à relire les 28 lignes pour trouver le trou.
      _erreur('Valeur manquante : ${manquants.join(', ')}');
      return;
    }

    // Les paramètres du haut sont ouverts par défaut, ceux du bas non : un
    // tableau replié est facile à oublier. On le dit avant d'envoyer.
    final horsNormes = parametresHorsNormes(valeurs);
    if (horsNormes.isNotEmpty) {
      _confirmerHorsNormes(horsNormes, valeurs);
      return;
    }

    _envoyer(valeurs, StatutAnalyse.soumis);
  }

  Future<void> _confirmerHorsNormes(
    List<ParametreAnalyse> horsNormes,
    Map<String, double?> valeurs,
  ) async {
    final confirme = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmerHorsNormesDialog(parametres: horsNormes),
    );
    if (confirme == true && mounted) {
      _envoyer(valeurs, StatutAnalyse.soumis);
    }
  }

  void _handleSaveDraft() => _envoyer(_valeurs, StatutAnalyse.enCours);

  void _envoyer(Map<String, double?> valeurs, StatutAnalyse statut) {
    final saved = AnalyseLabo(
      echantillonId: widget.echantillonId,
      echantillonRef: widget.echantillonRef,
      valeurs: valeurs,
      numeroCertificat: _texteOuNull(_certificatCtrl),
      numeroLot: _texteOuNull(_lotCtrl),
      dateDebutAnalyse: _texteOuNull(_debutCtrl),
      dateFinAnalyse: _texteOuNull(_finCtrl),
      quantiteMl: int.tryParse(_quantiteCtrl.text.trim()),
      statut: statut,
      dateAnalyse: widget.analyse?.dateAnalyse ?? _todayLabel(),
      notes: _texteOuNull(_notesCtrl),
    );

    Navigator.pop(context);
    widget.onSave(saved);
  }

  static String? _texteOuNull(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  void _erreur(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _champs.values) {
      c.dispose();
    }
    for (final c in [
      _certificatCtrl,
      _lotCtrl,
      _quantiteCtrl,
      _debutCtrl,
      _finCtrl,
      _notesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isCreate = widget.analyse == null;
    final title = widget.readOnly
        ? 'Rapport d\'analyse'
        : isCreate
        ? 'Nouvelle analyse'
        : 'Modifier l\'analyse';

    final valeurs = _valeurs;
    final classif = classificationCoi(valeurs);
    final horsNormes = parametresHorsNormes(valeurs);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // ── en-tête ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                        ),
                      ),
                      if (widget.readOnly &&
                          widget.analyse?.dateAnalyse != null)
                        Text(
                          'Soumis le ${widget.analyse!.dateAnalyse}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Référence de l\'échantillon : ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.echantillonRef,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── contenu défilant ─────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ClassifBanner(classif: classif),
                    if (horsNormes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _BandeauHorsNormes(parametres: horsNormes),
                    ],
                    const SizedBox(height: 16),

                    // ── identification du certificat ────────────────────
                    _SectionRow('Identification du certificat'),
                    _ChampTexte(
                      label: 'N° de certificat',
                      hint: 'ex. 188-2026',
                      ctrl: _certificatCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _ChampTexte(
                      label: 'Lot',
                      hint: 'ex. COM142-0426',
                      ctrl: _lotCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _ChampTexte(
                      label: 'Quantité analysée',
                      hint: 'ex. 100',
                      suffixe: 'ml',
                      chiffresSeuls: true,
                      ctrl: _quantiteCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _ChampTexte(
                      label: 'Début d\'analyse',
                      hint: 'aaaa-mm-jj',
                      ctrl: _debutCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _ChampTexte(
                      label: 'Fin d\'analyse',
                      hint: 'aaaa-mm-jj',
                      ctrl: _finCtrl,
                      readOnly: widget.readOnly,
                    ),

                    const SizedBox(height: 18),

                    // ── les trois tableaux du rapport ───────────────────
                    for (var i = 0; i < kTableauxAnalyse.length; i++)
                      _TableauParametres(
                        titre: _titresTableaux[i],
                        sousTitre: _sousTitresTableaux[i],
                        parametres: kTableauxAnalyse[i],
                        champs: _champs,
                        valeurs: valeurs,
                        readOnly: widget.readOnly,
                        ouvert: _tableauxOuverts.contains(i),
                        onToggle: () => setState(() {
                          _tableauxOuverts.contains(i)
                              ? _tableauxOuverts.remove(i)
                              : _tableauxOuverts.add(i);
                        }),
                      ),

                    // ── notes ───────────────────────────────────────────
                    const SizedBox(height: 14),
                    _Label('Notes (optionnel)'),
                    if (widget.readOnly)
                      _notesCtrl.text.isEmpty
                          ? Text(
                              '—',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAF8),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Text(
                                _notesCtrl.text,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kDark,
                                ),
                              ),
                            )
                    else
                      TextField(
                        controller: _notesCtrl,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14, color: kDark),
                        decoration: InputDecoration(
                          hintText:
                              'Observations, anomalies, conditions d\'analyse...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF7FAF8),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: kGreen,
                              width: 1.8,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // ── boutons ─────────────────────────────────────────
                    if (widget.readOnly)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kGreen,
                            side: const BorderSide(color: kGreen),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Fermer',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _handleSaveDraft,
                              icon: const Icon(Icons.save_outlined, size: 16),
                              label: const Text(
                                'Enregistrer comme brouillon',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFD07B2F),
                                side: const BorderSide(color: Color(0xFFD07B2F)),
                                backgroundColor: const Color(
                                  0xFFD07B2F,
                                ).withValues(alpha: 0.05),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kGreen,
                                    side: const BorderSide(color: kGreen),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: kGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isCreate ? 'Soumettre' : 'Enregistrer',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UN TABLEAU DU RAPPORT — repliable
// ─────────────────────────────────────────────────────────────────────────────
class _TableauParametres extends StatelessWidget {
  final String titre;
  final String sousTitre;
  final List<ParametreAnalyse> parametres;
  final Map<String, TextEditingController> champs;
  final Map<String, double?> valeurs;
  final bool readOnly;
  final bool ouvert;
  final VoidCallback onToggle;

  const _TableauParametres({
    required this.titre,
    required this.sousTitre,
    required this.parametres,
    required this.champs,
    required this.valeurs,
    required this.readOnly,
    required this.ouvert,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final remplis = parametres.where((p) => valeurs[p.cle] != null).length;
    final horsNormes = parametres
        .where((p) => conformite(p, valeurs[p.cle], valeurs: valeurs) == false)
        .length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── barre de titre ──────────────────────────────────────────────
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titre,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: kDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sousTitre,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Combien de lignes sont remplies : un tableau replié ne doit
                  // pas cacher qu'il est vide.
                  if (horsNormes > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 15,
                        color: Colors.red.shade400,
                      ),
                    ),
                  Text(
                    '$remplis/${parametres.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: remplis == 0 ? Colors.grey.shade400 : kOlive,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: ouvert ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── lignes ──────────────────────────────────────────────────────
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 6),
                    child: Row(
                      children: const [
                        _ColHeader(flex: 5, text: 'Paramètre'),
                        _ColHeader(flex: 3, text: 'Valeur'),
                        _ColHeader(flex: 3, text: 'Norme COI'),
                      ],
                    ),
                  ),
                  for (final p in parametres)
                    _FieldRow(
                      parametre: p,
                      ctrl: champs[p.cle]!,
                      conforme: conformite(p, valeurs[p.cle], valeurs: valeurs),
                      readOnly: readOnly,
                    ),
                ],
              ),
            ),
            crossFadeState: ouvert
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 180),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANDEAU DE CLASSIFICATION
// ─────────────────────────────────────────────────────────────────────────────
class _ClassifBanner extends StatelessWidget {
  final String? classif;
  const _ClassifBanner({required this.classif});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    if (classif == 'Extra Vierge') {
      color = kGreen;
      icon = Icons.verified_outlined;
    } else if (classif == 'Vierge') {
      color = Colors.orange.shade700;
      icon = Icons.check_circle_outline;
    } else if (classif == 'Lampante') {
      color = Colors.red.shade700;
      icon = Icons.cancel_outlined;
    } else {
      color = Colors.grey.shade400;
      icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            'Classification : ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Expanded(
            child: Text(
              // Sans les quatre grandeurs obligatoires, la question n'a pas de
              // réponse — on le dit plutôt que d'afficher un tiret muet.
              classif ?? 'en attente des 4 valeurs obligatoires',
              style: TextStyle(
                fontSize: classif == null ? 12 : 14,
                fontWeight: classif == null ? FontWeight.w500 : FontWeight.w800,
                color: classif == null ? Colors.grey.shade500 : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BANDEAU « HORS NORMES »
// ─────────────────────────────────────────────────────────────────────────────
class _BandeauHorsNormes extends StatelessWidget {
  final List<ParametreAnalyse> parametres;
  const _BandeauHorsNormes({required this.parametres});

  @override
  Widget build(BuildContext context) {
    final rouge = Colors.red.shade700;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: rouge.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rouge.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 17, color: rouge),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parametres.length == 1
                  ? '${parametres.first.label} sort de la norme COI'
                  : '${parametres.length} paramètres sortent de la norme COI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: rouge,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONFIRMATION AVANT DE SOUMETTRE UN RAPPORT HORS NORMES
// ─────────────────────────────────────────────────────────────────────────────
class _ConfirmerHorsNormesDialog extends StatelessWidget {
  final List<ParametreAnalyse> parametres;
  const _ConfirmerHorsNormesDialog({required this.parametres});

  @override
  Widget build(BuildContext context) {
    final rouge = Colors.red.shade700;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: rouge, size: 22),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Valeurs hors norme',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            parametres.length == 1
                ? 'Ce paramètre sort de la norme COI :'
                : 'Ces ${parametres.length} paramètres sortent de la norme COI :',
            style: const TextStyle(fontSize: 13, color: kDark),
          ),
          const SizedBox(height: 10),
          for (final p in parametres)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${p.label}  (norme ${p.norme})',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            'La direction en sera prévenue. Vérifiez que la saisie correspond '
            'bien au rapport papier avant de soumettre.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Revoir la saisie',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: rouge,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Soumettre quand même'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION ROW
// ─────────────────────────────────────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final String text;
  const _SectionRow(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kOlive,
        letterSpacing: 0.4,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TABLE COLUMN HEADER
// ─────────────────────────────────────────────────────────────────────────────
class _ColHeader extends StatelessWidget {
  final int flex;
  final String text;
  const _ColHeader({required this.flex, required this.text});

  @override
  Widget build(BuildContext context) => Expanded(
    flex: flex,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kOlive,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD ROW — une ligne du tableau
// ─────────────────────────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final ParametreAnalyse parametre;
  final TextEditingController ctrl;
  final bool? conforme;
  final bool readOnly;

  const _FieldRow({
    required this.parametre,
    required this.ctrl,
    required this.conforme,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final horsNorme = conforme == false;
    final rouge = Colors.red.shade600;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              parametre.label,
              style: const TextStyle(fontSize: 12, color: kDark),
            ),
          ),

          Expanded(
            flex: 3,
            child: readOnly
                ? Text(
                    formatValeurUnite(lireDecimal(ctrl.text), parametre.unite),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: horsNorme ? rouge : kDark,
                    ),
                  )
                : TextField(
                    controller: ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      // Le rapport imprime ses décimales avec une virgule, le
                      // clavier propose souvent un point : les deux passent.
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                    ],
                    style: TextStyle(
                      fontSize: 13,
                      color: horsNorme ? rouge : kDark,
                      fontWeight: horsNorme ? FontWeight.w700 : FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: '0,00',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      suffixText: parametre.unite.isEmpty
                          ? null
                          : parametre.unite,
                      suffixStyle: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                      filled: true,
                      fillColor: horsNorme
                          ? rouge.withValues(alpha: 0.05)
                          : const Color(0xFFF7FAF8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: horsNorme ? rouge : Colors.grey.shade200,
                          width: horsNorme ? 1.4 : 1.0,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: horsNorme ? rouge : kGreen,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          Expanded(
            flex: 3,
            child: Text(
              parametre.norme,
              style: TextStyle(
                fontSize: 11,
                color: horsNorme ? rouge : Colors.grey.shade500,
                fontWeight: horsNorme ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHAMP TEXTE — pour l'identification du certificat
// ─────────────────────────────────────────────────────────────────────────────
class _ChampTexte extends StatelessWidget {
  final String label;
  final String hint;
  final String? suffixe;
  final bool chiffresSeuls;
  final TextEditingController ctrl;
  final bool readOnly;

  const _ChampTexte({
    required this.label,
    required this.hint,
    required this.ctrl,
    required this.readOnly,
    this.suffixe,
    this.chiffresSeuls = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: kDark),
          ),
        ),
        Expanded(
          flex: 6,
          child: readOnly
              ? Text(
                  ctrl.text.isEmpty
                      ? '—'
                      : suffixe == null
                      ? ctrl.text
                      : '${ctrl.text} $suffixe',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: kDark,
                  ),
                )
              : TextField(
                  controller: ctrl,
                  keyboardType: chiffresSeuls
                      ? TextInputType.number
                      : TextInputType.text,
                  inputFormatters: chiffresSeuls
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  style: const TextStyle(fontSize: 13, color: kDark),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                    suffixText: suffixe,
                    suffixStyle: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF7FAF8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kGreen, width: 1.5),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );
}

// ── label helper ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: kOlive,
      ),
    ),
  );
}
