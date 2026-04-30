// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/widgets/dialogs/formulaire_dialog.dart
// PURPOSE : add / edit dialog for one or more Echantillons (degustateur module)
//           — in add mode: multiple bouteilles per fournisseur, each becomes its
//             own card in the list (same pattern as formulaire_collecteur_dialog)
//           — shared fields: collecteur, fournisseur, gouvernorat, délégation,
//             date d'arrivée, statut (read-only), photo, action buttons
//           — per-bouteille fields: référence, variété, scellage, quantité
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/echantillon.dart';
import '../../../../core/models/enums.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLE ROW — one row per bottle in the list
// ─────────────────────────────────────────────────────────────────────────────
class _BouteilleRow {
  final TextEditingController refCtrl;
  final TextEditingController varieteCtrl;
  final TextEditingController scellageCtrl;
  final TextEditingController qteCtrl;

  _BouteilleRow({
    required this.refCtrl,
    required this.varieteCtrl,
    required this.scellageCtrl,
    required this.qteCtrl,
  });

  factory _BouteilleRow.empty() => _BouteilleRow(
    refCtrl: TextEditingController(),
    varieteCtrl: TextEditingController(),
    scellageCtrl: TextEditingController(),
    qteCtrl: TextEditingController(),
  );

  factory _BouteilleRow.fromSample(Echantillon e) => _BouteilleRow(
    refCtrl: TextEditingController(text: e.referenceBouteille),
    varieteCtrl: TextEditingController(text: e.variete ?? ''),
    scellageCtrl: TextEditingController(text: e.scellage ?? ''),
    qteCtrl: TextEditingController(text: e.quantiteEstimee ?? ''),
  );

  void dispose() {
    refCtrl.dispose();
    varieteCtrl.dispose();
    scellageCtrl.dispose();
    qteCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────
void showFormulaireDialog(
  BuildContext context, {
  Echantillon? echantillon,
  required int prochainNumero,
  required Function(List<Echantillon>) onSaveMultiple,
}) {
  showDialog(
    context: context,
    builder: (_) => _FormulaireDialog(
      echantillon: echantillon,
      prochainNumero: prochainNumero,
      onSaveMultiple: onSaveMultiple,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATEFUL DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _FormulaireDialog extends StatefulWidget {
  final Echantillon? echantillon;
  final int prochainNumero;
  final Function(List<Echantillon>) onSaveMultiple;

  const _FormulaireDialog({
    required this.echantillon,
    required this.prochainNumero,
    required this.onSaveMultiple,
  });

  @override
  State<_FormulaireDialog> createState() => _FormulaireDialogState();
}

class _FormulaireDialogState extends State<_FormulaireDialog> {
  // ── GeoService ────────────────────────────────────────────────────────────
  final GeoService _geo = GeoService.instance;
  bool _geoLoaded = false;

  // ── Shared controllers ───────────────────────────────────────────────────
  late final TextEditingController _codeFournisseurCtrl;
  late final TextEditingController _collecteurCtrl;
  late final TextEditingController _dateAjoutCtrl;
  late final TextEditingController _remarquesCtrl;

  // ── Location state ────────────────────────────────────────────────────────
  String? _gouvernorat;
  String? _delegation;

  // ── Per-bouteille rows ────────────────────────────────────────────────────
  final List<_BouteilleRow> _bouteilles = [];

  bool get _isModification => widget.echantillon != null;
  int get _bottleCount => _bouteilles.length;

  @override
  void initState() {
    super.initState();
    final e = widget.echantillon;

    _codeFournisseurCtrl = TextEditingController(
      text: e?.codeFournisseur ?? '',
    );
    _collecteurCtrl = TextEditingController(text: e?.collecteurNom ?? '');
    _dateAjoutCtrl = TextEditingController(text: e?.dateAjout ?? _todayStr());
    _remarquesCtrl = TextEditingController(text: e?.remarques ?? '');

    _gouvernorat = e?.gouvernorat.isEmpty == true ? null : e?.gouvernorat;
    _delegation = e?.delegation;

    // Seed with one row (pre-filled for edit, empty for add)
    _bouteilles.add(
      e != null ? _BouteilleRow.fromSample(e) : _BouteilleRow.empty(),
    );

    _geo.load().then((_) {
      if (mounted) setState(() => _geoLoaded = true);
    });
  }

  @override
  void dispose() {
    _codeFournisseurCtrl.dispose();
    _collecteurCtrl.dispose();
    _dateAjoutCtrl.dispose();
    _remarquesCtrl.dispose();
    for (final b in _bouteilles) {
      b.dispose();
    }
    super.dispose();
  }

  String _todayStr() {
    final n = DateTime.now();
    return '${n.day.toString().padLeft(2, '0')}/'
        '${n.month.toString().padLeft(2, '0')}/${n.year}';
  }

  void _addRow() => setState(() => _bouteilles.add(_BouteilleRow.empty()));

  void _removeRow(int index) {
    setState(() {
      _bouteilles[index].dispose();
      _bouteilles.removeAt(index);
    });
  }

  bool get _isValid {
    if (_bouteilles.isEmpty) return false;
    return _bouteilles.every((b) => b.refCtrl.text.trim().isNotEmpty);
  }

  void _save() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'La référence est obligatoire pour chaque bouteille',
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

    Navigator.pop(context);

    final gouvernorat = _gouvernorat ?? '';
    final collecteur = _collecteurCtrl.text.trim().isEmpty
        ? null
        : _collecteurCtrl.text.trim();
    final codeFournisseur = _codeFournisseurCtrl.text.trim().isEmpty
        ? null
        : _codeFournisseurCtrl.text.trim();

    if (_isModification) {
      final e = widget.echantillon!;
      final b = _bouteilles.first;
      e.referenceBouteille = b.refCtrl.text.trim();
      e.variete = b.varieteCtrl.text.trim().isEmpty
          ? null
          : b.varieteCtrl.text.trim();
      e.scellage = b.scellageCtrl.text.trim().isEmpty
          ? null
          : b.scellageCtrl.text.trim();
      e.quantiteEstimee = b.qteCtrl.text.trim().isEmpty
          ? null
          : b.qteCtrl.text.trim();
      e.gouvernorat = gouvernorat;
      e.delegation = _delegation;
      e.remarques = _remarquesCtrl.text.trim().isEmpty
          ? null
          : _remarquesCtrl.text.trim();
      // codeFournisseur, dateAjout, collecteurNom are API-assigned — not mutated
      widget.onSaveMultiple([e]);
    } else {
      final now = DateTime.now();
      final samples = _bouteilles.asMap().entries.map((entry) {
        final idx = entry.key;
        final b = entry.value;
        final numero = widget.prochainNumero + idx;
        return Echantillon(
          id: 'new-${now.millisecondsSinceEpoch}-$idx',
          ref: '${now.year}/${numero.toString().padLeft(4, '0')}',
          fournisseurId: 'fournisseur-placeholder',
          collecteurId: 'collecteur-placeholder',
          codeFournisseur: codeFournisseur,
          collecteurNom: collecteur,
          referenceBouteille: b.refCtrl.text.trim(),
          variete: b.varieteCtrl.text.trim().isEmpty
              ? null
              : b.varieteCtrl.text.trim(),
          scellage: b.scellageCtrl.text.trim().isEmpty
              ? null
              : b.scellageCtrl.text.trim(),
          gouvernorat: gouvernorat,
          delegation: _delegation,
          remarques: _remarquesCtrl.text.trim().isEmpty
              ? null
              : _remarquesCtrl.text.trim(),
          quantiteEstimee: b.qteCtrl.text.trim().isEmpty
              ? null
              : b.qteCtrl.text.trim(),
          dateAjout: _dateAjoutCtrl.text,
          statutCollecteur: StatutCollecteur.receptionne,
          statutDegustateur: StatutDegustateur.enAttente,
          recuPhysiquement: true,
        );
      }).toList();
      widget.onSaveMultiple(samples);
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
                  // ID badge — add mode only
                  if (!_isModification)
                    _IdBadge(
                      prochainNumero: widget.prochainNumero,
                      bottleCount: _bottleCount,
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
                    // ── SHARED: FOURNISSEUR & COLLECTEUR ─────────────────
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
                    ),

                    const SizedBox(height: 12),

                    // ── SHARED: LOCALISATION ─────────────────────────────
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
                    ),

                    const SizedBox(height: 12),

                    // ── PER-BOUTEILLE SECTION ─────────────────────────────
                    _BouteillesSection(
                      bouteilles: _bouteilles,
                      isModification: _isModification,
                      onAddRow: _addRow,
                      onRemoveRow: _removeRow,
                    ),

                    const SizedBox(height: 12),
                    // ── SHARED: DATE ──────────────────────────────────────
                    DateInputField(controller: _dateAjoutCtrl),
                    const SizedBox(height: 12),

                    // ── SHARED: STATUT (read-only) ────────────────────────
                    _ReadOnlyField(
                      label: 'Statut',
                      icon: Icons.flag_outlined,
                      value: _isModification
                          ? (widget.echantillon!.statutDegustateur?.label ??
                                'En attente')
                          : 'En attente',
                    ),

                    const SizedBox(height: 16),
                    // ── SHARED: PHOTO (placeholder) ───────────────────────
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

                    const SizedBox(height: 12),

                    // ── SHARED: REMARQUES ─────────────────────────────────
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Remarques',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _olive,
                              ),
                            ),
                            Text(
                              ' (optionnel)',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _remarquesCtrl,
                          maxLines: 3,
                          minLines: 2,
                          style: const TextStyle(fontSize: 14, color: _dark),
                          decoration: InputDecoration(
                            hintText: 'Notes, observations particulières...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                            filled: true,
                            fillColor: _fieldFill,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: _green,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        _isModification
                            ? 'Enregistrer'
                            : _bottleCount > 1
                            ? 'Ajouter $_bottleCount échantillons'
                            : 'Ajouter',
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
// ID BADGE — shows auto-generated ref range (add mode only)
// ─────────────────────────────────────────────────────────────────────────────
class _IdBadge extends StatelessWidget {
  final int prochainNumero;
  final int bottleCount;

  const _IdBadge({required this.prochainNumero, required this.bottleCount});

  @override
  Widget build(BuildContext context) {
    final year = DateTime.now().year;
    final from = prochainNumero.toString().padLeft(4, '0');
    final to = (prochainNumero + bottleCount - 1).toString().padLeft(4, '0');
    final label = bottleCount > 1 ? '$year/$from → $to' : '$year/$from';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 26, 46, 31).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _dark,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLES SECTION — list of per-bottle cards with add/remove controls
// ─────────────────────────────────────────────────────────────────────────────
class _BouteillesSection extends StatelessWidget {
  final List<_BouteilleRow> bouteilles;
  final bool isModification;
  final VoidCallback onAddRow;
  final ValueChanged<int> onRemoveRow;

  const _BouteillesSection({
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
        // Section header row with "Ajouter une bouteille" button
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bouteilles *',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _olive,
              ),
            ),
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
                    color: _green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _green.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, size: 14, color: _green),
                      SizedBox(width: 4),
                      Text(
                        'Ajouter une bouteille',
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
        // Info banner when multiple bottles
        if (!isModification && count > 1) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: _green.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$count bouteilles → $count échantillons séparés seront créés',
                    style: TextStyle(
                      fontSize: 11,
                      color: _green.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        // Bottle cards
        ...List.generate(
          count,
          (i) => _BouteilleCard(
            row: bouteilles[i],
            index: i,
            showRemove: !isModification && count > 1,
            onRemove: () => onRemoveRow(i),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BOUTEILLE CARD — ref, variété, scellage, quantité fields for one bottle
// ─────────────────────────────────────────────────────────────────────────────
class _BouteilleCard extends StatelessWidget {
  final _BouteilleRow row;
  final int index;
  final bool showRemove;
  final VoidCallback onRemove;

  const _BouteilleCard({
    required this.row,
    required this.index,
    required this.showRemove,
    required this.onRemove,
  });

  InputDecoration _fieldDec(String hint, {String? suffixText}) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        suffixText: suffixText,
        suffixStyle: const TextStyle(
          color: _olive,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
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
          borderSide: const BorderSide(color: _green, width: 1.8),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header: bottle label + remove button
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Bouteille ${index + 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
              const Spacer(),
              if (showRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 15,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Référence bouteille *
          _InlineLabel(label: 'Référence bouteille', required: true),
          const SizedBox(height: 5),
          TextField(
            controller: row.refCtrl,
            style: const TextStyle(fontSize: 13, color: _dark),
            decoration: _fieldDec('Ex: CHEMLALI-C1'),
          ),
          const SizedBox(height: 8),

          // Variété + Scellage (side by side)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineLabel(label: "Variété d'olive"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: row.varieteCtrl,
                      style: const TextStyle(fontSize: 13, color: _dark),
                      decoration: _fieldDec('Ex: Chemlali'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InlineLabel(label: 'Scellage'),
                    const SizedBox(height: 5),
                    TextField(
                      controller: row.scellageCtrl,
                      style: const TextStyle(fontSize: 13, color: _dark),
                      decoration: _fieldDec('Ex: Z1'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quantité estimée
          _InlineLabel(label: 'Quantité estimée'),
          const SizedBox(height: 5),
          TextField(
            controller: row.qteCtrl,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, color: _dark),
            decoration: _fieldDec('Ex: 5000', suffixText: 'T'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INLINE LABEL — small label above a field inside a card
// ─────────────────────────────────────────────────────────────────────────────
class _InlineLabel extends StatelessWidget {
  final String label;
  final bool required;

  const _InlineLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
      if (required)
        const Text(' *', style: TextStyle(fontSize: 11, color: Colors.red)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD LABEL — standalone label row (used before DateInputField)
// ─────────────────────────────────────────────────────────────────────────────
class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _olive,
        ),
      ),
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

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  InputDecoration _dec() => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _olive,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
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

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.hint,
    required this.onChanged,
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
          ],
        ),
        const SizedBox(height: 6),
        IgnorePointer(
          ignoring: onChanged == null,
          child: Opacity(
            opacity: onChanged == null ? 0.5 : 1.0,
            child: DropdownButtonFormField<String>(
              initialValue: (value != null && items.contains(value)) ? value : null,
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
