// ═════════════════════════════════════════════════════════════════════════════
// FILE    : gestion_echantillons/widgets/search_filter_bar.dart
// PURPOSE : shared search + statut chip bar used by sessions + analyse pages
//           date filtering is handled separately via DateFilterButton +
//           DateFilterSheet (AppBar pattern, matching 1_ceo module)
//
// EXPORTS :
//   SearchFilterBar   — green bar with search input + statut chips
//   DateFilterButton  — AppBar action button (calendar icon / date text when active)
//   DateFilterSheet   — bottom sheet with "Jour exact" / "Période" mode toggle
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/widgets/filtre_chip.dart';
import '../../widgets/chef_colors.dart';

const Color _oliveGreen = Color(0xFF6B8143);
const Color _cream      = Color(0xFFF9F6EF);

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH + STATUT FILTER BAR
// search input + scrollable statut chips — date is handled in AppBar separately
// ─────────────────────────────────────────────────────────────────────────────
class SearchFilterBar extends StatelessWidget {

  final String                recherche;
  final TextEditingController controller;
  final String?               filtreStatut;
  final List<String>          statutLabels;

  final ValueChanged<String>  onRechercheChanged;
  final VoidCallback          onRechercheClear;
  final ValueChanged<String?> onStatutChanged;

  const SearchFilterBar({
    super.key,
    required this.recherche,
    required this.controller,
    required this.filtreStatut,
    required this.onRechercheChanged,
    required this.onRechercheClear,
    required this.onStatutChanged,
    this.statutLabels = const ['En attente', 'En cours', 'Soumis'],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   chefGreen,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [

          // ── SEARCH BAR ───────────────────────────────────────────────────
          TextField(
            controller: controller,
            onChanged:  onRechercheChanged,
            style: const TextStyle(color: chefDark, fontSize: 14),
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

          // ── STATUT CHIPS ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FiltreChip(
                  label:      'Tous',
                  isSelected: filtreStatut == null,
                  onTap:      () => onStatutChanged(null),
                ),
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
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE FILTER BUTTON  (AppBar action) — matching 1_ceo pattern
// shows calendar icon when inactive; white pill with date text when active
// ─────────────────────────────────────────────────────────────────────────────
class DateFilterButton extends StatelessWidget {
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onTap;

  const DateFilterButton({
    super.key,
    required this.dateDebut,
    required this.dateFin,
    required this.onTap,
  });

  bool get _active => dateDebut != null;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: _active ? Colors.white : Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _active
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size:  15,
              color: _active ? chefGreen : Colors.white,
            ),
            if (_active) ...[
              const SizedBox(width: 5),
              Text(
                dateFin != null
                    ? '${_fmt(dateDebut!)} → ${_fmt(dateFin!)}'
                    : _fmt(dateDebut!),
                style: const TextStyle(
                  fontSize:   10,
                  fontWeight: FontWeight.w700,
                  color:      chefGreen,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE FILTER SHEET — "Jour exact" / "Période" mode toggle (matching 1_ceo)
// ─────────────────────────────────────────────────────────────────────────────
class DateFilterSheet extends StatefulWidget {
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final void Function(DateTime debut, DateTime? fin) onApply;
  final VoidCallback onClear;

  const DateFilterSheet({
    super.key,
    required this.dateDebut,
    required this.dateFin,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<DateFilterSheet> createState() => _DateFilterSheetState();
}

class _DateFilterSheetState extends State<DateFilterSheet> {
  late DateTime? _debut;
  late DateTime? _fin;
  bool _isRange = false;

  @override
  void initState() {
    super.initState();
    _debut   = widget.dateDebut;
    _fin     = widget.dateFin;
    _isRange = widget.dateFin != null;
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Future<void> _pickDate(bool isDebut) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isDebut ? _debut : _fin) ?? DateTime.now(),
      firstDate:   DateTime(2020),
      lastDate:    DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary:   chefGreen,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => isDebut ? _debut = picked : _fin = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color:        _cream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize:      MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(children: [
            const Icon(Icons.calendar_today_outlined, size: 16, color: chefGreen),
            const SizedBox(width: 8),
            Text(
              'Filtrer par date',
              style: GoogleFonts.domine(
                fontSize:   17,
                fontWeight: FontWeight.w700,
                color:      chefDark,
              ),
            ),
          ]),
          const SizedBox(height: 16),

          // mode toggle
          Container(
            decoration: BoxDecoration(
              color:        Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(children: [
              _ModeSegment(
                label:    'Jour exact',
                selected: !_isRange,
                onTap:    () => setState(() {
                  _isRange = false;
                  _fin     = null;
                }),
              ),
              _ModeSegment(
                label:    'Période',
                selected: _isRange,
                onTap:    () => setState(() => _isRange = true),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // date picker(s)
          GestureDetector(
            onTap: () => _pickDate(true),
            child: _DatePickerField(
              label: _isRange ? 'Du' : 'Date',
              value: _debut != null ? _fmtDate(_debut!) : null,
            ),
          ),
          if (_isRange) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _pickDate(false),
              child: _DatePickerField(
                label: 'Au',
                value: _fin != null ? _fmtDate(_fin!) : null,
              ),
            ),
          ],
          const SizedBox(height: 20),

          // buttons
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  side:    BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape:   RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Effacer'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _debut == null
                    ? null
                    : () {
                        widget.onApply(_debut!, _isRange ? _fin : null);
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: chefGreen,
                  foregroundColor: Colors.white,
                  padding:   const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'Appliquer',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

// ── private helpers ───────────────────────────────────────────────────────────

class _ModeSegment extends StatelessWidget {
  final String       label;
  final bool         selected;
  final VoidCallback onTap;
  const _ModeSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color:        selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow:    selected
              ? [BoxShadow(
                  color:      chefDark.withValues(alpha: 0.07),
                  blurRadius: 4,
                  offset:     const Offset(0, 1),
                )]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize:   12,
              fontWeight: FontWeight.w600,
              color: selected ? chefDark : Colors.grey.shade500,
            ),
          ),
        ),
      ),
    ),
  );
}

class _DatePickerField extends StatelessWidget {
  final String  label;
  final String? value;
  const _DatePickerField({required this.label, this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: value != null ? chefGreen : Colors.grey.shade200,
        width: value != null ? 1.5   : 1,
      ),
    ),
    child: Row(children: [
      Icon(
        Icons.calendar_today_outlined,
        size:  16,
        color: value != null ? chefGreen : Colors.grey.shade400,
      ),
      const SizedBox(width: 10),
      Text(
        '$label : ',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
      Text(
        value ?? 'Choisir une date',
        style: TextStyle(
          fontSize:   13,
          fontWeight: value != null ? FontWeight.w700 : FontWeight.w400,
          color:      value != null ? chefDark : Colors.grey.shade400,
        ),
      ),
    ]),
  );
}
