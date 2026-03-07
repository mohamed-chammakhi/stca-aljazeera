// ═════════════════════════════════════════════════════════════════════════════
// FILE    : gestion_echantillons/widgets/search_filter_bar.dart
// PURPOSE : shared search + filter bar used by ALL list pages
//           — text search bar
//           — statut chips  ← labels are CONFIGURABLE via statutLabels param
//           — date range bottom sheet (Du + Au, calendarOnly pickers)
//           — active date label + clear button
//
// USED BY :
//   - gestion_echantillons_page.dart   (labels: En attente / En cours / Soumis)
//   - evaluation_echantillons_page.dart (same labels)
//   - sessions_degustation_page.dart   (labels: Planifiée / En cours / Terminée)
//
// IMPORTANT : this widget holds NO state of its own
//             all values come IN via params, all changes go OUT via callbacks
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'filtre_chip.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

class SearchFilterBar extends StatelessWidget {

  // ── incoming values ───────────────────────────────────────────────────────
  final String                recherche;
  final TextEditingController controller;
  final String?               filtreStatut;
  final DateTime?             dateDebut;
  final DateTime?             dateFin;

  // chip labels — configurable so each page can use its own statut vocabulary
  // defaults to gestion/evaluation labels if not provided
  final List<String> statutLabels;

  // ── outgoing callbacks ────────────────────────────────────────────────────
  final ValueChanged<String>           onRechercheChanged;
  final VoidCallback                   onRechercheClear;
  final ValueChanged<String?>          onStatutChanged;
  final Function(DateTime?, DateTime?) onDateChanged;
  final VoidCallback                   onDateClear;

  const SearchFilterBar({
    super.key,
    required this.recherche,
    required this.controller,
    required this.filtreStatut,
    required this.dateDebut,
    required this.dateFin,
    required this.onRechercheChanged,
    required this.onRechercheClear,
    required this.onStatutChanged,
    required this.onDateChanged,
    required this.onDateClear,
    // default labels match gestion + evaluation pages
    this.statutLabels = const ['En attente', 'En cours', 'Soumis'],
  });

  bool get _dateFilterActive => dateDebut != null || dateFin != null;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  // ── opens one calendarOnly date picker ────────────────────────────────────
  Future<DateTime?> _pickSingleDate(BuildContext context,
      {DateTime? initial}) =>
      showDatePicker(
        context:          context,
        initialDate:      initial ?? DateTime.now(),
        firstDate:        DateTime(2000),
        lastDate:         DateTime(2126),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
        builder: (ctx, child) => Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(
              primary:   _green,
              onPrimary: Colors.white,
              onSurface: _darkText,
            ),
          ),
          child: child!,
        ),
      );

  // ── opens bottom sheet with Du + Au pickers ───────────────────────────────
  void _showDateRangeSheet(BuildContext context) {
    DateTime? tmpDebut = dateDebut;
    DateTime? tmpFin   = dateFin;

    showModalBottomSheet(
      context:            context,
      isScrollControlled: true,
      backgroundColor:    Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheetState) {

          Future<void> pickDebut() async {
            final picked =
                await _pickSingleDate(context, initial: tmpDebut);
            if (picked == null) return;
            setSheetState(() {
              tmpDebut = picked;
              if (tmpFin != null && tmpFin!.isBefore(picked)) tmpFin = picked;
            });
          }

          Future<void> pickFin() async {
            final picked = await _pickSingleDate(
              context,
              initial: tmpFin ?? tmpDebut ?? DateTime.now(),
            );
            if (picked == null) return;
            setSheetState(() {
              tmpFin = picked;
              if (tmpDebut != null && picked.isBefore(tmpDebut!)) {
                tmpDebut = picked;
              }
            });
          }

          return Container(
            decoration: const BoxDecoration(
              color:        Colors.white,
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
                    color:        Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                const SizedBox(height: 20),

                // title
                Row(
                  children: [
                    const Icon(Icons.date_range_outlined,
                        color: _green, size: 20),
                    const SizedBox(width: 8),
                    Text('Filtrer par période',
                        style: TextStyle(
                            fontSize:   16,
                            fontWeight: FontWeight.w700,
                            color:      _darkText)),
                  ],
                ),

                const SizedBox(height: 20),

                // Du + Au buttons
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                          label: 'Du', date: tmpDebut,
                          onTap: pickDebut, fmt: _fmt),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.arrow_forward,
                        color: _oliveGreen, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateButton(
                          label: 'Au', date: tmpFin,
                          onTap: pickFin, fmt: _fmt),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Effacer + Appliquer
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          onDateClear();
                          Navigator.pop(ctx);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _green,
                          side:    const BorderSide(color: _green),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape:   RoundedRectangleBorder(
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
                                onDateChanged(tmpDebut, tmpFin ?? tmpDebut);
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
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   _green,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [

          // ── SEARCH BAR ───────────────────────────────────────────────────
          TextField(
            controller: controller,
            onChanged:  onRechercheChanged,
            style: const TextStyle(color: _darkText, fontSize: 14),
            decoration: InputDecoration(
              hintText:  'Rechercher...',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: _oliveGreen),
              suffixIcon: recherche.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: _oliveGreen),
                      onPressed: onRechercheClear,
                    )
                  : null,
              filled:    true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:   BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── STATUT CHIPS + 📅 DATE BUTTON ────────────────────────────────
          Row(
            children: [

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [

                      // "Tous" chip — always first
                      FiltreChip(
                        label:      'Tous',
                        isSelected: filtreStatut == null,
                        onTap:      () => onStatutChanged(null),
                      ),

                      // dynamic chips from statutLabels
                      ...statutLabels.map((label) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FiltreChip(
                              label:      label,
                              isSelected: filtreStatut == label,
                              onTap:      () => onStatutChanged(label),
                            ),
                          )),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // 📅 date range button
              GestureDetector(
                onTap: () => _showDateRangeSheet(context),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _dateFilterActive
                            ? Colors.white
                            : Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _dateFilterActive
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.date_range_outlined,
                        color: _dateFilterActive ? _green : Colors.white,
                        size: 20,
                      ),
                    ),
                    if (_dateFilterActive)
                      Positioned(
                        top: -4, right: -4,
                        child: Container(
                          width: 10, height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // ── ACTIVE DATE LABEL + CLEAR ─────────────────────────────────────
          if (_dateFilterActive) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.filter_alt_outlined,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  dateDebut != null &&
                          dateFin  != null &&
                          dateDebut!.isAtSameMomentAs(dateFin!)
                      ? 'Le ${_fmt(dateDebut!)}'
                      : 'Du ${_fmt(dateDebut!)}  →  ${_fmt(dateFin!)}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onDateClear,
                  child: const Icon(Icons.close,
                      color: Colors.white70, size: 16),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── date button used inside the bottom sheet ──────────────────────────────────
class _DateButton extends StatelessWidget {
  final String    label;
  final DateTime? date;
  final VoidCallback onTap;
  final String Function(DateTime) fmt;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color:        hasDate ? _green.withOpacity(0.07) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(
            color: hasDate ? _green : Colors.grey.shade300,
            width: hasDate ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize:   11,
                    color:      hasDate ? _green : Colors.grey.shade500,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(
              hasDate ? fmt(date!) : 'Choisir...',
              style: TextStyle(
                  fontSize:   13,
                  fontWeight: FontWeight.w700,
                  color:      hasDate ? _darkText : Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}
