// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart
// PURPOSE : bottom sheet form to CREATE or EDIT a session
// USAGE   : showFormulaireSessionDialog(context, session: null, ...)  ← add
//           showFormulaireSessionDialog(context, session: s,    ...)  ← edit
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/session_degustation.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

Future<void> showFormulaireSessionDialog(
  BuildContext context, {
  required SessionDegustation? session,       // null = add mode, non-null = edit
  required int                 prochainNumero,
  required ValueChanged<SessionDegustation> onSave,
}) {
  final isEdit = session != null;

  // ── pre-fill controllers ──────────────────────────────────────────────────
  final titreCtrl = TextEditingController(
      text: isEdit ? session.titre : '');
  final dateCtrl  = TextEditingController(
      text: isEdit ? session.date  : '');
  final heureCtrl = TextEditingController(
      text: isEdit ? session.heure : '');
  final lieuCtrl  = TextEditingController(
      text: isEdit ? session.lieu  : '');
  final notesCtrl = TextEditingController(
      text: isEdit ? (session.notes ?? '') : '');

  StatutSession statut = isEdit ? session.statut : StatutSession.planifiee;

  return showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) {

        // ── validation + save ─────────────────────────────────────────────
        void handleSave() {
          if (titreCtrl.text.trim().isEmpty ||
              dateCtrl.text.trim().isEmpty  ||
              heureCtrl.text.trim().isEmpty ||
              lieuCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Veuillez remplir tous les champs obligatoires'),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(20),
              ),
            );
            return;
          }

          if (isEdit) {
            // mutate existing object
            session
              ..titre  = titreCtrl.text.trim()
              ..date   = dateCtrl.text.trim()
              ..heure  = heureCtrl.text.trim()
              ..lieu   = lieuCtrl.text.trim()
              ..statut = statut
              ..notes  = notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim();
            onSave(session);
          } else {
            // create new object
            final nouveau = SessionDegustation(
              id:     'SES-${prochainNumero.toString().padLeft(3, '0')}',
              titre:  titreCtrl.text.trim(),
              date:   dateCtrl.text.trim(),
              heure:  heureCtrl.text.trim(),
              lieu:   lieuCtrl.text.trim(),
              statut: statut,
              notes:  notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim(),
            );
            onSave(nouveau);
          }

          Navigator.pop(ctx);
        }

        return Padding(
          // push the sheet up when keyboard appears
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── drag handle ──────────────────────────────────────────
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

                  // ── title ────────────────────────────────────────────────
                  Text(
                    isEdit ? 'Modifier la session' : 'Nouvelle session',
                    style: const TextStyle(
                      fontSize:   17,
                      fontWeight: FontWeight.w700,
                      color:      _darkText,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Titre ────────────────────────────────────────────────
                  _FieldLabel('Titre *'),
                  _Field(controller: titreCtrl, hint: 'Ex: Session Chemlali'),

                  const SizedBox(height: 14),

                  // ── Date + Heure side by side ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Date *'),
                            _Field(
                              controller:   dateCtrl,
                              hint:         'JJ/MM/AAAA',
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                // auto-format DD/MM/YYYY
                                final digits = v.replaceAll('/', '');
                                String fmt = '';
                                for (int i = 0; i < digits.length && i < 8; i++) {
                                  if (i == 2 || i == 4) fmt += '/';
                                  fmt += digits[i];
                                }
                                if (fmt != v) {
                                  dateCtrl.value = TextEditingValue(
                                    text:      fmt,
                                    selection: TextSelection.collapsed(
                                        offset: fmt.length),
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
                            _FieldLabel('Heure *'),
                            _Field(
                              controller:   heureCtrl,
                              hint:         'HH:MM',
                              keyboardType: TextInputType.number,
                              onChanged: (v) {
                                // auto-format HH:MM
                                final digits = v.replaceAll(':', '');
                                String fmt = '';
                                for (int i = 0; i < digits.length && i < 4; i++) {
                                  if (i == 2) fmt += ':';
                                  fmt += digits[i];
                                }
                                if (fmt != v) {
                                  heureCtrl.value = TextEditingValue(
                                    text:      fmt,
                                    selection: TextSelection.collapsed(
                                        offset: fmt.length),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ── Lieu ─────────────────────────────────────────────────
                  _FieldLabel('Lieu *'),
                  _Field(
                      controller: lieuCtrl,
                      hint:       'Ex: Salle de dégustation A'),

                  const SizedBox(height: 14),

                  // ── Statut ───────────────────────────────────────────────
                  _FieldLabel('Statut'),
                  const SizedBox(height: 6),
                  Row(
                    children: StatutSession.values.map((s) {
                      final labels = {
                        StatutSession.planifiee: 'Planifiée',
                        StatutSession.enCours:   'En cours',
                        StatutSession.terminee:  'Terminée',
                      };
                      final isSelected = statut == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setSheetState(() => statut = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _green
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              labels[s]!,
                              style: TextStyle(
                                fontSize:   12,
                                fontWeight: FontWeight.w600,
                                color:      isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 14),

                  // ── Notes (optional) ─────────────────────────────────────
                  _FieldLabel('Notes (optionnel)'),
                  _Field(
                    controller: notesCtrl,
                    hint:       'Remarques, instructions...',
                    maxLines:   3,
                  ),

                  const SizedBox(height: 24),

                  // ── Annuler + Enregistrer ─────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _green,
                            side:    const BorderSide(color: _green),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape:   RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler',
                              style: TextStyle(fontWeight: FontWeight.w600)),
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
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape:   RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            isEdit ? 'Enregistrer' : 'Créer',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

// ── small helpers to keep the form code clean ─────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize:   12,
            fontWeight: FontWeight.w600,
            color:      _oliveGreen,
          ),
        ),
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
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          filled:    true,
          fillColor: const Color(0xFFF7FAF8),
          contentPadding: const EdgeInsets.symmetric(
              vertical: 12, horizontal: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   BorderSide(color: Colors.grey.shade200),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide:   const BorderSide(color: _green, width: 1.8),
          ),
        ),
      );
}
