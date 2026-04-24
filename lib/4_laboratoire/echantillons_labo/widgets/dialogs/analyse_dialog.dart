// ═════════════════════════════════════════════════════════════════════════════
// FILE : laboratoire/echantillons_labo/widgets/dialogs/analyse_dialog.dart
// PURPOSE : Full-screen dialog for adding/editing a lab analysis report.
//           Two entry modes: MANUAL form OR scan (triggers scan_rapport_dialog)
//
// STRUCTURE:
//   AnalyseDialog         — entry-point bottom sheet: choose Manual or Scan
//   ManuelAnalyseForm     — tabbed form with all COI physicochemical fields
//   _FieldRow             — helper for labeled numeric input
//   _SectionHeader        — visual section divider
//   _ClassificationResult — live auto-classification strip
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../analyse_labo.dart';
import '../../models/echantillon_labo.dart';
import 'scan_rapport_dialog.dart';
import 'formulaire_analyse_labo_dialog.dart';

const Color _green = Color(0xFF38835A);
const Color _cream = Color(0xFFF9F6EF);
const Color _darkText = Color(0xFF1A2E1F);

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT  — shown when "Ajouter une analyse" is tapped
// ─────────────────────────────────────────────────────────────────────────────
void showAnalyseChoiceSheet(
  BuildContext context, {
  required EchantillonLabo echantillon,
  AnalyseLabo? existing,
  required void Function(AnalyseLabo) onSave,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (_) => _ChoiceSheet(
      echantillon: echantillon,
      existing:    existing,
      onSave:      onSave,
    ),
  );
}

class _ChoiceSheet extends StatelessWidget {
  final EchantillonLabo echantillon;
  final AnalyseLabo?    existing;
  final void Function(AnalyseLabo) onSave;

  const _ChoiceSheet({
    required this.echantillon,
    this.existing,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Ajouter un rapport d\'analyse',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            echantillon.referenceBouteille,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 28),

          // ── SCAN option ────────────────────────────────────────────────
          _OptionTile(
            icon: Icons.document_scanner_outlined,
            title: 'Scanner le rapport papier',
            subtitle:
                'Prenez une photo du rapport imprimé — les valeurs seront extraites automatiquement',
            color: const Color(0xFF1565C0),
            onTap: () {
              Navigator.pop(context);
              showScanRapportDialog(
                context,
                echantillon: echantillon,
                onSave: onSave,
              );
            },
          ),
          const SizedBox(height: 12),

          // ── MANUAL option ──────────────────────────────────────────────
          _OptionTile(
            icon: Icons.edit_note_outlined,
            title: 'Saisir manuellement',
            subtitle:
                'Remplissez les champs un par un selon les résultats du laboratoire',
            color: _green,
            onTap: () {
              Navigator.pop(context);
              showFormulaireAnalyseLaboDialog(
                context,
                echantillonRef: echantillon.referenceBouteille,
                echantillonId:  echantillon.id,
                analyse:        existing,
                onSave:         onSave,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: color.withOpacity(0.6),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// MANUAL FORM  — full-screen dialog with all COI fields
// ─────────────────────────────────────────────────────────────────────────────
void showManuelAnalyseForm(
  BuildContext context, {
  required EchantillonLabo echantillon,
  AnalyseLabo? existing,
  required void Function(AnalyseLabo) onSave,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => ManuelAnalyseForm(
      echantillon: echantillon,
      existing: existing,
      onSave: onSave,
    ),
  );
}

class ManuelAnalyseForm extends StatefulWidget {
  final EchantillonLabo echantillon;
  final AnalyseLabo? existing;
  final void Function(AnalyseLabo) onSave;

  const ManuelAnalyseForm({
    super.key,
    required this.echantillon,
    this.existing,
    required this.onSave,
  });

  @override
  State<ManuelAnalyseForm> createState() => _ManuelAnalyseFormState();
}

class _ManuelAnalyseFormState extends State<ManuelAnalyseForm>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  // ── Controllers for every field ───────────────────────────────────────────
  final _aciditeCtrl = TextEditingController();
  final _peroxydeCtrl = TextEditingController();
  final _k232Ctrl = TextEditingController();
  final _k270Ctrl = TextEditingController();
  final _deltaKCtrl = TextEditingController();
  final _humiditeCtrl = TextEditingController();
  final _impuretesCtrl = TextEditingController();
  final _polyphenolsCtrl = TextEditingController();
  final _tocophCtrl = TextEditingController();
  final _oleicCtrl = TextEditingController();
  final _linoleicCtrl = TextEditingController();
  final _palmiticCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _classif = '—';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    if (widget.existing != null) _populate(widget.existing!);
    _aciditeCtrl.addListener(_recompute);
    _peroxydeCtrl.addListener(_recompute);
    _k270Ctrl.addListener(_recompute);
    _k232Ctrl.addListener(_recompute);
  }

  void _populate(AnalyseLabo a) {
    if (a.aciditeLibre != null) _aciditeCtrl.text = a.aciditeLibre.toString();
    if (a.indicePeroxyde != null)
      _peroxydeCtrl.text = a.indicePeroxyde.toString();
    if (a.k232 != null) _k232Ctrl.text = a.k232.toString();
    if (a.k270 != null) _k270Ctrl.text = a.k270.toString();
    if (a.deltaK != null) _deltaKCtrl.text = a.deltaK.toString();
    if (a.humidite != null) _humiditeCtrl.text = a.humidite.toString();
    if (a.impuretes != null) _impuretesCtrl.text = a.impuretes.toString();
    if (a.polyphenolsTotaux != null)
      _polyphenolsCtrl.text = a.polyphenolsTotaux.toString();
    if (a.tocopherols != null) _tocophCtrl.text = a.tocopherols.toString();
    if (a.acideOleique != null) _oleicCtrl.text = a.acideOleique.toString();
    if (a.acideLinoleique != null)
      _linoleicCtrl.text = a.acideLinoleique.toString();
    if (a.acidePalmitique != null)
      _palmiticCtrl.text = a.acidePalmitique.toString();
    if (a.notes != null) _notesCtrl.text = a.notes!;
  }

  void _recompute() {
    final acide = double.tryParse(_aciditeCtrl.text);
    final perox = double.tryParse(_peroxydeCtrl.text);
    final k270 = double.tryParse(_k270Ctrl.text);
    final k232 = double.tryParse(_k232Ctrl.text);

    String c = '—';
    if (acide != null && perox != null) {
      if (acide <= 0.8 &&
          perox <= 20 &&
          (k270 == null || k270 <= 0.22) &&
          (k232 == null || k232 <= 2.50)) {
        c = 'Extra Vierge';
      } else if (acide <= 2.0 && perox <= 20) {
        c = 'Vierge';
      } else {
        c = 'Lampante';
      }
    }
    if (mounted) setState(() => _classif = c);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final analyse = AnalyseLabo(
      echantillonId: widget.echantillon.id,
      echantillonRef: widget.echantillon.ref,
      aciditeLibre: double.tryParse(_aciditeCtrl.text),
      indicePeroxyde: double.tryParse(_peroxydeCtrl.text),
      k232: double.tryParse(_k232Ctrl.text),
      k270: double.tryParse(_k270Ctrl.text),
      deltaK: double.tryParse(_deltaKCtrl.text),
      humidite: double.tryParse(_humiditeCtrl.text),
      impuretes: double.tryParse(_impuretesCtrl.text),
      polyphenolsTotaux: double.tryParse(_polyphenolsCtrl.text),
      tocopherols: double.tryParse(_tocophCtrl.text),
      acideOleique: double.tryParse(_oleicCtrl.text),
      acideLinoleique: double.tryParse(_linoleicCtrl.text),
      acidePalmitique: double.tryParse(_palmiticCtrl.text),
      classification: _classif == '—' ? null : _classif,
      statut: StatutAnalyse.soumis,
      dateAnalyse: _today(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );
    Navigator.pop(context);
    widget.onSave(analyse);
  }

  String _today() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [
      _aciditeCtrl,
      _peroxydeCtrl,
      _k232Ctrl,
      _k270Ctrl,
      _deltaKCtrl,
      _humiditeCtrl,
      _impuretesCtrl,
      _polyphenolsCtrl,
      _tocophCtrl,
      _oleicCtrl,
      _linoleicCtrl,
      _palmiticCtrl,
      _notesCtrl,
    ])
      c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: _cream,
        appBar: AppBar(
          backgroundColor: _green,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rapport d\'analyse',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.echantillon.referenceBouteille,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _submit,
              child: const Text(
                'SOUMETTRE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
          bottom: TabBar(
            controller: _tab,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            tabs: const [
              Tab(text: 'ESSENTIELS'),
              Tab(text: 'QUALITÉ'),
              Tab(text: 'ACIDES GRAS'),
            ],
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Live classification banner ──────────────────────────────
              _ClassificationBanner(classification: _classif),

              // ── Tabbed content ─────────────────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    // Tab 1 — Essential COI parameters
                    _buildEssentialsTab(),
                    // Tab 2 — Quality indicators
                    _buildQualiteTab(),
                    // Tab 3 — Fatty acid profile
                    _buildAcideGrasTab(),
                  ],
                ),
              ),

              // ── Submit button ──────────────────────────────────────────
              _SubmitFooter(onSubmit: _submit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEssentielsTab() => _FormTab(
    children: [
      _SectionHeader(
        icon: Icons.warning_amber_outlined,
        title: 'Paramètres de base COI',
        subtitle: 'Obligatoires pour la classification',
      ),
      _FieldRow(
        controller: _aciditeCtrl,
        label: 'Acidité libre',
        unit: '% ac. oléique',
        hint: 'ex: 0.42',
        norm: '≤ 0.80 (Extra Vierge)',
        required: true,
      ),
      _FieldRow(
        controller: _peroxydeCtrl,
        label: 'Indice de peroxyde',
        unit: 'meqO₂/kg',
        hint: 'ex: 8.0',
        norm: '≤ 20 (Extra Vierge)',
        required: true,
      ),
      _FieldRow(
        controller: _k232Ctrl,
        label: 'Absorbance UV K₂₃₂',
        unit: '',
        hint: 'ex: 1.85',
        norm: '≤ 2.50 (Extra Vierge)',
        required: true,
      ),
      _FieldRow(
        controller: _k270Ctrl,
        label: 'Absorbance UV K₂₇₀',
        unit: '',
        hint: 'ex: 0.15',
        norm: '≤ 0.22 (Extra Vierge)',
        required: true,
      ),
      _FieldRow(
        controller: _deltaKCtrl,
        label: 'ΔK (Delta-K)',
        unit: '',
        hint: 'ex: 0.005',
        norm: '≤ 0.01 (Extra Vierge)',
      ),
      _SectionHeader(
        icon: Icons.water_drop_outlined,
        title: 'Contaminants physiques',
        subtitle: 'Teneur en eau et impuretés',
      ),
      _FieldRow(
        controller: _humiditeCtrl,
        label: 'Humidité & matières volatiles',
        unit: '%',
        hint: 'ex: 0.15',
        norm: '≤ 0.20',
      ),
      _FieldRow(
        controller: _impuretesCtrl,
        label: 'Impuretés insolubles',
        unit: '%',
        hint: 'ex: 0.05',
        norm: '≤ 0.10',
      ),
    ],
  );

  Widget _buildEssentialsTab() => _buildEssentielsTab();

  Widget _buildQualiteTab() => _FormTab(
    children: [
      _SectionHeader(
        icon: Icons.star_outline,
        title: 'Indicateurs de qualité',
        subtitle: 'Antioxydants et composés bénéfiques',
      ),
      _FieldRow(
        controller: _polyphenolsCtrl,
        label: 'Polyphénols totaux',
        unit: 'mg/kg',
        hint: 'ex: 320',
        norm: 'Élevé = meilleure qualité',
      ),
      _FieldRow(
        controller: _tocophCtrl,
        label: 'tocopherols (Vit. E)',
        unit: 'mg/kg',
        hint: 'ex: 250',
        norm: 'Indicateur antioxydant',
      ),
      const SizedBox(height: 20),
      _SectionHeader(
        icon: Icons.notes_outlined,
        title: 'Remarques',
        subtitle: 'Observations du technicien',
      ),
      _NotesField(controller: _notesCtrl),
    ],
  );

  Widget _buildAcideGrasTab() => _FormTab(
    children: [
      _SectionHeader(
        icon: Icons.biotech_outlined,
        title: 'Profil en acides gras',
        subtitle: 'Composition lipidique de l\'huile',
      ),
      _FieldRow(
        controller: _oleicCtrl,
        label: 'Acide oléique (C18:1)',
        unit: '%',
        hint: 'ex: 72.0',
        norm: 'Plage normale: 55 – 83%',
      ),
      _FieldRow(
        controller: _linoleicCtrl,
        label: 'Acide linoléique (C18:2)',
        unit: '%',
        hint: 'ex: 10.5',
        norm: 'Plage normale: 2.5 – 21%',
      ),
      _FieldRow(
        controller: _palmiticCtrl,
        label: 'Acide palmitique (C16:0)',
        unit: '%',
        hint: 'ex: 11.5',
        norm: 'Plage normale: 7.5 – 20%',
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPER WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ClassificationBanner extends StatelessWidget {
  final String classification;
  const _ClassificationBanner({required this.classification});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    if (classification == 'Extra Vierge') {
      color = _green;
      icon = Icons.verified_outlined;
    } else if (classification == 'Vierge') {
      color = Colors.orange.shade700;
      icon = Icons.check_circle_outline;
    } else if (classification == 'Lampante') {
      color = Colors.red.shade700;
      icon = Icons.cancel_outlined;
    } else {
      color = Colors.grey.shade500;
      icon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color.withOpacity(0.08),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            'Classification automatique : ',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          Text(
            classification,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FormTab extends StatelessWidget {
  final List<Widget> children;
  const _FormTab({required this.children});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 12),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: _green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _green, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: _darkText,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    ),
  );
}

class _FieldRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String unit;
  final String hint;
  final String norm;
  final bool required;

  const _FieldRow({
    required this.controller,
    required this.label,
    required this.unit,
    required this.hint,
    required this.norm,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _darkText,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          validator: required
              ? (v) => (v == null || v.isEmpty) ? 'Champ obligatoire' : null
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixText: unit,
            suffixStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
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
              borderSide: const BorderSide(color: _green, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade300),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(norm, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      ],
    ),
  );
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  const _NotesField({required this.controller});

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    maxLines: 4,
    decoration: InputDecoration(
      hintText: 'Observations, anomalies ou commentaires du technicien...',
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(14),
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
  );
}

class _SubmitFooter extends StatelessWidget {
  final VoidCallback onSubmit;
  const _SubmitFooter({required this.onSubmit});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onSubmit,
        icon: const Icon(Icons.check_circle_outline, size: 20),
        label: const Text(
          'Soumettre l\'analyse',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    ),
  );
}
