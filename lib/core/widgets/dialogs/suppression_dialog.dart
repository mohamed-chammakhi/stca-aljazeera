import 'package:flutter/material.dart';
import 'package:project3/core/models/echantillon.dart';

const Color _green = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);

void showSuppressionDialog(
  BuildContext context, {
  required Echantillon echantillon,
  required VoidCallback onConfirmer,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
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
      content: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: _darkText),
          children: [
            const TextSpan(text: 'Êtes-vous sûr de supprimer l\'échantillon '),
            TextSpan(
              text: echantillon.id,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: _green,
              ),
            ),
            const TextSpan(text: ' de '),
            TextSpan(
              text: echantillon.fournisseurTexte,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' ?\n\nCette action est irréversible.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onConfirmer();
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
