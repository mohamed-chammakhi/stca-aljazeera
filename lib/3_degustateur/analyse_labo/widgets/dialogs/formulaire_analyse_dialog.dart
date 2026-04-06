// ═════════════════════════════════════════════════════════════════════════════
// FILE    : analyse_laboratoire/widgets/dialogs/formulaire_analyse_dialog.dart
// PURPOSE : bottom sheet form to CREATE or EDIT a laboratory analysis
//           — echantillon selector (dropdown from list)
//           — date + technicien
//           — criteria table with numeric inputs
//           — statut chips
//           — notes
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/analyse_labo.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);
const Color _red        = Color(0xFFC62828);

// mock echantillon list for dropdown — replace with real data later
const List<Map<String, String>> _mockEchantillons = [
  {'id': 'OL-2024-001', 'nom': 'Chemlali - Lot A - Sfax'},
  {'id': 'OL-2024-002', 'nom': 'Chetoui - Lot B - Béja'},
  {'id': 'OL-2024-003', 'nom': 'Zalmati - Gafsa'},
  {'id': 'OL-2024-004', 'nom': 'Oueslati - Kairouan'},
  {'id': 'OL-2024-005', 'nom': 'Chemlali - Lot C - Sfax'},
];

Future<void> showFormulaireAnalyseDialog(
  BuildContext context, {
  required AnalyseLabo? analyse,        // null = create, non-null = edit
  required int          prochainNumero,
  required ValueChanged<AnalyseLabo> onSave,
}) {
  final isEdit = analyse != null;

  // ── controllers ──────────────────────────────────────────────────────────
  final dateCtrl       = TextEditingController(
      text: isEdit ? analyse.dateAnalyse : '');
  final technicienCtrl = TextEditingController(
      text: isEdit ? analyse.technicienNom : '');
  final notesCtrl      = TextEditingController(
      text: isEdit ? (analyse.notes ?? '') : '');

  // selected echantillon
  Map<String, String>? selectedEchantillon = isEdit
      ? _mockEchantillons.firstWhere(
          (e) => e['id'] == analyse.echantillonId,
          orElse: () => _mockEchantillons.first)
      : null;

  StatutAnalyse statut = isEdit ? analyse.statut : StatutAnalyse.enAttente;

  // deep-copy criteria so edits are not reflected until Enregistrer
  List<CritereAnalyse> criteres = isEdit
      ? analyse.criteres
            .map((c) => CritereAnalyse(
                  label:    c.label,
                  valeur:   c.valeur,
                  unite:    c.unite,
                  seuilMin: c.seuilMin,
                  seuilMax: c.seuilMax,
                ))
            .toList()
      : criteresDefaut();

  // controllers for each criteria value
  final List<TextEditingController> valeurCtrls = criteres
      .map((c) => TextEditingController(
          text: c.valeur == 0.0 ? '' : c.valeur.toString()))
      .toList();

  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) {

        void handleSave() {
          if (selectedEchantillon == null ||
              dateCtrl.text.trim().isEmpty ||
              technicienCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text(
                  'Veuillez remplir tous les champs obligatoires'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(20),
            ));
            return;
          }

          // apply current textfield values to criteres
          for (int i = 0; i < criteres.length; i++) {
            criteres[i].valeur =
                double.tryParse(valeurCtrls[i].text) ?? 0.0;
          }

          if (isEdit) {
            analyse
              ..echantillonId  = selectedEchantillon!['id']!
              ..echantillonNom = selectedEchantillon!['nom']!
              ..dateAnalyse    = dateCtrl.text.trim()
              ..technicienNom  = technicienCtrl.text.trim()
              ..statut         = statut
              ..notes          = notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim()
              ..criteres       = criteres;
            onSave(analyse);
          } else {
            onSave(AnalyseLabo(
              id:             'ANL-${prochainNumero.toString().padLeft(3, '0')}',
              echantillonId:  selectedEchantillon!['id']!,
              echantillonNom: selectedEchantillon!['nom']!,
              dateAnalyse:    dateCtrl.text.trim(),
              technicienNom:  technicienCtrl.text.trim(),
              statut:         statut,
              criteres:       criteres,
              notes:          notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim(),
            ));
          }
          Navigator.pop(ctx);
        }

        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color:        Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize:        MainAxisSize.min,
                crossAxisAlignment:  CrossAxisAlignment.start,
                children: [

                  // drag handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      decoration: BoxDecoration(
                        color:        Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // title
                  Text(
                    isEdit
                        ? 'Modifier l\'analyse'
                        : 'Nouvelle analyse',
                    style: const TextStyle(
                        fontSize:   17,
                        fontWeight: FontWeight.w700,
                        color:      _darkText),
                  ),
                  const SizedBox(height: 20),

                  // ── Echantillon dropdown ──────────────────────────────
                  _Label('Échantillon *'),
                  Container(
                    decoration: BoxDecoration(
                      color:        const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(
                          color: Colors.grey.shade200),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Map<String, String>>(
                        value:       selectedEchantillon,
                        hint:        Text('Sélectionner un échantillon',
                            style: TextStyle(
                                color:    Colors.grey.shade400,
                                fontSize: 13)),
                        isExpanded:  true,
                        icon:        const Icon(
                            Icons.keyboard_arrow_down,
                            color: _oliveGreen),
                        items: _mockEchantillons
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text('${e['id']} — ${e['nom']}',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color:    _darkText)),
                                ))
                            .toList(),
                        onChanged: (val) =>
                            setSheetState(() =>
                                selectedEchantillon = val),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ── Date + Technicien ─────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Date *'),
                          _Field(
                            controller:   dateCtrl,
                            hint:         'JJ/MM/AAAA',
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final d = v.replaceAll('/', '');
                              String f = '';
                              for (int i = 0;
                                  i < d.length && i < 8;
                                  i++) {
                                if (i == 2 || i == 4) f += '/';
                                f += d[i];
                              }
                              if (f != v) {
                                dateCtrl.value =
                                    TextEditingValue(
                                  text: f,
                                  selection:
                                      TextSelection.collapsed(
                                          offset: f.length),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label('Technicien *'),
                          _Field(
                              controller: technicienCtrl,
                              hint:       'Nom du technicien'),
                        ],
                      ),
                    ),
                  ]),

                  const SizedBox(height: 14),

                  // ── Statut chips ──────────────────────────────────────
                  _Label('Statut'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatutAnalyse.enAttente,
                      StatutAnalyse.envoyee,
                      StatutAnalyse.validee,
                    ].map((s) {
                      final labels = {
                        StatutAnalyse.enAttente: 'En attente',
                        StatutAnalyse.envoyee:   'Envoyée',
                        StatutAnalyse.validee:   'Validée',
                      };
                      final sel = statut == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () =>
                              setSheetState(() => statut = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: sel
                                  ? _green
                                  : Colors.grey.shade100,
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              labels[s]!,
                              style: TextStyle(
                                  fontSize:   12,
                                  fontWeight: FontWeight.w600,
                                  color:      sel
                                      ? Colors.white
                                      : Colors.grey.shade600),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // ── Criteria table ────────────────────────────────────
                  _Label('Critères d\'analyse (normes COI)'),
                  const SizedBox(height: 8),

                  // table header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color:        const Color(0xFFF1F8F4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      Expanded(
                          flex: 5,
                          child: Text('Critère',
                              style: TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w700,
                                  color:      _oliveGreen))),
                      Expanded(
                          flex: 3,
                          child: Text('Valeur',
                              style: TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w700,
                                  color:      _oliveGreen))),
                      Expanded(
                          flex: 3,
                          child: Text('Norme COI',
                              style: TextStyle(
                                  fontSize:   11,
                                  fontWeight: FontWeight.w700,
                                  color:      _oliveGreen))),
                    ]),
                  ),
                  const SizedBox(height: 4),

                  // table rows
                  ...List.generate(criteres.length, (i) {
                    final c      = criteres[i];
                    final valCtrl = valeurCtrls[i];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          // label
                          Expanded(
                            flex: 5,
                            child: Text(c.label,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color:    _darkText)),
                          ),
                          // value input
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller:   valCtrl,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                          decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .allow(
                                        RegExp(r'[\d.]'))
                              ],
                              onChanged: (v) {
                                final parsed =
                                    double.tryParse(v);
                                if (parsed != null) {
                                  setSheetState(() =>
                                      criteres[i].valeur =
                                          parsed);
                                }
                              },
                              style: const TextStyle(
                                  fontSize: 13,
                                  color:    _darkText),
                              decoration: InputDecoration(
                                hintText:  '0.00',
                                hintStyle: TextStyle(
                                    color:    Colors
                                        .grey.shade400,
                                    fontSize: 12),
                                suffixText:  c.unite.isEmpty
                                    ? null
                                    : c.unite,
                                suffixStyle: TextStyle(
                                    fontSize: 10,
                                    color:    Colors
                                        .grey.shade500),
                                filled:    true,
                                fillColor: const Color(
                                    0xFFF7FAF8),
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                            horizontal: 10,
                                            vertical:   8),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors
                                          .grey.shade200),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Colors
                                          .grey.shade200),
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(
                                          color: _green,
                                          width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // norme
                          Expanded(
                            flex: 3,
                            child: Text(
                              _seuilLabel(c),
                              style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.grey.shade500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 14),

                  // ── Notes ─────────────────────────────────────────────
                  _Label('Notes (optionnel)'),
                  _Field(
                    controller: notesCtrl,
                    hint:       'Observations, conditions d\'analyse...',
                    maxLines:   3,
                  ),

                  const SizedBox(height: 24),

                  // ── Annuler + Enregistrer ─────────────────────────────
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side:    const BorderSide(
                              color: _green),
                          padding: const EdgeInsets
                              .symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        child: const Text('Annuler',
                            style: TextStyle(
                                fontWeight:
                                    FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation:       0,
                          padding: const EdgeInsets
                              .symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEdit
                              ? 'Enregistrer'
                              : 'Créer',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ── helpers ────────────────────────────────────────────────────────────────
String _seuilLabel(CritereAnalyse c) {
  if (c.seuilMin == null && c.seuilMax == null) return '—';
  if (c.seuilMax != null && c.seuilMin != null) {
    return '${c.seuilMin}–${c.seuilMax} ${c.unite}'.trim();
  }
  if (c.seuilMax != null) return '≤ ${c.seuilMax} ${c.unite}'.trim();
  return '≥ ${c.seuilMin} ${c.unite}'.trim();
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      _oliveGreen)),
      );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String                hint;
  final TextInputType         keyboardType;
  final int                   maxLines;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines     = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller:   controller,
        keyboardType: keyboardType,
        maxLines:     maxLines,
        onChanged:    onChanged,
        style: const TextStyle(fontSize: 14, color: _darkText),
        decoration: InputDecoration(
          hintText:  hint,
          hintStyle: TextStyle(
              color: Colors.grey.shade400, fontSize: 13),
          filled:    true,
          fillColor: const Color(0xFFF7FAF8),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:
                BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: _green, width: 1.8),
          ),
        ),
      );
}
