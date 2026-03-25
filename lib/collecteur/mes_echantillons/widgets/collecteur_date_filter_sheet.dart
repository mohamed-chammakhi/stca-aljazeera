// ─────────────────────────────────────────────────────────────────────────────
// FILE : collecteur/pages/mes_echantillons/widgets/collecteur_date_filter_sheet.dart
//
// Standalone date-range bottom sheet used by MesEchantillonsPage.
// Owns no state — all values come IN, all changes go OUT via callbacks.
//
// Usage:
//   showCollecteurDateFilterSheet(
//     context,
//     dateDebut: _dateDebut,
//     dateFin:   _dateFin,
//     onApply:   (debut, fin) => setState(() { _dateDebut = debut; _dateFin = fin; }),
//     onClear:   ()           => setState(() { _dateDebut = null;  _dateFin = null; }),
//   );
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

void showCollecteurDateFilterSheet(
  BuildContext context, {
  required DateTime? dateDebut,
  required DateTime? dateFin,
  required void Function(DateTime? debut, DateTime? fin) onApply,
  required VoidCallback onClear,
}) {
  DateTime? tmpDebut = dateDebut;
  DateTime? tmpFin   = dateFin;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheet) {

        Future<DateTime?> pickDate({DateTime? initial}) => showDatePicker(
              context: context,
              initialDate: initial ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2126),
              initialEntryMode: DatePickerEntryMode.calendarOnly,
              builder: (c, child) => Theme(
                data: Theme.of(c).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: _green,
                    onPrimary: Colors.white,
                    onSurface: _darkText,
                  ),
                ),
                child: child!,
              ),
            );

        Future<void> pickDebut() async {
          final picked = await pickDate(initial: tmpDebut);
          if (picked == null) return;
          setSheet(() {
            tmpDebut = picked;
            if (tmpFin != null && tmpFin!.isBefore(picked)) tmpFin = picked;
          });
        }

        Future<void> pickFin() async {
          final picked =
              await pickDate(initial: tmpFin ?? tmpDebut ?? DateTime.now());
          if (picked == null) return;
          setSheet(() {
            tmpFin = picked;
            if (tmpDebut != null && picked.isBefore(tmpDebut!)) {
              tmpDebut = picked;
            }
          });
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // title
              Row(children: [
                const Icon(Icons.date_range_outlined, color: _green, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Filtrer par période',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ]),
              const SizedBox(height: 20),

              // Du + Au
              Row(children: [
                Expanded(child: _DateBtn(label: 'Du',  date: tmpDebut, onTap: pickDebut)),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward, color: _oliveGreen, size: 18),
                const SizedBox(width: 12),
                Expanded(child: _DateBtn(label: 'Au',  date: tmpFin,   onTap: pickFin)),
              ]),
              const SizedBox(height: 24),

              // Effacer + Appliquer
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onClear();
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _green,
                      side: const BorderSide(color: _green),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Effacer',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: tmpDebut == null && tmpFin == null
                        ? null
                        : () {
                            onApply(tmpDebut, tmpFin ?? tmpDebut);
                            Navigator.pop(ctx);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Appliquer',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ]),
            ],
          ),
        );
      },
    ),
  );
}

// ── Date button ───────────────────────────────────────────────────────────────
class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateBtn({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final has = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: has ? _green.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: has ? _green : Colors.grey.shade300,
            width: has ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: has ? _green : Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              has ? _fmt(date!) : 'Choisir...',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: has ? _darkText : Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
