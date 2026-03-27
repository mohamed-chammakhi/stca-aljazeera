// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/echantillons/widgets/dialogs/refus_dialog.dart
// PURPOSE : CEO refusal dialog — mandatory reason selection + optional comment
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_ceo.dart';

void showRefusDialog(
  BuildContext context, {
  required EchantillonCeo echantillon,
  required VoidCallback onConfirmer,
}) {
  showDialog(
    context: context,
    builder: (ctx) => _RefusDialog(
      echantillon: echantillon,
      onConfirmer: onConfirmer,
    ),
  );
}

class _RefusDialog extends StatefulWidget {
  final EchantillonCeo echantillon;
  final VoidCallback onConfirmer;

  const _RefusDialog({
    required this.echantillon,
    required this.onConfirmer,
  });

  @override
  State<_RefusDialog> createState() => _RefusDialogState();
}

class _RefusDialogState extends State<_RefusDialog> {
  RefusMotif? _motif;
  final _commentaireCtrl = TextEditingController();

  static const Color _darkText = Color(0xFF1A2E1F);

  @override
  void dispose() {
    _commentaireCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF9F6EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.cancel_outlined, color: Colors.red.shade500, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Refuser l\'échantillon',
            style: GoogleFonts.domine(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sample info
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.science_outlined, size: 14, color: Colors.red.shade400),
                const SizedBox(width: 8),
                Text(
                  '${widget.echantillon.ref} — ${widget.echantillon.codeFournisseur}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Motif selection — mandatory
          const Text(
            'Motif de refus *',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B8143),
            ),
          ),
          const SizedBox(height: 8),

          _MotifTile(
            label: 'Refus panel',
            subtitle: 'Rejeté par le panel de dégustation et le CEO',
            selected: _motif == RefusMotif.panelRefus,
            onTap: () => setState(() => _motif = RefusMotif.panelRefus),
          ),
          const SizedBox(height: 6),
          _MotifTile(
            label: 'Accord non atteint',
            subtitle: 'La négociation commerciale n\'a pas abouti',
            selected: _motif == RefusMotif.accordNonAtteint,
            onTap: () => setState(() => _motif = RefusMotif.accordNonAtteint),
          ),

          const SizedBox(height: 14),

          const Text(
            'Commentaire (optionnel)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B8143),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _commentaireCtrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: _darkText),
            decoration: InputDecoration(
              hintText: 'Précisions supplémentaires...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
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
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler', style: TextStyle(color: Colors.grey.shade600)),
        ),
        ElevatedButton.icon(
          onPressed: _motif == null
              ? null
              : () {
                  Navigator.pop(context);
                  widget.onConfirmer();
                },
          icon: const Icon(Icons.close, size: 16),
          label: const Text(
            'Confirmer le refus',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade500,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _MotifTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _MotifTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? Colors.red.shade300 : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? Colors.red.shade500 : Colors.grey.shade400,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.red.shade700 : const Color(0xFF1A2E1F),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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
