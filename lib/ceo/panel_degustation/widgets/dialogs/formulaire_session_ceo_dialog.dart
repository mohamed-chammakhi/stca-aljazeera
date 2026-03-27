// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/panel_degustation/widgets/dialogs/formulaire_session_ceo_dialog.dart
// PURPOSE : Dialog to create a new tasting session (CEO only)
//           Requires minimum 4 panel members per COI guidelines
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/session_ceo.dart';

void showFormulaireSessionCeoDialog(
  BuildContext context, {
  required void Function(SessionCeo session) onSave,
}) {
  showDialog(
    context: context,
    builder: (ctx) => _FormulaireSessionCeoDialog(onSave: onSave),
  );
}

class _FormulaireSessionCeoDialog extends StatefulWidget {
  final void Function(SessionCeo session) onSave;
  const _FormulaireSessionCeoDialog({required this.onSave});

  @override
  State<_FormulaireSessionCeoDialog> createState() =>
      _FormulaireSessionCeoDialogState();
}

class _FormulaireSessionCeoDialogState
    extends State<_FormulaireSessionCeoDialog> {
  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

  final _titreCtrl = TextEditingController();
  final _lieuCtrl = TextEditingController();
  DateTime? _date;
  TimeOfDay? _heure;

  // Mock available panel members — replace with API
  final List<_MembreMock> _available = [
    _MembreMock('D01', 'Ali Ben Salem'),
    _MembreMock('D02', 'Sara Mbarki'),
    _MembreMock('D03', 'Hedi Rjaibi'),
    _MembreMock('D04', 'Leila Khemiri'),
    _MembreMock('D05', 'Karim Trabelsi'),
    _MembreMock('D06', 'Nour Mansouri'),
  ];
  final Set<String> _selectedIds = {};

  // Mock available samples — replace with API
  final List<String> _availableSamples = [
    'ECH-001', 'ECH-002', 'ECH-004', 'ECH-005', 'ECH-006',
  ];
  final Set<String> _selectedSamples = {};

  bool get _isValid =>
      _titreCtrl.text.trim().isNotEmpty &&
      _lieuCtrl.text.trim().isNotEmpty &&
      _date != null &&
      _heure != null &&
      _selectedIds.length >= 4 &&
      _selectedSamples.isNotEmpty;

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  void dispose() {
    _titreCtrl.dispose();
    _lieuCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF9F6EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.wine_bar_outlined, color: _green, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'Nouvelle session',
                  style: GoogleFonts.domine(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Titre
            _label('Titre de la session *'),
            _field(_titreCtrl, 'Ex: Session Mars 2026 — Lot A', Icons.title_outlined),
            const SizedBox(height: 14),

            // Date + Heure
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Date *'),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 15, color: _green),
                              const SizedBox(width: 6),
                              Text(
                                _date != null ? _fmt(_date!) : 'JJ/MM/AAAA',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _date != null
                                      ? _darkText
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Heure *'),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setState(() => _heure = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_outlined,
                                  size: 15, color: _green),
                              const SizedBox(width: 6),
                              Text(
                                _heure != null
                                    ? _heure!.format(context)
                                    : 'HH:MM',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _heure != null
                                      ? _darkText
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Lieu
            _label('Lieu *'),
            _field(_lieuCtrl, 'Ex: Salle de dégustation — Siège', Icons.place_outlined),
            const SizedBox(height: 16),

            // Échantillons
            _label('Échantillons à évaluer *'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _availableSamples.map((id) {
                final sel = _selectedSamples.contains(id);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (sel) _selectedSamples.remove(id);
                    else _selectedSamples.add(id);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? _green : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: sel ? _green : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      id,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Panel members
            Row(
              children: [
                _label('Dégustateurs *'),
                const Spacer(),
                Text(
                  '${_selectedIds.length} sélectionné(s) — min. 4',
                  style: TextStyle(
                    fontSize: 11,
                    color: _selectedIds.length < 4
                        ? Colors.orange.shade700
                        : _green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._available.map((m) {
              final sel = _selectedIds.contains(m.id);
              return GestureDetector(
                onTap: () => setState(() {
                  if (sel) _selectedIds.remove(m.id);
                  else _selectedIds.add(m.id);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? _green.withOpacity(0.06) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: sel ? _green.withOpacity(0.4) : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        sel ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                        color: sel ? _green : Colors.grey.shade400,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        m.nom,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? _darkText : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Actions
            Row(
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
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isValid
                        ? () {
                            Navigator.pop(context);
                            widget.onSave(SessionCeo(
                              id: 'S-${DateTime.now().millisecondsSinceEpoch}',
                              titre: _titreCtrl.text.trim(),
                              date: _fmt(_date!),
                              heure: _heure!.format(context),
                              lieu: _lieuCtrl.text.trim(),
                              echantillonIds: _selectedSamples.toList(),
                              membreIds: _selectedIds.toList(),
                              membreNoms: _available
                                  .where((m) => _selectedIds.contains(m.id))
                                  .map((m) => m.nom)
                                  .toList(),
                              soumissions: 0,
                              statut: StatutSessionCeo.planifiee,
                              createdAt: DateTime.now(),
                            ));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Créer la session',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF6B8143),
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
  ) => TextField(
    controller: ctrl,
    onChanged: (_) => setState(() {}),
    style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E1F)),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: _green, size: 18),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: _green, width: 1.5),
      ),
    ),
  );
}

class _MembreMock {
  final String id;
  final String nom;
  const _MembreMock(this.id, this.nom);
}
