// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
// PURPOSE : add / edit dialog for one EchantillonGestion
//           — CEO-style sections (BOUTEILLE, FOURNISSEUR, LOCALISATION, DATE)
//           — gouvernorat → delegation cascade via GeoService
//           — statut is always read-only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_gestion.dart';
import '../date_input_field.dart';
import '../../../../2_collecteur/carte_geo/services/geo_service.dart';

const Color _green      = Color(0xFF38835A);
const Color _olive      = Color(0xFF6B8143);
const Color _dark       = Color(0xFF1A2E1F);
const Color _cream      = Color(0xFFF9F6EF);
const Color _fieldFill  = Color(0xFFF7FAF8);

void showFormulaireDialog(
  BuildContext context, {
  EchantillonGestion? echantillon,
  required int prochainNumero,
  required Function(EchantillonGestion) onSave,
}) {
  showDialog(
    context: context,
    builder: (_) => _FormulaireDialog(
      echantillon:    echantillon,
      prochainNumero: prochainNumero,
      onSave:         onSave,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireDialog extends StatefulWidget {
  final EchantillonGestion? echantillon;
  final int                 prochainNumero;
  final Function(EchantillonGestion) onSave;

  const _FormulaireDialog({
    required this.echantillon,
    required this.prochainNumero,
    required this.onSave,
  });

  @override
  State<_FormulaireDialog> createState() => _FormulaireDialogState();
}

class _FormulaireDialogState extends State<_FormulaireDialog> {
  // ── GeoService ───────────────────────────────────────────────────────────────
  final GeoService _geo = GeoService.instance;
  bool _geoLoaded = false;

  // ── Controllers ──────────────────────────────────────────────────────────────
  late final TextEditingController _refCtrl;
  late final TextEditingController _codeFournisseurCtrl;
  late final TextEditingController _varieteCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _dateCtrl;
  late final TextEditingController _collecteurCtrl;

  // ── Location state ────────────────────────────────────────────────────────────
  String? _gouvernorat;
  String? _delegation;

  bool get _isModification => widget.echantillon != null;

  @override
  void initState() {
    super.initState();
    final e = widget.echantillon;

    _refCtrl             = TextEditingController(text: e?.ref             ?? '');
    _codeFournisseurCtrl = TextEditingController(text: e?.codeFournisseur ?? '');
    _varieteCtrl         = TextEditingController(text: e?.variete         ?? '');
    _quantiteCtrl        = TextEditingController(text: e?.quantite        ?? '');
    _collecteurCtrl      = TextEditingController(text: e?.collecteur      ?? '');
    _dateCtrl            = TextEditingController(
      text: e?.dateArrivee ?? _todayStr(),
    );

    _gouvernorat = e?.gouvernorat.isEmpty == true ? null : e?.gouvernorat;
    _delegation  = e?.delegation;

    // Load geo data for cascaded dropdowns
    _geo.load().then((_) {
      if (mounted) setState(() => _geoLoaded = true);
    });
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    _codeFournisseurCtrl.dispose();
    _varieteCtrl.dispose();
    _quantiteCtrl.dispose();
    _collecteurCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  void _save() {
    if (_refCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La référence est obligatoire'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.pop(context);

    final gouvernorat = _gouvernorat ?? '';

    if (_isModification) {
      final e = widget.echantillon!;
      e.ref             = _refCtrl.text.trim();
      e.codeFournisseur = _codeFournisseurCtrl.text.trim();
      e.variete         = _varieteCtrl.text.trim();
      e.gouvernorat     = gouvernorat;
      e.delegation      = _delegation;
      e.quantite        = _quantiteCtrl.text.trim();
      e.dateArrivee     = _dateCtrl.text;
      e.collecteur      = _collecteurCtrl.text.trim().isEmpty
          ? null
          : _collecteurCtrl.text.trim();
      widget.onSave(e);
    } else {
      widget.onSave(
        EchantillonGestion(
          id:              '${DateTime.now().year}/${widget.prochainNumero}',
          ref:             _refCtrl.text.trim(),
          codeFournisseur: _codeFournisseurCtrl.text.trim(),
          variete:         _varieteCtrl.text.trim(),
          dateArrivee:     _dateCtrl.text,
          gouvernorat:     gouvernorat,
          delegation:      _delegation,
          quantite:        _quantiteCtrl.text.trim(),
          statut:          'En attente',
          collecteur:      _collecteurCtrl.text.trim().isEmpty
              ? null
              : _collecteurCtrl.text.trim(),
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // ── Dialog header ─────────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: const BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isModification ? Icons.edit_outlined : Icons.add_circle_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isModification ? "Modifier l'échantillon" : 'Nouvel échantillon',
                      style: GoogleFonts.domine(
                        fontSize:   17,
                        fontWeight: FontWeight.w700,
                        color:      Colors.white,
                      ),
                    ),
                  ),
                  // ID auto-label (add mode only)
                  if (!_isModification)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:        Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${DateTime.now().year}/${widget.prochainNumero}',
                        style: const TextStyle(
                          fontSize:   12,
                          fontWeight: FontWeight.w700,
                          color:      Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── SECTION: BOUTEILLE ────────────────────────────────────
                    _SectionLabel('Bouteille'),
                    const SizedBox(height: 10),
                    _FormField(
                      label:      'Référence bouteille',
                      controller: _refCtrl,
                      icon:       Icons.tag,
                      hint:       'Ex: CHEMLALI-C1',
                      required:   true,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label:      "Variété d'olive",
                      controller: _varieteCtrl,
                      icon:       Icons.eco_outlined,
                      hint:       'Ex: Chemlali, Chetoui…',
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label:        'Quantité estimée',
                      controller:   _quantiteCtrl,
                      icon:         Icons.scale_outlined,
                      hint:         'Ex: 5000',
                      keyboardType: TextInputType.number,
                      suffixText:   'T',
                    ),

                    const SizedBox(height: 20),

                    // ── SECTION: FOURNISSEUR & COLLECTEUR ────────────────────
                    _SectionLabel('Fournisseur & Collecteur'),
                    const SizedBox(height: 10),
                    _FormField(
                      label:      'Nom / Code fournisseur',
                      controller: _codeFournisseurCtrl,
                      icon:       Icons.store_outlined,
                      hint:       'Ex: Domaine Bel-Air',
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label:    'Collecteur',
                      controller: _collecteurCtrl,
                      icon:     Icons.person_outline,
                      hint:     'Ex: Ahmed Dridi',
                      optional: true,
                    ),

                    const SizedBox(height: 20),

                    // ── SECTION: LOCALISATION ─────────────────────────────────
                    _SectionLabel('Localisation'),
                    const SizedBox(height: 10),

                    // Gouvernorat dropdown
                    _DropdownField(
                      label:    'Gouvernorat',
                      icon:     Icons.location_city_outlined,
                      value:    _gouvernorat,
                      items:    _geoLoaded ? _geo.gouvernorats : [],
                      hint:     _geoLoaded ? 'Sélectionner un gouvernorat' : 'Chargement…',
                      onChanged: (v) => setState(() {
                        _gouvernorat = v;
                        _delegation  = null; // reset delegation
                      }),
                    ),
                    const SizedBox(height: 12),

                    // Delegation dropdown (cascades from gouvernorat)
                    _DropdownField(
                      label: 'Délégation',
                      icon:  Icons.location_on_outlined,
                      value: _delegation,
                      items: (_geoLoaded && _gouvernorat != null)
                          ? _geo.delegationsFor(_gouvernorat!)
                          : [],
                      hint: _gouvernorat == null
                          ? 'Choisir un gouvernorat d\'abord'
                          : 'Sélectionner une délégation',
                      onChanged: _gouvernorat == null
                          ? null
                          : (v) => setState(() => _delegation = v),
                      optional: true,
                    ),

                    const SizedBox(height: 20),

                    // ── SECTION: DATE & STATUT ────────────────────────────────
                    _SectionLabel("Date & Statut"),
                    const SizedBox(height: 10),
                    DateInputField(controller: _dateCtrl),
                    const SizedBox(height: 12),

                    // Statut — read-only
                    _ReadOnlyField(
                      label: 'Statut',
                      icon:  Icons.flag_outlined,
                      value: _isModification
                          ? widget.echantillon!.statut
                          : 'En attente',
                    ),

                    const SizedBox(height: 20),

                    // ── SECTION: PHOTO (placeholder) ──────────────────────────
                    _SectionLabel('Photo'),
                    const SizedBox(height: 10),
                    Container(
                      width:  double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color:        _green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.25),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: _green.withValues(alpha: 0.55), size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Ajouter une photo (optionnel)',
                            style: TextStyle(
                              fontSize: 12,
                              color: _green.withValues(alpha: 0.55),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Action buttons ────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: _cream,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade600,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: Icon(
                        _isModification ? Icons.check : Icons.add,
                        size: 16,
                      ),
                      label: Text(
                        _isModification ? 'Enregistrer' : 'Ajouter',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL  — olive uppercase caption
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize:      10,
      fontWeight:    FontWeight.w700,
      color:         _olive,
      letterSpacing: 1.1,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM FIELD  — label + icon + text input
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String                label;
  final TextEditingController controller;
  final IconData              icon;
  final String                hint;
  final TextInputType         keyboardType;
  final String?               suffixText;
  final bool                  required;
  final bool                  optional;

  const _FormField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.required = false,
    this.optional = false,
  });

  InputDecoration _dec() => InputDecoration(
    hintText:  hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    prefixIcon: Icon(icon, color: _green, size: 20),
    suffixText:  suffixText,
    suffixStyle: const TextStyle(
      color:      _olive,
      fontWeight: FontWeight.w700,
      fontSize:   14,
    ),
    filled:     true,
    fillColor:  _fieldFill,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:   const BorderSide(color: _green, width: 1.8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      _olive,
              ),
            ),
            if (required)
              const Text(' *', style: TextStyle(fontSize: 12, color: Colors.red)),
            if (optional)
              Text(
                ' (optionnel)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller:   controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _dark),
          decoration:   _dec(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DROPDOWN FIELD  — label + icon + dropdown
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String        label;
  final IconData      icon;
  final String?       value;
  final List<String>  items;
  final String        hint;
  final ValueChanged<String?>? onChanged;
  final bool          optional;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
    this.optional = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize:   12,
                fontWeight: FontWeight.w600,
                color:      _olive,
              ),
            ),
            if (optional)
              Text(
                ' (optionnel)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
          ],
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: onChanged == null,
          child: Opacity(
            opacity: onChanged == null ? 0.5 : 1.0,
            child: DropdownButtonFormField<String>(
              value:      value,
              isExpanded: true,
              decoration: InputDecoration(
                prefixIcon: Icon(icon, color: _green, size: 20),
                filled:     true,
                fillColor:  _fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12, horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:   const BorderSide(color: _green, width: 1.8),
                ),
              ),
              hint: Text(
                hint,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
              ),
              items: items
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// READ-ONLY FIELD  — shows a locked value (e.g. statut)
// ─────────────────────────────────────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String   label;
  final IconData icon;
  final String   value;

  const _ReadOnlyField({
    required this.label,
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize:   12,
          fontWeight: FontWeight.w600,
          color:      _olive,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:        _fieldFill,
          borderRadius: BorderRadius.circular(10),
          border:       Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: _green, size: 20),
            const SizedBox(width: 12),
            Text(value, style: const TextStyle(fontSize: 14, color: _dark)),
            const Spacer(),
            Icon(Icons.lock_outline, size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    ],
  );
}
