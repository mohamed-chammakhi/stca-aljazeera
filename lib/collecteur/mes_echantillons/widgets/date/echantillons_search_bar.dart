// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/echantillons_search_bar.dart
//
// Search bar + status chips + optional date range filter.
// DateInputField is imported — no code duplication.
// The parent owns all filter state and passes it down via callbacks.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/echantillon_collecteur.dart';
import 'date_input_field.dart'; // ← reuses existing widget, no copy

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);

// ── Chip metadata ─────────────────────────────────────────────────────────────
class ChipData {
  final StatutCollecteur? statut;
  final String label;
  const ChipData(this.statut, this.label);
}

const List<ChipData> kFiltreChips = [
  ChipData(null, 'Tous'),
  ChipData(StatutCollecteur.enTraitement, 'En traitement'),
  ChipData(StatutCollecteur.valideANegocier, 'Validé — À négocier'),
  ChipData(StatutCollecteur.achatConfirme, 'Achat confirmé'),
  ChipData(StatutCollecteur.refuse, 'Refusés'),
];

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class EchantillonsSearchBar extends StatefulWidget {
  /// Text search — controlled by parent.
  final TextEditingController searchController;

  /// Active status chip — null means "Tous".
  final StatutCollecteur? filtreStatut;

  /// Date range — both controlled by parent so the page can filter with them.
  final TextEditingController dateDebutController;
  final TextEditingController dateFinController;

  final ValueChanged<String> onRechercheChanged;
  final ValueChanged<StatutCollecteur?> onFiltreChanged;

  /// Called whenever either date field changes so the page can re-filter.
  final VoidCallback onDateChanged;

  const EchantillonsSearchBar({
    super.key,
    required this.searchController,
    required this.filtreStatut,
    required this.dateDebutController,
    required this.dateFinController,
    required this.onRechercheChanged,
    required this.onFiltreChanged,
    required this.onDateChanged,
  });

  @override
  State<EchantillonsSearchBar> createState() => _EchantillonsSearchBarState();
}

class _EchantillonsSearchBarState extends State<EchantillonsSearchBar> {
  /// Whether the date range panel is expanded.
  bool _showDateFilter = false;

  /// True when at least one date field has content.
  bool get _hasDateFilter =>
      widget.dateDebutController.text.isNotEmpty ||
      widget.dateFinController.text.isNotEmpty;

  void _clearDates() {
    widget.dateDebutController.clear();
    widget.dateFinController.clear();
    widget.onDateChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Text search bar ────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: widget.searchController,
            onChanged: widget.onRechercheChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Rechercher par référence, fournisseur, région...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: _green, size: 20),
              suffixIcon: widget.searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        widget.searchController.clear();
                        widget.onRechercheChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _green, width: 1.5),
              ),
            ),
          ),
        ),

        // ── Status chips + date toggle button on the same row ──────────────
        SizedBox(
          height: 44,
          child: Row(
            children: [
              // Scrollable chips take all available space
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16),
                  itemCount: kFiltreChips.length,
                  itemBuilder: (_, i) {
                    final chip = kFiltreChips[i];
                    final isSelected = widget.filtreStatut == chip.statut;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => widget.onFiltreChanged(chip.statut),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? _green : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _green : Colors.grey.shade200,
                            ),
                          ),
                          child: Text(
                            chip.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Date filter toggle — badge dot when a date is active
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 4),
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showDateFilter = !_showDateFilter),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _showDateFilter
                              ? _green
                              : _hasDateFilter
                              ? _green.withValues(alpha: 0.12)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: (_showDateFilter || _hasDateFilter)
                                ? _green
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Icon(
                          Icons.date_range_outlined,
                          size: 18,
                          color: _showDateFilter
                              ? Colors.white
                              : _hasDateFilter
                              ? _green
                              : Colors.grey.shade500,
                        ),
                      ),
                      // Active indicator dot
                      if (_hasDateFilter && !_showDateFilter)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Date range panel — shown only when toggled open ────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _showDateFilter
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header + clear button
                      Row(
                        children: [
                          const Text(
                            'Filtrer par date',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _oliveGreen,
                            ),
                          ),
                          const Spacer(),
                          if (_hasDateFilter)
                            GestureDetector(
                              onTap: _clearDates,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.close,
                                    size: 13,
                                    color: Colors.grey.shade500,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Effacer les dates',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Two DateInputFields side by side
                      // DateInputField already handles formatting + picker ✓
                      Row(
                        children: [
                          Expanded(
                            child: _DateFieldWrapper(
                              label: 'Du',
                              controller: widget.dateDebutController,
                              onChanged: widget.onDateChanged,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateFieldWrapper(
                              label: 'Au',
                              controller: widget.dateFinController,
                              onChanged: widget.onDateChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPER — wraps DateInputField with a custom label and onChange hook
//
// DateInputField exposes its own label ("Date d'arrivée") which we override
// here with "Du" / "Au". We wrap rather than modify the original file.
// ─────────────────────────────────────────────────────────────────────────────
class _DateFieldWrapper extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;

  const _DateFieldWrapper({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_DateFieldWrapper> createState() => _DateFieldWrapperState();
}

class _DateFieldWrapperState extends State<_DateFieldWrapper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_notify);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_notify);
    super.dispose();
  }

  void _notify() => widget.onChanged();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _oliveGreen,
          ),
        ),
        const SizedBox(height: 6),
        // DateInputField renders the text field + calendar button.
        // Its own "Date d'arrivée" label is hidden because we render
        // our own label above — pass a controller and let it do the rest.
        DateInputField(controller: widget.controller),
      ],
    );
  }
}
