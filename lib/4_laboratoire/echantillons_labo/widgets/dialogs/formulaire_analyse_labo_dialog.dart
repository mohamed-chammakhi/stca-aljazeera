// ═════════════════════════════════════════════════════════════════════════════
// FILE    : laboratoire/echantillons_labo/widgets/dialogs/formulaire_analyse_labo_dialog.dart
// PURPOSE : Bottom sheet form to CREATE, EDIT, or VIEW a laboratory analysis.
//           In create/edit mode: editable fields with live classification.
//           In read-only mode: same layout with non-editable values.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../analyse_labo.dart';
import '../../../../../core/theme/app_colors.dart';

String _todayLabel() {
  final now = DateTime.now();
  return '${now.day.toString().padLeft(2, '0')}/'
      '${now.month.toString().padLeft(2, '0')}/${now.year}';
}

Future<void> showFormulaireAnalyseLaboDialog(
  BuildContext context, {
  required String echantillonRef,
  required String echantillonId,
  AnalyseLabo? analyse, // null = create, non-null = edit or view
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
  // ── Controllers ────────────────────────────────────────────────────────────
  late final TextEditingController _aciditeCtrl;
  late final TextEditingController _peroxydeCtrl;
  late final TextEditingController _k232Ctrl;
  late final TextEditingController _k270Ctrl;
  late final TextEditingController _deltaKCtrl;
  late final TextEditingController _humiditeCtrl;
  late final TextEditingController _impuretesCtrl;
  late final TextEditingController _polyphenolsCtrl;
  late final TextEditingController _tocophCtrl;
  late final TextEditingController _oleicCtrl;
  late final TextEditingController _linoleicCtrl;
  late final TextEditingController _palmiticCtrl;
  late final TextEditingController _notesCtrl;

  String _classif = '—';

  @override
  void initState() {
    super.initState();
    final a = widget.analyse;
    _aciditeCtrl = TextEditingController(
      text: a?.aciditeLibre?.toString() ?? '',
    );
    _peroxydeCtrl = TextEditingController(
      text: a?.indicePeroxyde?.toString() ?? '',
    );
    _k232Ctrl = TextEditingController(text: a?.k232?.toString() ?? '');
    _k270Ctrl = TextEditingController(text: a?.k270?.toString() ?? '');
    _deltaKCtrl = TextEditingController(text: a?.deltaK?.toString() ?? '');
    _humiditeCtrl = TextEditingController(text: a?.humidite?.toString() ?? '');
    _impuretesCtrl = TextEditingController(
      text: a?.impuretes?.toString() ?? '',
    );
    _polyphenolsCtrl = TextEditingController(
      text: a?.polyphenolsTotaux?.toString() ?? '',
    );
    _tocophCtrl = TextEditingController(text: a?.tocopherols?.toString() ?? '');
    _oleicCtrl = TextEditingController(text: a?.acideOleique?.toString() ?? '');
    _linoleicCtrl = TextEditingController(
      text: a?.acideLinoleique?.toString() ?? '',
    );
    _palmiticCtrl = TextEditingController(
      text: a?.acidePalmitique?.toString() ?? '',
    );
    _notesCtrl = TextEditingController(text: a?.notes ?? '');

    if (!widget.readOnly) {
      _aciditeCtrl.addListener(_recompute);
      _peroxydeCtrl.addListener(_recompute);
      _k232Ctrl.addListener(_recompute);
      _k270Ctrl.addListener(_recompute);
      _recompute();
    } else {
      _classif = a?.classificationAuto ?? '—';
    }
  }

  void _recompute() {
    final acide = double.tryParse(_aciditeCtrl.text);
    final perox = double.tryParse(_peroxydeCtrl.text);
    // Delegate to the model's single source of truth for classification logic.
    final c = (acide != null && perox != null)
        ? AnalyseLabo(
            echantillonId: '',
            echantillonRef: '',
            aciditeLibre: acide,
            indicePeroxyde: perox,
            k232: double.tryParse(_k232Ctrl.text),
            k270: double.tryParse(_k270Ctrl.text),
          ).classificationAuto
        : '—';
    if (mounted) setState(() => _classif = c);
  }

  void _handleSave() {
    final acide = double.tryParse(_aciditeCtrl.text);
    final perox = double.tryParse(_peroxydeCtrl.text);
    final k232 = double.tryParse(_k232Ctrl.text);
    final k270 = double.tryParse(_k270Ctrl.text);

    if (acide == null || perox == null || k232 == null || k270 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Veuillez remplir tous les champs obligatoires (Acidité, Peroxyde, K₂₃₂, K₂₇₀)',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    final saved = AnalyseLabo(
      echantillonId: widget.echantillonId,
      echantillonRef: widget.echantillonRef,
      aciditeLibre: acide,
      indicePeroxyde: perox,
      k232: k232,
      k270: k270,
      deltaK: double.tryParse(_deltaKCtrl.text),
      humidite: double.tryParse(_humiditeCtrl.text),
      impuretes: double.tryParse(_impuretesCtrl.text),
      polyphenolsTotaux: double.tryParse(_polyphenolsCtrl.text),
      tocopherols: double.tryParse(_tocophCtrl.text),
      acideOleique: double.tryParse(_oleicCtrl.text),
      acideLinoleique: double.tryParse(_linoleicCtrl.text),
      acidePalmitique: double.tryParse(_palmiticCtrl.text),
      classification: _classif == '—' ? null : _classif,
      statut: StatutAnalyse.soumis,
      dateAnalyse: widget.analyse?.dateAnalyse ?? _todayLabel(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    Navigator.pop(context);
    widget.onSave(saved);
  }

  void _handleSaveDraft() {
    final draft = AnalyseLabo(
      echantillonId:     widget.echantillonId,
      echantillonRef:    widget.echantillonRef,
      aciditeLibre:      double.tryParse(_aciditeCtrl.text),
      indicePeroxyde:    double.tryParse(_peroxydeCtrl.text),
      k232:              double.tryParse(_k232Ctrl.text),
      k270:              double.tryParse(_k270Ctrl.text),
      deltaK:            double.tryParse(_deltaKCtrl.text),
      humidite:          double.tryParse(_humiditeCtrl.text),
      impuretes:         double.tryParse(_impuretesCtrl.text),
      polyphenolsTotaux: double.tryParse(_polyphenolsCtrl.text),
      tocopherols:       double.tryParse(_tocophCtrl.text),
      acideOleique:      double.tryParse(_oleicCtrl.text),
      acideLinoleique:   double.tryParse(_linoleicCtrl.text),
      acidePalmitique:   double.tryParse(_palmiticCtrl.text),
      classification:    _classif == '—' ? null : _classif,
      statut:            StatutAnalyse.enCours,
      dateAnalyse:       widget.analyse?.dateAnalyse ?? _todayLabel(),
      notes:             _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    Navigator.pop(context);
    widget.onSave(draft);
  }

  @override
  void dispose() {
    for (final c in [
      _aciditeCtrl,
      _peroxydeCtrl,
      _k232Ctrl,
      _k270Ctrl,
      _deltaKCtrl,
      _humiditeCtrl,
      _impuretesCtrl,
      _polyphenolsCtrl,
      _tocophCtrl,
      _oleicCtrl,
      _linoleicCtrl,
      _palmiticCtrl,
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

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── drag handle ──────────────────────────────────────────────
            const SizedBox(height: 36),
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
            const SizedBox(height: 22),

            // ── header ───────────────────────────────────────────────────
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
                      Text(
                        widget.echantillonRef,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── scrollable content ───────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Classification banner
                    _ClassifBanner(classif: _classif),
                    const SizedBox(height: 16),

                    // ── Table header ────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _ColHeader(flex: 5, text: 'Paramètre'),
                          _ColHeader(flex: 3, text: 'Valeur'),
                          _ColHeader(flex: 3, text: 'Norme COI'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Section: Essentiels ─────────────────────────────
                    _SectionRow('Paramètres essentiels COI'),
                    _FieldRow(
                      label: 'Acidité libre *',
                      unite: '% ac. oléique',
                      norm: '≤ 0.80',
                      ctrl: _aciditeCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'Indice de peroxyde *',
                      unite: 'meqO₂/kg',
                      norm: '≤ 20',
                      ctrl: _peroxydeCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'K₂₃₂ *',
                      unite: '',
                      norm: '≤ 2.50',
                      ctrl: _k232Ctrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'K₂₇₀ *',
                      unite: '',
                      norm: '≤ 0.22',
                      ctrl: _k270Ctrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'ΔK',
                      unite: '',
                      norm: '≤ 0.01',
                      ctrl: _deltaKCtrl,
                      readOnly: widget.readOnly,
                    ),

                    // ── Section: Contaminants ───────────────────────────
                    _SectionRow('Contaminants physiques'),
                    _FieldRow(
                      label: 'Humidité',
                      unite: '%',
                      norm: '≤ 0.20',
                      ctrl: _humiditeCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'Impuretés',
                      unite: '%',
                      norm: '≤ 0.10',
                      ctrl: _impuretesCtrl,
                      readOnly: widget.readOnly,
                    ),

                    // ── Section: Qualité ────────────────────────────────
                    _SectionRow('Indicateurs de qualité'),
                    _FieldRow(
                      label: 'Polyphénols totaux',
                      unite: 'mg/kg',
                      norm: 'Élevé = meilleur',
                      ctrl: _polyphenolsCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'Tocophérols',
                      unite: 'mg/kg',
                      norm: 'Antioxydant',
                      ctrl: _tocophCtrl,
                      readOnly: widget.readOnly,
                    ),

                    // ── Section: Acides gras ────────────────────────────
                    _SectionRow('Profil en acides gras (optionnel)'),
                    _FieldRow(
                      label: 'Acide oléique (C18:1)',
                      unite: '%',
                      norm: '55 – 83 %',
                      ctrl: _oleicCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'Acide linoléique (C18:2)',
                      unite: '%',
                      norm: '2.5 – 21 %',
                      ctrl: _linoleicCtrl,
                      readOnly: widget.readOnly,
                    ),
                    _FieldRow(
                      label: 'Acide palmitique (C16:0)',
                      unite: '%',
                      norm: '7.5 – 20 %',
                      ctrl: _palmiticCtrl,
                      readOnly: widget.readOnly,
                    ),

                    // ── Notes ───────────────────────────────────────────
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

                    // ── Buttons ─────────────────────────────────────────
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
                          // Draft button — full width, orange outlined
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
                                side: const BorderSide(
                                    color: Color(0xFFD07B2F)),
                                backgroundColor:
                                    const Color(0xFFD07B2F).withValues(alpha: 0.05),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Cancel + Submit row
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kGreen,
                                    side: const BorderSide(color: kGreen),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Annuler',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
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
                                        vertical: 13),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    isCreate ? 'Soumettre' : 'Enregistrer',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
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
// CLASSIFICATION BANNER
// ─────────────────────────────────────────────────────────────────────────────
class _ClassifBanner extends StatelessWidget {
  final String classif;
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
          Text(
            classif,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION ROW  — colored label that spans full width
// ─────────────────────────────────────────────────────────────────────────────
class _SectionRow extends StatelessWidget {
  final String text;
  const _SectionRow(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
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
// FIELD ROW  — one criteria row in the table
// ─────────────────────────────────────────────────────────────────────────────
class _FieldRow extends StatelessWidget {
  final String label;
  final String unite;
  final String norm;
  final TextEditingController ctrl;
  final bool readOnly;

  const _FieldRow({
    required this.label,
    required this.unite,
    required this.norm,
    required this.ctrl,
    required this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Label
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: kDark),
            ),
          ),

          // Value: input or read-only text
          Expanded(
            flex: 3,
            child: readOnly
                ? Text(
                    ctrl.text.isEmpty
                        ? '—'
                        : unite.isEmpty
                        ? ctrl.text
                        : '${ctrl.text} $unite',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                  )
                : TextField(
                    controller: ctrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                    style: const TextStyle(fontSize: 13, color: kDark),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                      suffixText: unite.isEmpty ? null : unite,
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

          const SizedBox(width: 8),

          // Norm
          Expanded(
            flex: 3,
            child: Text(
              norm,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ),
        ],
      ),
    );
  }
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
