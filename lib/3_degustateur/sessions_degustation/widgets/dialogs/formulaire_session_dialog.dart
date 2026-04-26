// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/widgets/dialogs/formulaire_session_dialog.dart
// PURPOSE : bottom sheet form to CREATE or EDIT a tasting session
// USAGE   : showFormulaireSessionDialog(context, session: null, ...)  ← add
//           showFormulaireSessionDialog(context, session: s,    ...)  ← edit
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_degustation.dart';
import '../../../membres_panel/models/membre_panel.dart';
import '../../../membres_panel/services/membres_panel_service.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _fieldFill = Color(0xFFF7FAF8);

// Section accent colors
const Color _sectionSession = Color(0xFF38835A); // green

// ─────────────────────────────────────────────────────────────────────────────
// SCROLL-WHEEL TIME SHEET  (AM/PM)
// ─────────────────────────────────────────────────────────────────────────────
Future<TimeOfDay?> _showScrollTimeSheet(
  BuildContext context, {
  TimeOfDay? initial,
}) async {
  int selectedHour = initial?.hourOfPeriod ?? 9;
  if (selectedHour == 0) selectedHour = 12;
  int selectedMinute = initial?.minute ?? 0;
  int selectedPeriod = (initial?.period == DayPeriod.pm) ? 1 : 0;

  const int hourRepeat = 200;
  const int minRepeat = 200;
  final hourCtrl = FixedExtentScrollController(
    initialItem: 12 * (hourRepeat ~/ 2) + (selectedHour - 1),
  );
  final minCtrl = FixedExtentScrollController(
    initialItem: 60 * (minRepeat ~/ 2) + selectedMinute,
  );
  final periodCtrl = FixedExtentScrollController(initialItem: selectedPeriod);

  final result = await showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, color: _green, size: 18),
                const SizedBox(width: 8),
                const Text(
                  "Heure de la session",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _green.withValues(alpha: 0.18)),
                    ),
                  ),
                  Row(
                    children: [
                      // AM / PM
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView.useDelegate(
                          controller: periodCtrl,
                          itemExtent: 44,
                          diameterRatio: 1.6,
                          perspective: 0.002,
                          overAndUnderCenterOpacity: 0.35,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedPeriod = i),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 2,
                            builder: (_, i) => Center(
                              child: Text(
                                i == 0 ? 'AM' : 'PM',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: i == selectedPeriod
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: i == selectedPeriod
                                      ? _dark
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Hours
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView.useDelegate(
                          controller: hourCtrl,
                          itemExtent: 44,
                          diameterRatio: 1.6,
                          perspective: 0.002,
                          overAndUnderCenterOpacity: 0.35,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedHour = (i % 12) + 1),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 12 * hourRepeat,
                            builder: (_, i) {
                              final h = (i % 12) + 1;
                              final sel = h == selectedHour;
                              return Center(
                                child: Text(
                                  h.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: sel ? _dark : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const Text(
                        ':',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                      // Minutes
                      Expanded(
                        flex: 3,
                        child: ListWheelScrollView.useDelegate(
                          controller: minCtrl,
                          itemExtent: 44,
                          diameterRatio: 1.6,
                          perspective: 0.002,
                          overAndUnderCenterOpacity: 0.35,
                          physics: const FixedExtentScrollPhysics(),
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedMinute = i % 60),
                          childDelegate: ListWheelChildBuilderDelegate(
                            childCount: 60 * minRepeat,
                            builder: (_, i) {
                              final m = i % 60;
                              final sel = m == selectedMinute;
                              return Center(
                                child: Text(
                                  m.toString().padLeft(2, '0'),
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: sel
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                    color: sel ? _dark : Colors.grey.shade400,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  int hour24 = selectedHour % 12;
                  if (selectedPeriod == 1) hour24 += 12;
                  Navigator.pop(
                    ctx,
                    TimeOfDay(hour: hour24, minute: selectedMinute),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Confirmer',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  hourCtrl.dispose();
  minCtrl.dispose();
  periodCtrl.dispose();
  return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Parse 'DD/MM/YYYY' → DateTime
DateTime? _parseDdMmYyyy(String s) {
  try {
    final p = s.split('/');
    if (p.length != 3) return null;
    return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
  } catch (_) {
    return null;
  }
}

/// Parse 'HH:MM' → TimeOfDay
TimeOfDay? _parseHhMm(String s) {
  try {
    final p = s.split(':');
    if (p.length != 2) return null;
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  } catch (_) {
    return null;
  }
}

String _fmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String _fmtTime(TimeOfDay t) {
  final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
  final m = t.minute.toString().padLeft(2, '0');
  final period = t.period == DayPeriod.am ? 'AM' : 'PM';
  return '${h.toString().padLeft(2, '0')}:$m $period';
}

/// 12-hour display → 24-hour 'HH:MM' for storage
String _fmtTimeStorage(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

// ═════════════════════════════════════════════════════════════════════════════
// PUBLIC ENTRY POINT
// ═════════════════════════════════════════════════════════════════════════════

Future<void> showFormulaireSessionDialog(
  BuildContext context, {
  required SessionDegustation? session,
  required int prochainNumero,
  required ValueChanged<SessionDegustation> onSave,
}) async {
  final membres = await MembresPanelService().fetchMembres();
  if (!context.mounted) return;
  final isEdit = session != null;

  final titreCtrl = TextEditingController(text: isEdit ? session.titre : '');
  final lieuCtrl = TextEditingController(text: isEdit ? session.lieu : '');
  final notesCtrl = TextEditingController(
    text: isEdit ? (session.notes ?? '') : '',
  );
  final nbEchantillonsCtrl = TextEditingController(
    text: isEdit && session.nombreEchantillonsPrevus != null
        ? session.nombreEchantillonsPrevus.toString()
        : '',
  );

  // Parse existing date/time for edit mode
  DateTime? pickedDate = isEdit ? _parseDdMmYyyy(session.date) : null;
  TimeOfDay? pickedTime = isEdit ? _parseHhMm(session.heure) : null;

  // Statut: always planifiée for new sessions
  StatutSession statut = (isEdit && session.statut == StatutSession.terminee)
      ? StatutSession.terminee
      : StatutSession.planifiee;

  // Participants: pre-fill from session when editing
  List<String> selectedParticipantIds = isEdit
      ? List.from(session.participantIds)
      : [];

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        Future<void> pickDate() async {
          final date = await showDatePicker(
            context: ctx,
            initialDate: pickedDate ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2130),
            initialEntryMode: DatePickerEntryMode.calendarOnly,
            builder: (c, child) => Theme(
              data: Theme.of(c).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: _green,
                  onPrimary: Colors.white,
                  onSurface: _dark,
                ),
              ),
              child: child!,
            ),
          );
          if (date != null) setSheetState(() => pickedDate = date);
        }

        Future<void> pickTime() async {
          final time = await _showScrollTimeSheet(ctx, initial: pickedTime);
          if (time != null) setSheetState(() => pickedTime = time);
        }

        Future<void> pickParticipants() async {
          // Work on a local copy — committed only on "Confirmer"
          List<String> temp = List.from(selectedParticipantIds);

          await showModalBottomSheet(
            context: ctx,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => StatefulBuilder(
              builder: (_, setInner) => Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.group_outlined,
                          color: _green,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Sélectionner les participants',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _dark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...membres.map((m) {
                      final selected = temp.contains(m.id);
                      return InkWell(
                        onTap: () => setInner(() {
                          if (selected) {
                            temp.remove(m.id);
                          } else {
                            temp.add(m.id);
                          }
                        }),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: selected ? _green : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? _green
                                        : Colors.grey.shade400,
                                    width: 1.8,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: selected
                                    ? const Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                m.nomComplet,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: _dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7F3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: _green.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 7),
                          const Expanded(
                            child: Text(
                              'Si aucun participant n\'est sélectionné, tous les membres du panel seront notifiés.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A6B55),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setSheetState(
                            () => selectedParticipantIds = List.from(temp),
                          );
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Confirmer',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        void handleSave() {
          if (titreCtrl.text.trim().isEmpty ||
              pickedDate == null ||
              pickedTime == null ||
              lieuCtrl.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'Veuillez remplir tous les champs obligatoires',
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

          final dateStr = _fmtDate(pickedDate!);
          final heureStr = _fmtTimeStorage(pickedTime!);

          final nbEch = int.tryParse(nbEchantillonsCtrl.text.trim());

          final nomsList = selectedParticipantIds.isEmpty
              ? null
              : selectedParticipantIds
                    .map(
                      (id) => membres.firstWhere((m) => m.id == id).nomComplet,
                    )
                    .toList();

          if (isEdit) {
            session
              ..titre = titreCtrl.text.trim()
              ..date = dateStr
              ..heure = heureStr
              ..lieu = lieuCtrl.text.trim()
              ..statut = statut
              ..notes = notesCtrl.text.trim().isEmpty
                  ? null
                  : notesCtrl.text.trim()
              ..nombreEchantillonsPrevus = nbEch
              ..participantIds = selectedParticipantIds;
            onSave(session);
          } else {
            onSave(
              SessionDegustation(
                id: 'SES-${prochainNumero.toString().padLeft(3, '0')}',
                titre: titreCtrl.text.trim(),
                date: dateStr,
                heure: heureStr,
                lieu: lieuCtrl.text.trim(),
                statut: StatutSession.planifiee,
                notes: notesCtrl.text.trim().isEmpty
                    ? null
                    : notesCtrl.text.trim(),
                nombreEchantillonsPrevus: nbEch,
                participantIds: selectedParticipantIds,
                participantNoms: nomsList,
                createdBy:
                    'mock-user-001', // TODO: replace with logged-in user ID
                createdAt: DateTime.now().toIso8601String(),
              ),
            );
          }

          Navigator.pop(ctx);
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Drag handle ────────────────────────────────────────
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

                  // ── Sheet title ────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 22,
                        decoration: BoxDecoration(
                          color: _green,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isEdit ? 'Modifier la session' : 'Nouvelle session',
                        style: GoogleFonts.domine(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Titre ─────────────────────────────────────────────
                  _FieldLabel('Titre de la session *', _sectionSession),
                  _Field(
                    controller: titreCtrl,
                    hint: 'Ex : Session Chemlali - Lot A',
                  ),

                  const SizedBox(height: 18),

                  // ── Date & Heure ──────────────────────────────────────
                  Row(
                    children: [
                      // Date picker button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Date *', _sectionSession),
                            _PickerButton(
                              icon: Icons.calendar_today_outlined,
                              label: pickedDate != null
                                  ? _fmtDate(pickedDate!)
                                  : 'JJ/MM/AAAA',
                              isEmpty: pickedDate == null,
                              onTap: pickDate,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Time picker button
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Heure *', _sectionSession),
                            _PickerButton(
                              icon: Icons.access_time_outlined,
                              label: pickedTime != null
                                  ? _fmtTime(pickedTime!)
                                  : '--:-- --',
                              isEmpty: pickedTime == null,
                              onTap: pickTime,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Lieu ──────────────────────────────────────────────
                  _FieldLabel('Salle / Emplacement *', _sectionSession),
                  _Field(
                    controller: lieuCtrl,
                    hint: 'Ex : Salle de dégustation A',
                  ),

                  const SizedBox(height: 18),

                  // ── Nombre d'échantillons ─────────────────────────────
                  _FieldLabel(
                    'Nombre d\'échantillons (optionnel)',
                    _sectionSession,
                  ),
                  _Field(
                    controller: nbEchantillonsCtrl,
                    hint: 'Ex : 6',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 18),

                  // ── Notes ─────────────────────────────────────────────
                  _FieldLabel('Notes (optionnel)', _sectionSession),
                  _Field(
                    controller: notesCtrl,
                    hint: 'Remarques, instructions, matériel…',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 18),

                  // ── Participants ──────────────────────────────────────
                  _FieldLabel('Participants (optionnel)', _sectionSession),
                  _PickerButton(
                    icon: Icons.group_outlined,
                    label: selectedParticipantIds.isEmpty
                        ? 'Tous les membres du panel (par défaut)'
                        : '${selectedParticipantIds.length} participant${selectedParticipantIds.length > 1 ? "s" : ""} sélectionné${selectedParticipantIds.length > 1 ? "s" : ""}',
                    isEmpty: selectedParticipantIds.isEmpty,
                    onTap: pickParticipants,
                  ),
                  if (selectedParticipantIds.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: selectedParticipantIds.map((id) {
                        final nom = membres
                            .firstWhere((m) => m.id == id)
                            .nomComplet;
                        return Container(
                          padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
                          decoration: BoxDecoration(
                            color: _green.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _green.withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                nom,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _dark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () => setSheetState(
                                  () => selectedParticipantIds.remove(id),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 13,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 26),

                  // ── Actions ───────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _green,
                            side: const BorderSide(color: _green),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Annuler',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            isEdit ? 'Enregistrer' : 'Créer la session',
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

// ─────────────────────────────────────────────────────────────────────────────
// PICKER BUTTON — tappable field that looks like a text field
// ─────────────────────────────────────────────────────────────────────────────
class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isEmpty;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.isEmpty,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: isEmpty ? Colors.grey.shade400 : _green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w600,
                color: isEmpty ? Colors.grey.shade400 : _dark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD LABEL
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _FieldLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    onChanged: onChanged,
    style: const TextStyle(fontSize: 14, color: _dark),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
        borderSide: const BorderSide(color: _green, width: 1.8),
      ),
    ),
  );
}
