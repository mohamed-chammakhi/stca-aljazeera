// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire_collecteur_dialog.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_collecteur.dart';
import '../../../carte_geo/services/geo_service.dart';

const Color _green = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText = Color(0xFF1A2E1F);

// Gouvernorats loaded dynamically from cities.json via GeoService

const List<String> _scellages = ['Z1', 'Z2', 'Z3', 'Z4', 'Z5'];

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
void showFormulaireCollecteurDialog(
  BuildContext context, {
  EchantillonCollecteur? echantillon,
  required Function(EchantillonCollecteur) onSave,
  required int prochainNumero,
}) {
  showDialog(
    context: context,
    builder: (context) => _FormulaireCollecteurDialog(
      echantillon: echantillon,
      isModification: echantillon != null,
      onSave: onSave,
      prochainNumero: prochainNumero,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireCollecteurDialog extends StatefulWidget {
  final EchantillonCollecteur? echantillon;
  final bool isModification;
  final Function(EchantillonCollecteur) onSave;
  final int prochainNumero;

  const _FormulaireCollecteurDialog({
    required this.echantillon,
    required this.isModification,
    required this.onSave,
    required this.prochainNumero,
  });

  @override
  State<_FormulaireCollecteurDialog> createState() =>
      _FormulaireCollecteurDialogState();
}

class _FormulaireCollecteurDialogState
    extends State<_FormulaireCollecteurDialog> {
  final GeoService _geo = GeoService.instance;
  bool _geoLoaded = false;

  late final TextEditingController _codeFournisseurCtrl;
  late final TextEditingController _remarquesCtrl;
  late final TextEditingController _dateCtrl;

  String? _gouvernorat;
  String? _delegation;
  String? _cite;
  String? _scellage;
  String? _photoUrl;

  final List<_BouteilleRow> _bouteilles = [];

  List<String> get _delegationOptions {
    if (!_geoLoaded) return [];
    if (_gouvernorat == null || _gouvernorat == 'Non précisé') return [];
    return _geo.delegationsFor(_gouvernorat!);
  }

  List<String> get _citeOptions {
    if (!_geoLoaded) return [];
    if (_gouvernorat == null || _delegation == null) return [];
    return _geo.citesFor(_gouvernorat!, _delegation!);
  }

  bool get _delegationLoading =>
      _gouvernorat != null && _gouvernorat != 'Non précisé' && !_geoLoaded;

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    // Ensure GeoService JSON is loaded — safe to call multiple times
    _geo.load().then((_) {
      if (mounted) setState(() => _geoLoaded = true);
    });
    final e = widget.echantillon;
    _codeFournisseurCtrl = TextEditingController(
      text: e?.codeFournisseur ?? '',
    );
    _remarquesCtrl = TextEditingController(text: e?.remarques ?? '');
    _dateCtrl = TextEditingController(text: e?.dateAjout ?? _todayString());
    _gouvernorat = e?.gouvernorat;
    _delegation = e?.delegation;
    _cite = e?.cite;
    _scellage = e?.scellage;
    _photoUrl = e?.imageUrl;

    _bouteilles.add(
      _BouteilleRow(
        refCtrl: TextEditingController(text: e?.referenceBouteille ?? ''),
        qteCtrl: TextEditingController(text: e?.quantiteEstimee ?? ''),
      ),
    );
  }

  @override
  void dispose() {
    _codeFournisseurCtrl.dispose();
    _remarquesCtrl.dispose();
    _dateCtrl.dispose();
    for (final b in _bouteilles) {
      b.refCtrl.dispose();
      b.qteCtrl.dispose();
    }
    super.dispose();
  }

  String _todayString() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  bool get _isValid {
    if (_gouvernorat == null || _gouvernorat!.isEmpty) return false;
    if (_codeFournisseurCtrl.text.trim().isEmpty) return false;
    if (_bouteilles.isEmpty) return false;
    if (_bouteilles.any((b) => b.refCtrl.text.trim().isEmpty)) return false;
    return true;
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez remplir tous les champs obligatoires'),
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

    if (_gouvernorat != null &&
        _gouvernorat != 'Non précisé' &&
        _delegation != null) {
      _geo.markVisited(gouvernorat: _gouvernorat!, delegation: _delegation!);
    }

    Navigator.pop(context);

    final first = _bouteilles.first;
    final generatedRef =
        '${DateTime.now().year}/${widget.prochainNumero.toString().padLeft(4, '0')}';

    if (widget.isModification) {
      final e = widget.echantillon!;
      e.gouvernorat = _gouvernorat!;
      e.delegation = _delegation;
      e.cite = _cite;
      e.codeFournisseur = _codeFournisseurCtrl.text.trim();
      e.referenceBouteille = first.refCtrl.text.trim();
      e.scellage = _scellage;
      e.remarques = _remarquesCtrl.text.trim().isEmpty
          ? null
          : _remarquesCtrl.text.trim();
      e.dateAjout = _dateCtrl.text;
      e.quantiteEstimee = first.qteCtrl.text.trim().isEmpty
          ? null
          : first.qteCtrl.text.trim();
      e.imageUrl = _photoUrl;
      widget.onSave(e);
    } else {
      widget.onSave(
        EchantillonCollecteur(
          id: 'ECH-${DateTime.now().millisecondsSinceEpoch}',
          ref: generatedRef,
          gouvernorat: _gouvernorat!,
          delegation: _delegation,
          cite: _cite,
          codeFournisseur: _codeFournisseurCtrl.text.trim(),
          referenceBouteille: first.refCtrl.text.trim(),
          scellage: _scellage,
          achatConfirme: false,
          camionReservee: null,
          remarques: _remarquesCtrl.text.trim().isEmpty
              ? null
              : _remarquesCtrl.text.trim(),
          dateAjout: _dateCtrl.text,
          quantiteEstimee: first.qteCtrl.text.trim().isEmpty
              ? null
              : first.qteCtrl.text.trim(),
          imageUrl: _photoUrl,
          collecteurId: 'COL-001',
          collecteurNom: 'Ahmed D.',
          statut: StatutCollecteur.enTraitement,
        ),
      );
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2130),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: _green,
            onPrimary: Colors.white,
            onSurface: _darkText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _dateCtrl.text =
            '${picked.day.toString().padLeft(2, '0')}/'
            '${picked.month.toString().padLeft(2, '0')}/'
            '${picked.year}';
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),

      title: Row(
        children: [
          Icon(
            widget.isModification
                ? Icons.edit_outlined
                : Icons.add_a_photo_outlined,
            color: _green,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.isModification
                  ? "Modifier l'échantillon"
                  : 'Nouvel échantillon',
              style: GoogleFonts.domine(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
          ),
        ],
      ),

      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── ID badge — add mode only ──────────────────────────────────
              if (!widget.isModification) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38835A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF38835A).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.tag_rounded, color: _green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'ID : ${DateTime.now().year}/${widget.prochainNumero.toString().padLeft(4, '0')}',
                        style: GoogleFonts.domine(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _green,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Auto-généré',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ── PHOTO ─────────────────────────────────────────────────────
              const _SectionLabel(label: 'Photo de la bouteille'),
              GestureDetector(
                onTap: () {
                  /* TODO: camera / gallery */
                },
                child: Container(
                  width: double.infinity,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF38835A).withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF38835A).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: const Color(0xFF38835A).withValues(alpha: 0.6),
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _photoUrl != null
                            ? 'Photo sélectionnée ✓'
                            : 'Prendre une photo (optionnel)',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF38835A).withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const _Divider(),
              const SizedBox(height: 14),

              // ── GOUVERNORAT — from cities.json via GeoService ─────────────
              const _SectionLabel(label: 'Gouvernorat *'),
              !_geoLoaded
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 13,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _green.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Chargement...',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _gouvernorat,
                      isExpanded: true,
                      hint: Text(
                        'Sélectionner un gouvernorat',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      decoration: _dropdownDecoration(
                        Icons.location_on_outlined,
                      ),
                      items: _geo.gouvernorats
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _gouvernorat = v;
                        _delegation = null;
                        _cite = null;
                      }),
                    ),

              const SizedBox(height: 12),

              // ── DÉLÉGATION — cascading ─────────────────────────────────────
              const _SectionLabel(label: 'Délégation (optionnel)'),
              _delegationOptions.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          // Show spinner while geo data loads, pin icon otherwise
                          _delegationLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.grey.shade400,
                                  ),
                                )
                              : Icon(
                                  Icons.place_outlined,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _delegationLoading
                                  ? 'Chargement des délégations...'
                                  : 'Sélectionner d\'abord un gouvernorat',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _delegation,
                      isExpanded: true,
                      hint: Text(
                        'Sélectionner une délégation',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      decoration: _dropdownDecoration(Icons.place_outlined),
                      items: [
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
                        ..._delegationOptions.map(
                          (d) => DropdownMenuItem(value: d, child: Text(d)),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _delegation = v;
                        _cite = null;
                      }),
                    ),

              if (_delegation != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 13,
                        color: _green.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cette délégation sera colorée sur la carte ✓',
                        style: TextStyle(
                          fontSize: 11,
                          color: _green.withValues(alpha: 0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              // ── CITÉ — 3rd level cascade ──────────────────────────────────
              const SizedBox(height: 12),
              const _SectionLabel(label: 'Cité (optionnel)'),
              _citeOptions.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_city_outlined,
                            size: 18,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              _delegation == null
                                  ? 'Sélectionner d\'abord une délégation'
                                  : 'Aucune cité disponible',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      value: _cite,
                      isExpanded: true,
                      hint: Text(
                        'Sélectionner une cité',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      decoration: _dropdownDecoration(
                        Icons.location_city_outlined,
                      ),
                      items: [
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
                        ..._citeOptions.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c)),
                        ),
                      ],
                      onChanged: (v) => setState(() => _cite = v),
                    ),

              const SizedBox(height: 12),

              // ── FOURNISSEUR ───────────────────────────────────────────────
              const _SectionLabel(label: 'Fournisseur *'),
              _TextField(
                controller: _codeFournisseurCtrl,
                icon: Icons.storefront_outlined,
                hint: 'Ex: NE-81, SF-42...',
              ),

              const SizedBox(height: 16),
              const _Divider(),
              const SizedBox(height: 14),

              // ── BOUTEILLES ────────────────────────────────────────────────
              Row(
                children: [
                  const _SectionLabel(label: 'Références bouteilles *'),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(
                      () => _bouteilles.add(
                        _BouteilleRow(
                          refCtrl: TextEditingController(),
                          qteCtrl: TextEditingController(),
                        ),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38835A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF38835A).withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add, size: 14, color: _green),
                          SizedBox(width: 4),
                          Text(
                            'Ajouter',
                            style: TextStyle(
                              fontSize: 12,
                              color: _green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      'Référence bouteille',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Quantité',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 6),

              ...List.generate(_bouteilles.length, (i) {
                final b = _bouteilles[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: b.refCtrl,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _darkText,
                          ),
                          decoration: _bottleFieldDeco(
                            hint: 'Ex: P2, C1, MARYAM...',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: b.qteCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _darkText,
                          ),
                          decoration: _bottleFieldDeco(hint: '0', suffix: 'T'),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 26,
                        child: _bouteilles.length > 1
                            ? GestureDetector(
                                onTap: () => setState(() {
                                  b.refCtrl.dispose();
                                  b.qteCtrl.dispose();
                                  _bouteilles.removeAt(i);
                                }),
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

              const SizedBox(height: 16),
              const _Divider(),
              const SizedBox(height: 14),

              // ── SCELLAGE + DATE ───────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(label: 'Scellage'),
                        DropdownButtonFormField<String>(
                          value: _scellage,
                          isExpanded: true,
                          hint: Text(
                            'Sélectionner',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                          decoration: _dropdownDecoration(
                            Icons.verified_outlined,
                          ),
                          items: _scellages
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _scellage = v),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionLabel(label: "Date d'ajout"),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _dateCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 10,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: _darkText,
                                ),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'JJ/MM/AAAA',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF7FAF8),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: _green,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                onChanged: (v) {
                                  final digits = v.replaceAll('/', '');
                                  final formatted = _formatDate(digits);
                                  if (formatted != v) {
                                    _dateCtrl.value = TextEditingValue(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                        offset: formatted.length,
                                      ),
                                    );
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF38835A,
                                  ).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF38835A,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit_calendar_outlined,
                                  color: _green,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── STATUT read-only ──────────────────────────────────────────
              const _SectionLabel(label: 'Statut'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
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
                      'En traitement',
                      style: TextStyle(fontSize: 13, color: _darkText),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.lock_outline,
                      size: 13,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── REMARQUES ─────────────────────────────────────────────────
              const _SectionLabel(label: 'Remarques (optionnel)'),
              TextField(
                controller: _remarquesCtrl,
                maxLines: 3,
                minLines: 2,
                style: const TextStyle(fontSize: 13, color: _darkText),
                decoration: InputDecoration(
                  hintText: 'Notes, observations particulières...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7FAF8),
                  contentPadding: const EdgeInsets.all(12),
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
                    borderSide: const BorderSide(color: _green, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _save,
          icon: Icon(widget.isModification ? Icons.check : Icons.add, size: 16),
          label: Text(widget.isModification ? 'Enregistrer' : 'Ajouter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DATE FORMATTER
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

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────
class _BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController qteCtrl;
  _BouteilleRow({required this.refCtrl, required this.qteCtrl});
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _oliveGreen,
      ),
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.grey.shade100, height: 1);
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  const _TextField({
    required this.controller,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    style: const TextStyle(fontSize: 14, color: _darkText),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: _green, size: 20),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

InputDecoration _dropdownDecoration(IconData icon) => InputDecoration(
  prefixIcon: Icon(icon, color: _green, size: 20),
  filled: true,
  fillColor: const Color(0xFFF7FAF8),
  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
);

InputDecoration _bottleFieldDeco({required String hint, String? suffix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        color: _oliveGreen,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    );
