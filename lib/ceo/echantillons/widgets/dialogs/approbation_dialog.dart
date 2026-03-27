// ─────────────────────────────────────────────────────────────────────────────
// FILE : ceo/echantillons/widgets/dialogs/approbation_dialog.dart
// PURPOSE : CEO approval dialog — optional comment + budget before approving
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/echantillon_ceo.dart';

void showApprobationDialog(
  BuildContext context, {
  required EchantillonCeo echantillon,
  required VoidCallback onConfirmer,
}) {
  final commentaireCtrl = TextEditingController();
  final budgetCtrl = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => _ApprobationDialog(
      echantillon: echantillon,
      commentaireCtrl: commentaireCtrl,
      budgetCtrl: budgetCtrl,
      onConfirmer: onConfirmer,
    ),
  );
}

class _ApprobationDialog extends StatelessWidget {
  final EchantillonCeo echantillon;
  final TextEditingController commentaireCtrl;
  final TextEditingController budgetCtrl;
  final VoidCallback onConfirmer;

  const _ApprobationDialog({
    required this.echantillon,
    required this.commentaireCtrl,
    required this.budgetCtrl,
    required this.onConfirmer,
  });

  static const Color _green = Color(0xFF38835A);
  static const Color _darkText = Color(0xFF1A2E1F);

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
              color: _green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline, color: _green, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Approuver l\'échantillon',
            style: GoogleFonts.domine(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _darkText,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sample ref info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.science_outlined, size: 14, color: _green),
                  const SizedBox(width: 8),
                  Text(
                    '${echantillon.ref} — ${echantillon.codeFournisseur}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Budget
            const Text(
              'Budget de négociation (optionnel)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B8143),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: budgetCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 14, color: _darkText),
              decoration: InputDecoration(
                hintText: 'Ex: 8.50 TND/L',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: const Icon(
                  Icons.monetization_on_outlined,
                  color: _green,
                  size: 18,
                ),
                filled: true,
                fillColor: Colors.white,
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
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Comment
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
              controller: commentaireCtrl,
              maxLines: 3,
              style: const TextStyle(fontSize: 14, color: _darkText),
              decoration: InputDecoration(
                hintText: 'Observations, conditions particulières...',
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
                  borderSide: const BorderSide(color: _green, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Annuler',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirmer();
          },
          icon: const Icon(Icons.check, size: 16),
          label: const Text(
            'Approuver',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            foregroundColor: Colors.white,
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
