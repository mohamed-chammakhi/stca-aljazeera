// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/formulaire_sections.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bouteille_row.dart';
import 'formulaire_decorations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ID BADGE
// ─────────────────────────────────────────────────────────────────────────────
class IdBadgeSection extends StatelessWidget {
  final int prochainNumero;
  final int bottleCount;

  const IdBadgeSection({
    super.key,
    required this.prochainNumero,
    required this.bottleCount,
  });

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final from = prochainNumero.toString().padLeft(4, '0');
    final to = (prochainNumero + bottleCount - 1).toString().padLeft(4, '0');
    final label = bottleCount > 1
        ? 'IDs : $year/$from → $to'
        : 'ID : $year/$from';

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kGreen.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tag_rounded, color: kGreen, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.domine(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: kGreen,
            ),
          ),
          const Spacer(),
          Text(
            'Auto-généré',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHOTO SECTION
// ─────────────────────────────────────────────────────────────────────────────
class PhotoSection extends StatelessWidget {
  final String? photoUrl;
  final VoidCallback onTap;

  const PhotoSection({super.key, required this.photoUrl, required this.onTap});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel(label: 'Photo de la bouteille'),
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 72,
          decoration: BoxDecoration(
            color: kGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kGreen.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_a_photo_outlined,
                color: kGreen.withValues(alpha: 0.6),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                photoUrl != null
                    ? 'Photo sélectionnée ✓'
                    : 'Prendre une photo (optionnel)',
                style: TextStyle(
                  fontSize: 13,
                  color: kGreen.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION CASCADE SECTION
// ─────────────────────────────────────────────────────────────────────────────
class LocationCascadeSection extends StatelessWidget {
  final bool geoLoaded;
  final String? gouvernorat;
  final String? delegation;
  final List<String> gouvernorats;
  final List<String> delegationOptions;
  final ValueChanged<String?> onGouvernoratChanged;
  final ValueChanged<String?> onDelegationChanged;

  const LocationCascadeSection({
    super.key,
    required this.geoLoaded,
    required this.gouvernorat,
    required this.delegation,
    required this.gouvernorats,
    required this.delegationOptions,
    required this.onGouvernoratChanged,
    required this.onDelegationChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CascadeDropdown(
        label: 'Gouvernorat *',
        hint: 'Sélectionner un gouvernorat',
        disabledHint: 'Chargement...',
        icon: Icons.location_on_outlined,
        value: gouvernorat,
        options: geoLoaded ? gouvernorats : [],
        enabled: geoLoaded,
        onChanged: onGouvernoratChanged,
      ),
      if (!geoLoaded) ...[
        const SizedBox(height: 6),
        Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: kGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Chargement des gouvernorats...',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 12),
      _CascadeDropdown(
        label: 'Délégation (optionnel)',
        hint: 'Sélectionner une délégation',
        disabledHint: "Sélectionner d'abord un gouvernorat",
        icon: Icons.place_outlined,
        value: delegation,
        options: delegationOptions,
        enabled: gouvernorat != null && delegationOptions.isNotEmpty,
        onChanged: onDelegationChanged,
        includeNonPrecise: true,
      ),
      if (delegation != null && delegation != 'Non précisée') ...[
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.map_outlined,
              size: 13,
              color: kGreen.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Cette délégation sera colorée sur la carte ✓',
              style: TextStyle(
                fontSize: 11,
                color: kGreen.withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ],
    ],
  );
}

class _CascadeDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String disabledHint;
  final IconData icon;
  final String? value;
  final List<String> options;
  final bool enabled;
  final ValueChanged<String?> onChanged;
  final bool includeNonPrecise;

  const _CascadeDropdown({
    required this.label,
    required this.hint,
    required this.disabledHint,
    required this.icon,
    required this.value,
    required this.options,
    required this.enabled,
    required this.onChanged,
    this.includeNonPrecise = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveValue = (enabled && options.contains(value)) ? value : null;
    final items = <DropdownMenuItem<String>>[
      if (includeNonPrecise)
        DropdownMenuItem<String>(
          value: 'Non précisée',
          child: Text(
            '— Non précisée —',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontStyle: FontStyle.italic,
              fontSize: 13,
            ),
          ),
        ),
      ...options.map((o) => DropdownMenuItem<String>(value: o, child: Text(o))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label: label),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          isExpanded: true,
          hint: Text(
            enabled ? hint : disabledHint,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: enabled ? Colors.grey.shade400 : Colors.grey.shade300,
              fontSize: 13,
            ),
          ),
          items: enabled ? items : null,
          onChanged: enabled ? onChanged : null,
          decoration: dropdownDeco(icon, disabled: !enabled),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class BouteillesSection extends StatelessWidget {
  final List<BouteilleRow> bouteilles;
  final bool isModification;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;

  const BouteillesSection({
    super.key,
    required this.bouteilles,
    required this.isModification,
    required this.onAddRow,
    required this.onRemoveRow,
  });

  @override
  Widget build(BuildContext context) {
    final count = bouteilles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SectionLabel(label: 'Bouteilles *'),
            const Spacer(),
            if (!isModification)
              GestureDetector(
                onTap: onAddRow,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: kGreen),
                      SizedBox(width: 4),
                      Text(
                        'Ajouter une bouteille',
                        style: TextStyle(
                          fontSize: 12,
                          color: kGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (!isModification && count > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: kGreen.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$count bouteilles → $count échantillons séparés seront créés',
                    style: TextStyle(
                      fontSize: 11,
                      color: kGreen.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        ...List.generate(
          count,
          (i) => _BouteilleCard(
            row: bouteilles[i],
            index: i,
            showRemove: count > 1,
            onRemove: () => onRemoveRow(i),
          ),
        ),
      ],
    );
  }
}

class _BouteilleCard extends StatelessWidget {
  final BouteilleRow row;
  final int index;
  final bool showRemove;
  final VoidCallback onRemove;

  const _BouteilleCard({
    required this.row,
    required this.index,
    required this.showRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Bouteille ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: kGreen,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (showRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: Colors.red.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 1 : Référence | Variété
          Row(
            children: [
              Expanded(
                child: _CardField(
                  controller: row.refCtrl,
                  label: 'Référence *',
                  hint: 'P2, C1, MARYAM...',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CardField(
                  controller: row.varieteCtrl,
                  label: 'Variété',
                  hint: 'Chemlali, Chetoui...',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Row 2 : Scellage | Quantité
          Row(
            children: [
              Expanded(
                flex: 5,
                child: _CardField(
                  controller: row.scellageCtrl,
                  label: 'Scellage',
                  hint: 'Z1, Z2...',
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: _CardField(
                  controller: row.qteCtrl,
                  label: 'Quantité estimée',
                  hint: '0',
                  suffix: 'T',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? suffix;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const _CardField({
    required this.controller,
    required this.label,
    required this.hint,
    this.suffix,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 14, color: kDarkText),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: kOlive,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 13,
              horizontal: 12,
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
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE SECTION
// ─────────────────────────────────────────────────────────────────────────────
class DateSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onPickDate;

  const DateSection({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel(label: "Date d'ajout"),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 10,
              style: const TextStyle(fontSize: 13, color: kDarkText),
              decoration: dateDeco(),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onPickDate,
            child: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.edit_calendar_outlined,
                color: kGreen,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PLANIFICATION ARRIVAGE SECTION
// ─────────────────────────────────────────────────────────────────────────────
enum ModePlanificationUI { dateExacte, periode }

class PlanificationArrivageSection extends StatelessWidget {
  final bool active;
  final VoidCallback onToggle;
  final ModePlanificationUI mode;
  final ValueChanged<ModePlanificationUI> onModeChanged;
  final DateTime? dateExacte;
  final DateTime? periodeDebut;
  final DateTime? periodeFin;
  final ValueChanged<DateTime?> onDateExacteChanged;
  final ValueChanged<DateTime?> onPeriodeDebutChanged;
  final ValueChanged<DateTime?> onPeriodeFinChanged;

  const PlanificationArrivageSection({
    super.key,
    required this.active,
    required this.onToggle,
    required this.mode,
    required this.onModeChanged,
    required this.dateExacte,
    required this.periodeDebut,
    required this.periodeFin,
    required this.onDateExacteChanged,
    required this.onPeriodeDebutChanged,
    required this.onPeriodeFinChanged,
  });

  // ── Format date only (no time) ─────────────────────────────────────────
  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  // ── Format date + optional time ────────────────────────────────────────
  String _fmtDateTime(DateTime d) {
    final base = _fmtDate(d);
    if (d.hour == 0 && d.minute == 0) return base; // no time chosen
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$base  $hour:$minute $period';
  }

  // ── Pick date only, then optionally pick time via scroll wheel ─────────
  Future<DateTime?> _pickDateThenOptionalTime(
    BuildContext ctx, {
    DateTime? initial,
  }) async {
    // Step 1 — date only, strip any time from initial
    final initialDateOnly = initial != null
        ? DateTime(initial.year, initial.month, initial.day)
        : DateTime.now();

    final date = await showDatePicker(
      context: ctx,
      initialDate: initialDateOnly,
      firstDate: DateTime.now(),
      lastDate: DateTime(2130),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (c, child) => Theme(
        data: Theme.of(c).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kGreen,
            onPrimary: Colors.white,
            onSurface: kDarkText,
          ),
        ),
        child: child!,
      ),
    );
    if (date == null) return null; // user cancelled date

    // Step 2 — optional time via scroll wheel bottom sheet
    // ignore: use_build_context_synchronously
    final time = await _showScrollTimeSheet(
      ctx,
      initial: initial != null && (initial.hour != 0 || initial.minute != 0)
          ? TimeOfDay(hour: initial.hour, minute: initial.minute)
          : null,
    );

    // time == null means user tapped "Ignorer" → keep midnight (no time)
    if (time == null) {
      return DateTime(date.year, date.month, date.day); // midnight = no time
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  bool get _isFilled {
    if (mode == ModePlanificationUI.dateExacte) return dateExacte != null;
    return periodeDebut != null && periodeFin != null;
  }

  String get _summaryText {
    if (mode == ModePlanificationUI.dateExacte && dateExacte != null) {
      return 'Arrivage prévu le ${_fmtDateTime(dateExacte!)}';
    }
    if (periodeDebut != null && periodeFin != null) {
      if (periodeDebut!.isAtSameMomentAs(periodeFin!)) {
        return 'Arrivage prévu le ${_fmtDateTime(periodeDebut!)}';
      }
      return 'Arrivage prévu du ${_fmtDateTime(periodeDebut!)} '
          'au ${_fmtDateTime(periodeFin!)}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Collapsible header ──────────────────────────────────────────
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? kGreen.withValues(alpha: 0.08)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: active
                    ? kGreen.withValues(alpha: 0.35)
                    : Colors.grey.shade200,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  color: active ? kGreen : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Planification de l'arrivage",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: active ? kDarkText : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        "Date ou période d'arrivage estimée à la société",
                        style: TextStyle(
                          fontSize: 11,
                          color: active
                              ? Colors.grey.shade500
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Optionnel',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: active ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: active ? kGreen : Colors.grey.shade400,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Expanded content ────────────────────────────────────────────
        if (active) ...[
          const SizedBox(height: 12),

          // Mode toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _ModeTab(
                  label: 'Date précise',
                  icon: Icons.event_outlined,
                  selected: mode == ModePlanificationUI.dateExacte,
                  onTap: () => onModeChanged(ModePlanificationUI.dateExacte),
                ),
                _ModeTab(
                  label: 'Période estimée',
                  icon: Icons.date_range_outlined,
                  selected: mode == ModePlanificationUI.periode,
                  onTap: () => onModeChanged(ModePlanificationUI.periode),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Date précise ──────────────────────────────────────────────
          if (mode == ModePlanificationUI.dateExacte)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Date d'arrivage prévue",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                _DatePickerButton(
                  date: dateExacte,
                  hint: 'Sélectionner une date',
                  onTap: () async {
                    final dt = await _pickDateThenOptionalTime(
                      context,
                      initial: dateExacte,
                    );
                    if (dt != null) onDateExacteChanged(dt);
                  },
                  fmt: _fmtDateTime,
                ),
              ],
            ),

          // ── Période estimée ───────────────────────────────────────────
          if (mode == ModePlanificationUI.periode)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Période d'arrivage prévue",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À partir du',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DatePickerButton(
                            date: periodeDebut,
                            hint: 'Choisir...',
                            onTap: () async {
                              final dt = await _pickDateThenOptionalTime(
                                context,
                                initial: periodeDebut,
                              );
                              if (dt == null) return;
                              onPeriodeDebutChanged(dt);
                              if (periodeFin != null &&
                                  periodeFin!.isBefore(dt)) {
                                onPeriodeFinChanged(dt);
                              }
                            },
                            fmt: _fmtDateTime,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 18,
                        left: 8,
                        right: 8,
                      ),
                      child: Icon(Icons.arrow_forward, color: kOlive, size: 16),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Jusqu'au",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _DatePickerButton(
                            date: periodeFin,
                            hint: 'Choisir...',
                            onTap: () async {
                              final dt = await _pickDateThenOptionalTime(
                                context,
                                initial:
                                    periodeFin ??
                                    periodeDebut ??
                                    DateTime.now(),
                              );
                              if (dt == null) return;
                              onPeriodeFinChanged(dt);
                              if (periodeDebut != null &&
                                  dt.isBefore(periodeDebut!)) {
                                onPeriodeDebutChanged(dt);
                              }
                            },
                            fmt: _fmtDateTime,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // ── Confirmation chip ─────────────────────────────────────────
          if (_isFilled) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kGreen.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kGreen.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: kGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _summaryText,
                      style: TextStyle(
                        fontSize: 11,
                        color: kGreen.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SCROLL-WHEEL TIME SHEET  (optionnel — avec bouton Ignorer)
//
// Returns TimeOfDay if the user confirms, null if they tap "Ignorer".
// Uses CupertinoPicker for the scroll-wheel feel.
// ─────────────────────────────────────────────────────────────────────────────
Future<TimeOfDay?> _showScrollTimeSheet(
  BuildContext context, {
  TimeOfDay? initial,
}) async {
  // Defaults
  int selectedHour = initial?.hourOfPeriod ?? 9; // 1–12
  int selectedMinute = initial?.minute ?? 0;
  int selectedPeriod = (initial?.period == DayPeriod.pm) ? 1 : 0; // 0=AM 1=PM

  if (selectedHour == 0) selectedHour = 12;

  final hours = List.generate(12, (i) => i + 1); // 1..12
  final minutes = List.generate(60, (i) => i); // 0..59

  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
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

                // Title row
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_outlined,
                      color: kGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      "Heure d'arrivage (optionnel)",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kDarkText,
                      ),
                    ),
                    const Spacer(),
                    // Ignorer button
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, null),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade500,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                      ),
                      child: const Text(
                        'Ignorer',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Scroll wheels ─────────────────────────────────────
                SizedBox(
                  height: 160,
                  child: Row(
                    children: [
                      // AM / PM
                      Expanded(
                        flex: 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedPeriod,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedPeriod = i),
                          children: [_WheelItem('AM'), _WheelItem('PM')],
                        ),
                      ),
                      // Hours
                      Expanded(
                        flex: 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: hours.indexOf(selectedHour),
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedHour = hours[i]),
                          children: hours
                              .map(
                                (h) => _WheelItem(h.toString().padLeft(2, '0')),
                              )
                              .toList(),
                        ),
                      ),
                      // Separator
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kDarkText,
                          ),
                        ),
                      ),
                      // Minutes
                      Expanded(
                        flex: 3,
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(
                            initialItem: selectedMinute,
                          ),
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              setSheetState(() => selectedMinute = i),
                          children: minutes
                              .map(
                                (m) => _WheelItem(m.toString().padLeft(2, '0')),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Convert 12-hour + period → 24-hour
                      int hour24 = selectedHour % 12;
                      if (selectedPeriod == 1) hour24 += 12; // PM
                      Navigator.pop(
                        ctx,
                        TimeOfDay(hour: hour24, minute: selectedMinute),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
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
          );
        },
      );
    },
  );
}

// ── Wheel item ────────────────────────────────────────────────────────────────
class _WheelItem extends StatelessWidget {
  final String text;
  const _WheelItem(this.text);

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: kDarkText,
      ),
    ),
  );
}

// ── Mode tab ──────────────────────────────────────────────────────────────────
class _ModeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? kGreen : Colors.grey.shade400,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? kGreen : Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Date picker button ────────────────────────────────────────────────────────
class _DatePickerButton extends StatelessWidget {
  final DateTime? date;
  final String hint;
  final VoidCallback onTap;
  final String Function(DateTime) fmt;

  const _DatePickerButton({
    required this.date,
    required this.hint,
    required this.onTap,
    required this.fmt,
  });

  @override
  Widget build(BuildContext context) {
    final has = date != null;
    final hasTime = has && (date!.hour != 0 || date!.minute != 0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        decoration: BoxDecoration(
          color: has ? kGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: has ? kGreen.withValues(alpha: 0.4) : Colors.grey.shade200,
            width: has ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasTime
                  ? Icons.access_time_rounded
                  : Icons.calendar_today_outlined,
              size: 15,
              color: has ? kGreen : Colors.grey.shade400,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                has ? fmt(date!) : hint,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: has ? FontWeight.w700 : FontWeight.w400,
                  color: has ? kDarkText : Colors.grey.shade400,
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
// STATUT READ-ONLY SECTION
// ─────────────────────────────────────────────────────────────────────────────
class StatutSection extends StatelessWidget {
  const StatutSection({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel(label: 'Statut'),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.hourglass_top_rounded,
              color: Color(0xFF2563EB),
              size: 18,
            ),
            const SizedBox(width: 10),
            const Text(
              'Réceptionné',
              style: TextStyle(fontSize: 13, color: kDarkText),
            ),
            const Spacer(),
            Icon(Icons.lock_outline, size: 13, color: Colors.grey.shade400),
          ],
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REMARQUES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class RemarquesSection extends StatelessWidget {
  final TextEditingController controller;
  const RemarquesSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SectionLabel(label: 'Remarques (optionnel)'),
      TextField(
        controller: controller,
        maxLines: 3,
        minLines: 2,
        style: const TextStyle(fontSize: 13, color: kDarkText),
        decoration: textAreaDeco('Notes, observations particulières...'),
      ),
    ],
  );
}
