// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/formulaire_state.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../../models/echantillon_collecteur.dart';
import 'planification_arrivage.dart';
import '../../../../carte_geo/services/geo_service.dart';
import 'bouteille_row.dart';
import 'formulaire_decorations.dart';
import 'formulaire_sections.dart' show ModePlanificationUI;

mixin FormulaireStateMixin<T extends StatefulWidget> on State<T> {
  final GeoService geo = GeoService.instance;
  bool geoLoaded = false;

  late final TextEditingController codeFournisseurCtrl;
  late final TextEditingController remarquesCtrl;
  late final TextEditingController dateCtrl;

  String? gouvernorat;
  String? delegation;
  String? photoUrl;

  final List<BouteilleRow> bouteilles = [];

  // ── Planification arrivage ─────────────────────────────────────────────────
  bool planificationActive = false;
  ModePlanificationUI planificationMode = ModePlanificationUI.dateExacte;
  DateTime? arrivageDateExacte;
  DateTime? arrivagePeriodeDebut;
  DateTime? arrivagePeriodeFin;

  // ── Geo ────────────────────────────────────────────────────────────────────
  List<String> get gouvernoratOptions {
    if (!geoLoaded) return [];
    return geo.gouvernorats;
  }

  List<String> get delegationOptions {
    if (!geoLoaded || gouvernorat == null) return [];
    return geo.delegationsFor(gouvernorat!);
  }

  void onGouvernoratChanged(String? value) {
    setState(() {
      gouvernorat = value;
      delegation = null;
    });
  }

  void onDelegationChanged(String? value) => setState(() => delegation = value);

  // ── Init / dispose ─────────────────────────────────────────────────────────
  void initFormulaireState(EchantillonCollecteur? e) {
    geo.load().then((_) {
      if (mounted) setState(() => geoLoaded = true);
    });

    codeFournisseurCtrl = TextEditingController(text: e?.codeFournisseur ?? '');
    remarquesCtrl = TextEditingController(text: e?.remarques ?? '');
    dateCtrl = TextEditingController(text: e?.dateAjout ?? _todayString());

    gouvernorat = e?.gouvernorat;
    delegation = e?.delegation;
    photoUrl = e?.imageUrl;

    // Restore planification when editing an existing sample
    if (e?.planificationArrivage != null) {
      planificationActive = true;
      final p = e!.planificationArrivage!;
      if (p.mode == ModePlanification.dateExacte) {
        planificationMode = ModePlanificationUI.dateExacte;
        arrivageDateExacte = p.dateExacte;
      } else {
        planificationMode = ModePlanificationUI.periode;
        arrivagePeriodeDebut = p.periodeDebut;
        arrivagePeriodeFin = p.periodeFin;
      }
    }

    bouteilles.add(
      BouteilleRow.fromSample(
        ref: e?.referenceBouteille ?? '',
        variete: e?.variete ?? '',
        scellage: e?.scellage ?? '',
        qte: e?.quantiteEstimee ?? '',
      ),
    );
  }

  void disposeFormulaireState() {
    codeFournisseurCtrl.dispose();
    remarquesCtrl.dispose();
    dateCtrl.dispose();
    for (final b in bouteilles) b.dispose();
  }

  // ── Planification helpers ──────────────────────────────────────────────────
  void togglePlanification() {
    setState(() {
      planificationActive = !planificationActive;
      if (!planificationActive) {
        arrivageDateExacte = null;
        arrivagePeriodeDebut = null;
        arrivagePeriodeFin = null;
      }
    });
  }

  void onPlanificationModeChanged(ModePlanificationUI mode) {
    setState(() {
      planificationMode = mode;
      // Clear stale values when switching mode
      arrivageDateExacte = null;
      arrivagePeriodeDebut = null;
      arrivagePeriodeFin = null;
    });
  }

  PlanificationArrivage? _buildPlanification() {
    if (!planificationActive) return null;
    if (planificationMode == ModePlanificationUI.dateExacte) {
      if (arrivageDateExacte == null) return null;
      return PlanificationArrivage.exact(arrivageDateExacte!);
    } else {
      if (arrivagePeriodeDebut == null || arrivagePeriodeFin == null) {
        return null;
      }
      return PlanificationArrivage.range(
        debut: arrivagePeriodeDebut!,
        fin: arrivagePeriodeFin!,
      );
    }
  }

  // ── Bottle row helpers ─────────────────────────────────────────────────────
  void addBouteilleRow() =>
      setState(() => bouteilles.add(BouteilleRow.empty()));

  void removeBouteilleRow(int index) {
    setState(() {
      bouteilles[index].dispose();
      bouteilles.removeAt(index);
    });
  }

  bool get isValid {
    if (bouteilles.isEmpty) return false;
    return bouteilles.every((b) => b.refCtrl.text.trim().isNotEmpty);
  }

  // ── Build samples ──────────────────────────────────────────────────────────
  List<EchantillonCollecteur> buildSamples({
    required bool isModification,
    required EchantillonCollecteur? existing,
    required int prochainNumero,
  }) {
    final planification = _buildPlanification();

    if (isModification) {
      final e = existing!;
      final b = bouteilles.first;
      e.gouvernorat = gouvernorat ?? '';
      e.delegation = delegation;
      e.cite = null;
      e.codeFournisseur = codeFournisseurCtrl.text.trim();
      e.referenceBouteille = b.refCtrl.text.trim();
      e.variete = _nullIfEmpty(b.varieteCtrl.text);
      e.scellage = _nullIfEmpty(b.scellageCtrl.text);
      e.remarques = _nullIfEmpty(remarquesCtrl.text);
      e.dateAjout = dateCtrl.text;
      e.quantiteEstimee = _nullIfEmpty(b.qteCtrl.text);
      e.imageUrl = photoUrl;
      e.planificationArrivage = planification;
      return [e];
    }

    final now = DateTime.now();
    return bouteilles.asMap().entries.map((entry) {
      final idx = entry.key;
      final b = entry.value;
      final numero = prochainNumero + idx;
      return EchantillonCollecteur(
        id: 'ECH-${now.millisecondsSinceEpoch}-$idx',
        ref: '${now.year}/${numero.toString().padLeft(4, '0')}',
        gouvernorat: gouvernorat ?? '',
        delegation: delegation,
        cite: null,
        codeFournisseur: codeFournisseurCtrl.text.trim(),
        referenceBouteille: b.refCtrl.text.trim(),
        variete: _nullIfEmpty(b.varieteCtrl.text),
        scellage: _nullIfEmpty(b.scellageCtrl.text),
        achatConfirme: false,
        //camionReservee: null,
        remarques: _nullIfEmpty(remarquesCtrl.text),
        dateAjout: dateCtrl.text,
        quantiteEstimee: _nullIfEmpty(b.qteCtrl.text),
        imageUrl: photoUrl,
        collecteurId: 'COL-001',
        collecteurNom: 'Ahmed D.',
        statut: StatutCollecteur.receptionne,
        planificationArrivage: planification,
      );
    }).toList();
  }

  // ── Save handler ───────────────────────────────────────────────────────────
  // markVisited is NO LONGER called here.
  // MesEchantillonsPage calls geo.rebuildFromEchantillons() after every
  // save, which rebuilds the visited set from scratch — always correct.
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
          content: const Text(
            'Veuillez remplir la référence de chaque bouteille',
          ),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
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

  // ── Date helpers ───────────────────────────────────────────────────────────
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

  String _todayString() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  String? _nullIfEmpty(String value) =>
      value.trim().isEmpty ? null : value.trim();
}

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
