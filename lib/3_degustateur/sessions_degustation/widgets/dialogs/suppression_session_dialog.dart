// ═════════════════════════════════════════════════════════════════════════════
// FILE    : sessions_degustation/widgets/dialogs/suppression_session_dialog.dart
// PURPOSE : confirmation dialog before deleting a session
// USAGE   : showSuppressionSessionDialog(context, session: s, onConfirmer: ...)
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/session_degustation.dart';

const Color _green = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);

Future<void> showSuppressionSessionDialog(
  BuildContext context, {
  required SessionDegustation session,
  required VoidCallback onConfirmer,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red.shade400,
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'Supprimer la session',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Text(
        'Voulez-vous vraiment supprimer "${session.titre}" ?\n'
        'Cette action est irréversible.',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      ),
      actions: [
        // Annuler
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Annuler',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Confirmer
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirmer();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade400,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            'Supprimer',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
