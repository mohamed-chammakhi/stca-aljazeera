import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';

class RefusDecisionDialog extends StatefulWidget {
  final String referenceBouteille;
  const RefusDecisionDialog({super.key, required this.referenceBouteille});

  @override
  State<RefusDecisionDialog> createState() => _RefusDecisionDialogState();
}

class _RefusDecisionDialogState extends State<RefusDecisionDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Refuser la proposition',
        style: GoogleFonts.domine(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: kDark,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Échantillon : ${widget.referenceBouteille}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B8E7A)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: kDark),
            decoration: InputDecoration(
              hintText: 'Raison du refus…',
              hintStyle: const TextStyle(
                color: Color(0xFF9E9E9E),
                fontSize: 12,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAF7),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFB71C1C), width: 1.4),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler',
              style: TextStyle(color: Color(0xFF6B8E7A))),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _ctrl.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text('Confirmer le refus'),
        ),
      ],
    );
  }
}
