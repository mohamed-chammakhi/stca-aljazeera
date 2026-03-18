// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/formulaire_sections.dart
//
// Pure UI sections used inside the formulaire dialog.
// Each section is a StatelessWidget that receives only what it needs.
// No state, no GeoService calls — those stay in formulaire_state.dart.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'bouteille_row.dart';
import 'formulaire_decorations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ID BADGE  (add mode only)
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
    final to   = (prochainNumero + bottleCount - 1).toString().padLeft(4, '0');
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

  const PhotoSection({
    super.key,
    required this.photoUrl,
    required this.onTap,
  });

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
// LOCATION CASCADE SECTION  (Gouvernorat → Délégation → Cité)
// ─────────────────────────────────────────────────────────────────────────────
class LocationCascadeSection extends StatelessWidget {
  final bool geoLoaded;
  final String? gouvernorat;
  final String? delegation;
  final String? cite;
  final List<String> gouvernorats;
  final List<String> delegationOptions;
  final List<String> citeOptions;
  final ValueChanged<String?> onGouvernoratChanged;
  final ValueChanged<String?> onDelegationChanged;
  final ValueChanged<String?> onCiteChanged;

  const LocationCascadeSection({
    super.key,
    required this.geoLoaded,
    required this.gouvernorat,
    required this.delegation,
    required this.cite,
    required this.gouvernorats,
    required this.delegationOptions,
    required this.citeOptions,
    required this.onGouvernoratChanged,
    required this.onDelegationChanged,
    required this.onCiteChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gouvernorat ──────────────────────────────────────────────────
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

          // ── Délégation ───────────────────────────────────────────────────
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
                Icon(Icons.map_outlined,
                    size: 13, color: kGreen.withValues(alpha: 0.7)),
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

          const SizedBox(height: 12),

          // ── Cité ─────────────────────────────────────────────────────────
          _CascadeDropdown(
            label: 'Cité (optionnel)',
            hint: 'Sélectionner une cité',
            disabledHint: delegation == null
                ? "Sélectionner d'abord une délégation"
                : 'Aucune cité disponible',
            icon: Icons.location_city_outlined,
            value: cite,
            options: citeOptions,
            enabled: delegation != null &&
                delegation != 'Non précisée' &&
                citeOptions.isNotEmpty,
            onChanged: onCiteChanged,
            includeNonPrecise: true,
          ),
        ],
      );
}

// ── Private cascade dropdown — used only inside LocationCascadeSection ────────
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
    final effectiveValue =
        (enabled && options.contains(value)) ? value : null;

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
      ...options
          .map((o) => DropdownMenuItem<String>(value: o, child: Text(o))),
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
// BOUTEILLES TABLE SECTION
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
        // Header row + "add" button
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
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: kGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: kGreen.withValues(alpha: 0.3)),
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

        // Multi-sample info banner
        if (!isModification && count > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kGreen.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: kGreen.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14, color: kGreen.withValues(alpha: 0.8)),
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

        const SizedBox(height: 10),

        // Column headers
        Row(
          children: [
            Expanded(
              flex: 4,
              child: Text('Référence',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 3,
              child: Text('Scellage',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 2,
              child: Text('Qté',
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 28),
          ],
        ),
        const SizedBox(height: 6),

        // Rows
        ...List.generate(count, (i) {
          final b = bouteilles[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: b.refCtrl,
                    style: const TextStyle(
                        fontSize: 13, color: kDarkText),
                    decoration:
                        bottleFieldDeco(hint: 'P2, C1, MARYAM...'),
                  ),
                ),
                const SizedBox(width: 6),
                // Scellage — plain TextField, auto-capitalised
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: b.scellageCtrl,
                    textCapitalization:
                        TextCapitalization.characters,
                    style: const TextStyle(
                        fontSize: 13, color: kDarkText),
                    decoration: bottleFieldDeco(hint: 'Z1, Z2...'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: b.qteCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                        fontSize: 13, color: kDarkText),
                    decoration:
                        bottleFieldDeco(hint: '0', suffix: 'T'),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox(
                  width: 24,
                  child: count > 1
                      ? GestureDetector(
                          onTap: () => onRemoveRow(i),
                          child: Icon(
                            Icons.remove_circle_outline,
                            size: 20,
                            color: Colors.red.shade300,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }),
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
                  style: const TextStyle(
                      fontSize: 13, color: kDarkText),
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
                    border: Border.all(
                        color: kGreen.withValues(alpha: 0.3)),
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
            padding: const EdgeInsets.symmetric(
                vertical: 11, horizontal: 14),
            decoration: BoxDecoration(
              color: kFieldFill,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded,
                    color: Color(0xFF2563EB), size: 18),
                const SizedBox(width: 10),
                const Text('En traitement',
                    style:
                        TextStyle(fontSize: 13, color: kDarkText)),
                const Spacer(),
                Icon(Icons.lock_outline,
                    size: 13, color: Colors.grey.shade400),
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
            decoration:
                textAreaDeco('Notes, observations particulières...'),
          ),
        ],
      );
}
