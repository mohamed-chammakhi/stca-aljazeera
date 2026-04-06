// ─────────────────────────────────────────────────────────────────────────────
// FILE : gestion_echantillons/dialogs/suppression_dialog.dart
// PURPOSE : delete confirmation popup
// receives : context, echantillon to delete, onConfirmer callback
// setState is triggered in the PAGE via onConfirmer, not here
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../models/echantillon_gestion.dart';

const Color _green = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);

void showSuppressionDialog(
  BuildContext context, {
  required EchantillonGestion echantillon,
  required VoidCallback onConfirmer, // page calls setState inside this
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      // ── TITLE ──
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'Supprimer ?',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ],
      ),

      // ── CONTENT ──
      // RichText = multiple styles in the same text block
      content: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: _darkText),
          children: [
            const TextSpan(text: 'Êtes-vous sûr de supprimer l\'échantillon '),
            TextSpan(
              text: echantillon.id, // green bold ID
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _green,
              ),
            ),
            const TextSpan(text: ' de '),
            TextSpan(
              text: echantillon.codeFournisseur, // bold supplier name
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' ?\n\nCette action est irréversible.'),
          ],
        ),
      ),

      // ── ACTIONS ──
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // close without deleting
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context); // close dialog first
            onConfirmer(); // then trigger delete in the page
          },
          icon: const Icon(Icons.delete_outline, size: 16),
          label: const Text('Supprimer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    ),
  );
}
