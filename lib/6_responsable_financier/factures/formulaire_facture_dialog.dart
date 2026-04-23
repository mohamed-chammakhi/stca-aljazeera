// ═════════════════════════════════════════════════════════════════════════════
// FILE : 6_responsable_financier/factures/formulaire_facture_dialog.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/facture.dart';
import '../../1_ceo/utilisateurs/models/echantillon_ceo_view.dart';

const Color _green  = Color(0xFF38835A);
const Color _dark   = Color(0xFF1A2E1F);
const Color _olive  = Color(0xFF6B8143);

void showFormulaireFactureDialog(
  BuildContext context, {
  required EchantillonCeoView echantillon,
  Facture? facture,
  void Function(Facture)? onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FormulaireFactureSheet(
      echantillon: echantillon,
      facture: facture,
      onSave: onSave,
    ),
  );
}

class _FormulaireFactureSheet extends StatefulWidget {
  final EchantillonCeoView echantillon;
  final Facture? facture;
  final void Function(Facture)? onSave;

  const _FormulaireFactureSheet({
    required this.echantillon,
    this.facture,
    this.onSave,
  });

  @override
  State<_FormulaireFactureSheet> createState() =>
      _FormulaireFactureSheetState();
}

class _FormulaireFactureSheetState extends State<_FormulaireFactureSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _quantiteCtrl;
  late TextEditingController _prixCtrl;
  late TextEditingController _notesCtrl;
  StatutFacture _statut = StatutFacture.brouillon;

  @override
  void initState() {
    super.initState();
    final f = widget.facture;
    _quantiteCtrl = TextEditingController(
      text: f?.quantiteT.toString() ??
          widget.echantillon.quantiteCibleT?.toString() ?? '',
    );
    _prixCtrl = TextEditingController(
      text: f?.prixUnitaireTnd.toString() ?? '',
    );
    _notesCtrl = TextEditingController(text: f?.notes ?? '');
    if (f != null) _statut = f.statut;
  }

  @override
  void dispose() {
    _quantiteCtrl.dispose();
    _prixCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _montant {
    final q = double.tryParse(_quantiteCtrl.text) ?? 0;
    final p = double.tryParse(_prixCtrl.text) ?? 0;
    return q * p;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    final dateStr =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final newFacture = Facture(
      id: widget.facture?.id ?? 'fac-${DateTime.now().millisecondsSinceEpoch}',
      numeroFacture: widget.facture?.numeroFacture ??
          'FAC-${now.year}-${(mockFactures.length + 1).toString().padLeft(4, '0')}',
      achatId: widget.echantillon.id,
      referenceBouteille: widget.echantillon.referenceBouteille,
      fournisseur: widget.echantillon.codeFournisseur,
      gouvernorat: widget.echantillon.gouvernorat,
      quantiteT: double.parse(_quantiteCtrl.text),
      prixUnitaireTnd: double.parse(_prixCtrl.text),
      montantTotal: _montant,
      statut: _statut,
      dateCreation: widget.facture?.dateCreation ?? dateStr,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.pop(context);
    widget.onSave?.call(newFacture);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.echantillon;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Handle ────────────────────────────────────────────────
                Center(
                  child: Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  widget.facture == null
                      ? 'Créer une facture'
                      : 'Modifier la facture',
                  style: GoogleFonts.domine(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _dark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${e.referenceBouteille} · ${e.gouvernorat}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 20),

                // ── Pre-filled read-only info ─────────────────────────────
                _InfoRow(label: 'N° échantillon', value: e.id),
                _InfoRow(label: 'Fournisseur', value: e.codeFournisseur),
                if (e.variete != null)
                  _InfoRow(label: 'Variété', value: e.variete!),
                const SizedBox(height: 16),

                // ── Editable fields ───────────────────────────────────────
                _fieldLabel('Quantité (T)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _quantiteCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  decoration: _inputDeco('ex: 12.5'),
                ),
                const SizedBox(height: 14),

                _fieldLabel('Prix unitaire (DT/T)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _prixCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  onChanged: (_) => setState(() {}),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                  decoration: _inputDeco('ex: 4200'),
                ),
                const SizedBox(height: 14),

                // ── Live total ────────────────────────────────────────────
                if (_montant > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _green.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _green.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Montant total',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _dark),
                        ),
                        Text(
                          '${_montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ')} DT',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: _green,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 14),

                _fieldLabel('Statut'),
                const SizedBox(height: 6),
                _StatutSelector(
                  value: _statut,
                  onChanged: (v) => setState(() => _statut = v),
                ),
                const SizedBox(height: 14),

                _fieldLabel('Notes (optionnel)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: _inputDeco('Informations complémentaires…'),
                ),
                const SizedBox(height: 24),

                // ── Actions ───────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade600,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Annuler'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.receipt_long_outlined, size: 16, color: Colors.white),
                        label: Text(
                          widget.facture == null ? 'Créer la facture' : 'Enregistrer',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: _olive,
      letterSpacing: 0.4,
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
    filled: true,
    fillColor: Colors.grey.shade50,
    contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
class _StatutSelector extends StatelessWidget {
  final StatutFacture value;
  final ValueChanged<StatutFacture> onChanged;
  const _StatutSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: StatutFacture.values.map((s) {
        final selected = value == s;
        final color = _statutColor(s);
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? color.withValues(alpha: 0.12) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected ? color.withValues(alpha: 0.5) : Colors.grey.shade200,
                  width: selected ? 1.5 : 1.0,
                ),
              ),
              child: Text(
                s.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? color : Colors.grey.shade500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _statutColor(StatutFacture s) {
    switch (s) {
      case StatutFacture.brouillon: return Colors.grey.shade600;
      case StatutFacture.emise:     return const Color(0xFFD07B2F);
      case StatutFacture.payee:     return _green;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ),
        Expanded(child: Text(value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _dark))),
      ],
    ),
  );
}
