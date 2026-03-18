// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/formulaire_state.dart
//
// Mixin that holds every piece of logic for the formulaire dialog:
//   • Controller lifecycle (init / dispose)
//   • Cascade dropdown handlers
//   • Date formatting + date picker
//   • Validation
//   • Save logic (modify single / add multiple)
//
// Usage:
//   class _FormulaireCollecteurDialogState extends State<...>
//       with FormulaireStateMixin { ... }
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../models/echantillon_collecteur.dart';
import '../../../../carte_geo/services/geo_service.dart';
import 'bouteille_row.dart';
import 'formulaire_decorations.dart';

mixin FormulaireStateMixin<T extends StatefulWidget> on State<T> {
  // ── GeoService ────────────────────────────────────────────────────────────
  final GeoService geo = GeoService.instance;
  bool geoLoaded = false;

  // ── Shared field controllers ──────────────────────────────────────────────
  late final TextEditingController codeFournisseurCtrl;
  late final TextEditingController remarquesCtrl;
  late final TextEditingController dateCtrl;

  // ── Location state ────────────────────────────────────────────────────────
  String? gouvernorat;
  String? delegation;
  String? cite;
  String? photoUrl;

  // ── Bottle rows ───────────────────────────────────────────────────────────
  final List<BouteilleRow> bouteilles = [];

  // ── Cascade computed options ──────────────────────────────────────────────
  List<String> get delegationOptions {
    if (!geoLoaded || gouvernorat == null) return [];
    return geo.delegationsFor(gouvernorat!);
  }

  List<String> get citeOptions {
    if (!geoLoaded || gouvernorat == null || delegation == null) return [];
    return geo.citesFor(gouvernorat!, delegation!);
  }

  // ── Cascade handlers ──────────────────────────────────────────────────────
  void onGouvernoratChanged(String? value) {
    setState(() {
      gouvernorat = value;
      delegation  = null;
      cite        = null;
    });
  }

  void onDelegationChanged(String? value) {
    setState(() {
      delegation = value;
      cite       = null;
    });
  }

  void onCiteChanged(String? value) => setState(() => cite = value);

  // ── Init helpers ──────────────────────────────────────────────────────────

  /// Call this inside [initState] with the optional existing sample.
  void initFormulaireState(EchantillonCollecteur? e) {
    geo.load().then((_) {
      if (mounted) setState(() => geoLoaded = true);
    });

    codeFournisseurCtrl =
        TextEditingController(text: e?.codeFournisseur ?? '');
    remarquesCtrl  = TextEditingController(text: e?.remarques ?? '');
    dateCtrl       = TextEditingController(
        text: e?.dateAjout ?? _todayString());

    gouvernorat = e?.gouvernorat;
    delegation  = e?.delegation;
    cite        = e?.cite;
    photoUrl    = e?.imageUrl;

    bouteilles.add(
      BouteilleRow.fromSample(
        ref:      e?.referenceBouteille ?? '',
        scellage: e?.scellage ?? '',
        qte:      e?.quantiteEstimee ?? '',
      ),
    );
  }

  /// Call this inside [dispose].
  void disposeFormulaireState() {
    codeFournisseurCtrl.dispose();
    remarquesCtrl.dispose();
    dateCtrl.dispose();
    for (final b in bouteilles) b.dispose();
  }

  // ── Bottle row management ─────────────────────────────────────────────────
  void addBouteilleRow() => setState(() => bouteilles.add(BouteilleRow.empty()));

  void removeBouteilleRow(int index) {
    setState(() {
      bouteilles[index].dispose();
      bouteilles.removeAt(index);
    });
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool get isValid {
    if (bouteilles.isEmpty) return false;
    return bouteilles.every((b) => b.refCtrl.text.trim().isNotEmpty);
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  /// [isModification]  true → mutate [existing] and return it in a 1-item list.
  ///                   false → create one new sample per bottle row.
  /// [prochainNumero]  starting ref counter (exclusive to add mode).
  List<EchantillonCollecteur> buildSamples({
    required bool isModification,
    required EchantillonCollecteur? existing,
    required int prochainNumero,
  }) {
    if (isModification) {
      final e = existing!;
      final b = bouteilles.first;
      e.gouvernorat       = gouvernorat ?? '';
      e.delegation        = delegation;
      e.cite              = cite;
      e.codeFournisseur   = codeFournisseurCtrl.text.trim();
      e.referenceBouteille = b.refCtrl.text.trim();
      e.scellage          = _nullIfEmpty(b.scellageCtrl.text);
      e.remarques         = _nullIfEmpty(remarquesCtrl.text);
      e.dateAjout         = dateCtrl.text;
      e.quantiteEstimee   = _nullIfEmpty(b.qteCtrl.text);
      e.imageUrl          = photoUrl;
      return [e];
    }

    final now = DateTime.now();
    return bouteilles.asMap().entries.map((entry) {
      final idx    = entry.key;
      final b      = entry.value;
      final numero = prochainNumero + idx;
      return EchantillonCollecteur(
        id:                  'ECH-${now.millisecondsSinceEpoch}-$idx',
        ref:                 '${now.year}/${numero.toString().padLeft(4, '0')}',
        gouvernorat:         gouvernorat ?? '',
        delegation:          delegation,
        cite:                cite,
        codeFournisseur:     codeFournisseurCtrl.text.trim(),
        referenceBouteille:  b.refCtrl.text.trim(),
        scellage:            _nullIfEmpty(b.scellageCtrl.text),
        achatConfirme:       false,
        camionReservee:      null,
        remarques:           _nullIfEmpty(remarquesCtrl.text),
        dateAjout:           dateCtrl.text,
        quantiteEstimee:     _nullIfEmpty(b.qteCtrl.text),
        imageUrl:            photoUrl,
        collecteurId:        'COL-001',
        collecteurNom:       'Ahmed D.',
        statut:              StatutCollecteur.enTraitement,
      );
    }).toList();
  }

  /// Call [buildSamples], mark geo, pop dialog, and pass result to [onSaveMultiple].
  void handleSave({
    required BuildContext ctx,
    required bool isModification,
    required EchantillonCollecteur? existing,
    required int prochainNumero,
    required Function(List<EchantillonCollecteur>) onSaveMultiple,
  }) {
    if (!isValid) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content:
              const Text('Veuillez remplir la référence de chaque bouteille'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (gouvernorat != null && delegation != null) {
      geo.markVisited(gouvernorat: gouvernorat!, delegation: delegation!);
    }

    Navigator.pop(ctx);

    onSaveMultiple(
      buildSamples(
        isModification: isModification,
        existing: existing,
        prochainNumero: prochainNumero,
      ),
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> pickDate(BuildContext ctx) async {
    final picked = await showDatePicker(
      context: ctx,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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
    if (picked != null) {
      setState(() {
        dateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  /// Auto-formats raw digit input as JJ/MM/AAAA while typing.
  void handleDateChanged(String raw) {
    final digits = raw.replaceAll('/', '');
    final formatted = _formatDate(digits);
    if (formatted != raw) {
      dateCtrl.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    setState(() {});
  }

  // ── Private helpers ───────────────────────────────────────────────────────
  String _todayString() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  String? _nullIfEmpty(String value) =>
      value.trim().isEmpty ? null : value.trim();
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE FORMATTER  (module-level pure function)
// ─────────────────────────────────────────────────────────────────────────────
String _formatDate(String digits) {
  if (digits.length > 8) digits = digits.substring(0, 8);
  String f = '';
  for (int i = 0; i < digits.length; i++) {
    if (i == 2 || i == 4) f += '/';
    f += digits[i];
  }
  if (digits.length >= 2) {
    final d = (int.tryParse(digits.substring(0, 2)) ?? 1)
        .clamp(1, 31)
        .toString()
        .padLeft(2, '0');
    f = d + f.substring(2);
  }
  if (digits.length >= 4) {
    final m = (int.tryParse(digits.substring(2, 4)) ?? 1)
        .clamp(1, 12)
        .toString()
        .padLeft(2, '0');
    f = f.substring(0, 3) + m + f.substring(5);
  }
  if (digits.length == 8) {
    final y = (int.tryParse(digits.substring(4, 8)) ?? 2026)
        .clamp(2000, 2130)
        .toString();
    f = f.substring(0, 6) + y;
  }
  return f;
}
