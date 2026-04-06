// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
// PURPOSE : add / edit dialog for one Echantillon (degustateur module)
//           — sections: BOUTEILLE, FOURNISSEUR, LOCALISATION, DATE
//           — gouvernorat → delegation cascade via GeoService
//           — statut is always read-only
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/echantillon.dart';
import '../date_input_field.dart';
import '../../../../2_collecteur/carte_geo/services/geo_service.dart';

const Color _green = Color(0xFF38835A);
const Color _beige = Color(0xFFE9F4EE);

const Color _olive = Color(0xFF6B8143);
const Color _dark = Color(0xFF1A2E1F);
const Color _cream = Color(0xFFF9F6EF);
const Color _fieldFill = Color(0xFFF7FAF8);

// Section accent colors
const Color _sectionBouteille = Color(0xFF38835A); // green
const Color _sectionFournisseur = Color(0xFF2E7D98); // teal-blue
const Color _sectionLocalisation = Color(0xFF6D4C41); // earthy
const Color _sectionDate = Color(0xFF5C6BC0); // muted indigo

void showFormulaireDialog(
  BuildContext context, {
  Echantillon? echantillon,
  required int prochainNumero,
  required Function(Echantillon) onSave,
}) {
  showDialog(
    context: context,
    builder: (_) => _FormulaireDialog(
      echantillon: echantillon,
      prochainNumero: prochainNumero,
      onSave: onSave,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireDialog extends StatefulWidget {
  final Echantillon? echantillon;
  final int prochainNumero;
  final Function(Echantillon) onSave;

  const _FormulaireDialog({
    required this.echantillon,
    required this.prochainNumero,
    required this.onSave,
  });

  @override
  State<_FormulaireDialog> createState() => _FormulaireDialogState();
}

class _FormulaireDialogState extends State<_FormulaireDialog> {
  // ── GeoService ────────────────────────────────────────────────────────────
  final GeoService _geo = GeoService.instance;
  bool _geoLoaded = false;

  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _refCtrl;
  late final TextEditingController _codeFournisseurCtrl;
  late final TextEditingController _varieteCtrl;
  late final TextEditingController _quantiteCtrl;
  late final TextEditingController _dateAjoutCtrl;
  late final TextEditingController _collecteurCtrl;

  // ── Location state ────────────────────────────────────────────────────────
  String? _gouvernorat;
  String? _delegation;

  bool get _isModification => widget.echantillon != null;

  @override
  void initState() {
    super.initState();
    final e = widget.echantillon;

    _refCtrl = TextEditingController(text: e?.referenceBouteille ?? '');
    _codeFournisseurCtrl = TextEditingController(
      text: e?.codeFournisseur ?? '',
    );
    _varieteCtrl = TextEditingController(text: e?.variete ?? '');
    _quantiteCtrl = TextEditingController(text: e?.quantiteEstimee ?? '');
    _collecteurCtrl = TextEditingController(text: e?.collecteurNom ?? '');
    _dateAjoutCtrl = TextEditingController(text: e?.dateAjout ?? _todayStr());

    _gouvernorat = e?.gouvernorat.isEmpty == true ? null : e?.gouvernorat;
    _delegation = e?.delegation;

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
    _dateAjoutCtrl.dispose();
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    Navigator.pop(context);

    final gouvernorat = _gouvernorat ?? '';
    final collecteur = _collecteurCtrl.text.trim().isEmpty
        ? null
        : _collecteurCtrl.text.trim();

    if (_isModification) {
      final e = widget.echantillon!;
      e.referenceBouteille = _refCtrl.text.trim();
      e.codeFournisseur = _codeFournisseurCtrl.text.trim();
      e.variete = _varieteCtrl.text.trim().isEmpty
          ? null
          : _varieteCtrl.text.trim();
      e.gouvernorat = gouvernorat;
      e.delegation = _delegation;
      e.quantiteEstimee = _quantiteCtrl.text.trim().isEmpty
          ? null
          : _quantiteCtrl.text.trim();
      e.dateAjout = _dateAjoutCtrl.text;
      e.collecteurNom = collecteur;
      widget.onSave(e);
    } else {
      widget.onSave(
        Echantillon(
          id: '${DateTime.now().year}/${widget.prochainNumero}',
          referenceBouteille: _refCtrl.text.trim(),
          codeFournisseur: _codeFournisseurCtrl.text.trim(),
          variete: _varieteCtrl.text.trim().isEmpty
              ? null
              : _varieteCtrl.text.trim(),
          dateAjout: _dateAjoutCtrl.text,
          gouvernorat: gouvernorat,
          delegation: _delegation,
          quantiteEstimee: _quantiteCtrl.text.trim().isEmpty
              ? null
              : _quantiteCtrl.text.trim(),
          statut: 'En attente',
          collecteurNom: collecteur,
          recuPhysiquement:
              true, // taster registers samples already present at company
        ),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
            // ── Dialog header ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              decoration: const BoxDecoration(
                color: _beige,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isModification
                        ? Icons.edit_outlined
                        : Icons.add_circle_outline,
                    color: _dark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isModification
                          ? "Modifier l'échantillon"
                          : 'Nouvel échantillon',
                      style: GoogleFonts.domine(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _dark,
                      ),
                    ),
                  ),
                  if (!_isModification)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(
                          255,
                          26,
                          46,
                          31,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${DateTime.now().year}/${widget.prochainNumero}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _dark,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormField(
                      label: 'Référence bouteille',
                      controller: _refCtrl,
                      hint: 'Ex: CHEMLALI-C1',
                      required: true,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: "Variété d'olive",
                      controller: _varieteCtrl,
                      hint: 'Ex: Chemlali, Chetoui…',
                      // optional: false,
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Quantité estimée',
                      controller: _quantiteCtrl,
                      hint: 'Ex: 5000',
                      keyboardType: TextInputType.number,
                      suffixText: 'T',
                      // optional: true,
                    ),

                    const SizedBox(height: 12),

                    // ── SECTION: FOURNISSEUR & COLLECTEUR ────────────────
                    _FormField(
                      label: 'Nom / Code fournisseur',
                      controller: _codeFournisseurCtrl,
                      hint: 'Ex: Domaine Bel-Air',
                    ),
                    const SizedBox(height: 12),
                    _FormField(
                      label: 'Collecteur',
                      controller: _collecteurCtrl,
                      hint: 'Ex: Ahmed Dridi',
                      // optional: true,
                    ),

                    const SizedBox(height: 12),

                    _DropdownField(
                      label: 'Gouvernorat',
                      value: _gouvernorat,
                      items: _geoLoaded
                          ? _geo.gouvernorats.toSet().toList()
                          : [],
                      hint: _geoLoaded
                          ? 'Sélectionner un gouvernorat'
                          : 'Chargement…',
                      onChanged: (v) => setState(() {
                        _gouvernorat = v;
                        _delegation = null;
                      }),
                    ),
                    const SizedBox(height: 12),

                    _DropdownField(
                      label: 'Délégation',
                      value: _delegation,
                      items: (_geoLoaded && _gouvernorat != null)
                          ? _geo.delegationsFor(_gouvernorat!).toSet().toList()
                          : [],
                      hint: _gouvernorat == null
                          ? "Choisir un gouvernorat d'abord"
                          : 'Sélectionner une délégation',
                      onChanged: _gouvernorat == null
                          ? null
                          : (v) => setState(() => _delegation = v),
                      //   optional: true,
                    ),

                    const SizedBox(height: 12),

                    // ── SECTION: DATE & STATUT ────────────────────────────
                    DateInputField(controller: _dateAjoutCtrl),
                    const SizedBox(height: 12),

                    // Statut — read-only
                    _ReadOnlyField(
                      label: 'Statut',
                      icon: Icons.flag_outlined,
                      value: _isModification
                          ? widget.echantillon!.statut
                          : 'En attente',
                    ),

                    const SizedBox(height: 12),

                    // ── SECTION: PHOTO (placeholder) ──────────────────────
                    _FieldLabel(label: 'Photo'),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _green.withValues(alpha: 0.25),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: _green.withValues(alpha: 0.55),
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ajouter une photo ',
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

            // ── Action buttons ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
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
                  const SizedBox(width: 20),
                  Expanded(
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
                        backgroundColor: const Color.fromARGB(
                          255,
                          197,
                          206,
                          201,
                        ),
                        foregroundColor: _dark,
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
// FIELD LABEL — standalone label row (used before DateInputField)
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  final bool optional;
  final double fontSize;
  const _FieldLabel({
    required this.label,
    this.optional = false,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: _olive,
        ),
      ),
      /*     if (optional)
        Text(
          ' (optionnel)',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),*/
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? suffixText;
  final bool required;
  final bool optional;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.suffixText,
    this.required = false,

    this.optional = false,
  });

  InputDecoration _dec() => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    suffixText: suffixText,
    suffixStyle: const TextStyle(
      color: _olive,
      fontWeight: FontWeight.w700,
      fontSize: 14,
    ),
    filled: true,
    fillColor: _fieldFill,
    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _olive,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            /*     if (optional)
              Text(
                ' (optionnel)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),*/
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _dark),
          decoration: _dec(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DROPDOWN FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final String hint;
  final ValueChanged<String?>? onChanged;
  final bool optional;

  const _DropdownField({
    required this.label,
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _olive,
              ),
            ),
            /*  if (optional)
              Text(
                ' (optionnel)',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),*/
          ],
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: onChanged == null,
          child: Opacity(
            opacity: onChanged == null ? 0.5 : 1.0,
            child: DropdownButtonFormField<String>(
              value: (value != null && items.contains(value)) ? value : null,
              isExpanded: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: _fieldFill,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 14,
                ),
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
// READ-ONLY FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;

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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _olive,
        ),
      ),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _fieldFill,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
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
