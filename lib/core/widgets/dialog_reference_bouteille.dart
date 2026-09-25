import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum ChoixReferenceBouteille { garderAncienne, utiliserNouvelle }

Future<ChoixReferenceBouteille> demanderChoixReferenceBouteilleRecalculee(
  BuildContext context, {
  required String ancienneReference,
  required String nouvelleReference,
  required Color couleurPrincipale,
}) async {
  final choix = await showDialog<ChoixReferenceBouteille>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DialogReferenceBouteille(
      ancienneReference: ancienneReference,
      nouvelleReference: nouvelleReference,
      couleurPrincipale: couleurPrincipale,
    ),
  );
  return choix ?? ChoixReferenceBouteille.garderAncienne;
}

class _DialogReferenceBouteille extends StatelessWidget {
  final String ancienneReference;
  final String nouvelleReference;
  final Color couleurPrincipale;

  const _DialogReferenceBouteille({
    required this.ancienneReference,
    required this.nouvelleReference,
    required this.couleurPrincipale,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'La référence a changé',
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
          const Text(
            'En modifiant la quantité, la citerne ou le fournisseur, '
            'la référence a été recalculée.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B8E7A)),
          ),
          const SizedBox(height: 12),
          Text(
            'Ancienne : $ancienneReference',
            style: const TextStyle(fontSize: 13, color: kDark),
          ),
          const SizedBox(height: 6),
          Text(
            'Nouvelle : $nouvelleReference',
            style: const TextStyle(fontSize: 13, color: kDark),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            ChoixReferenceBouteille.garderAncienne,
          ),
          child: const Text(
            "Garder l'ancienne",
            style: TextStyle(color: Color(0xFF6B8E7A)),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(
            context,
            ChoixReferenceBouteille.utiliserNouvelle,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: couleurPrincipale,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          child: const Text('Utiliser la nouvelle'),
        ),
      ],
    );
  }
}
