// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/dialog_doublon_fournisseur.dart
// PURPOSE : Asked just before a new supplier is created, when a very similar one
//           already exists.
//
//           The collector is free to create suppliers — he is on the road and
//           cannot wait for approval. This is the guard rail that keeps that
//           freedom from filling the reference list with the same company under
//           three spellings, which is what makes the CEO dashboard lie.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/fournisseur.dart';
import '../theme/app_colors.dart';

/// Pops the chosen existing supplier, or null to create a new one.
///
/// Returning null on cancel is deliberate: "no, create a new one" and closing
/// the dialog lead to the same place, so the collector is never trapped.
class DialogDoublonFournisseur extends StatelessWidget {
  final String nomSaisi;
  final List<Fournisseur> proches;

  const DialogDoublonFournisseur({
    super.key,
    required this.nomSaisi,
    required this.proches,
  });

  static Future<Fournisseur?> afficher(
    BuildContext context, {
    required String nomSaisi,
    required List<Fournisseur> proches,
  }) {
    return showDialog<Fournisseur>(
      context: context,
      builder: (_) =>
          DialogDoublonFournisseur(nomSaisi: nomSaisi, proches: proches),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pluriel = proches.length > 1;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        pluriel
            ? 'Des fournisseurs proches existent déjà'
            : 'Un fournisseur proche existe déjà',
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
            'Vous avez saisi « $nomSaisi ».',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B8E7A)),
          ),
          const SizedBox(height: 12),
          for (final f in proches) ...[
            _CarteFournisseur(
              fournisseur: f,
              onTap: () => Navigator.pop(context, f),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            pluriel
                ? "Touchez celui qu'il vous faut, ou créez-en un nouveau."
                : "Touchez-le si c'est le bon, ou créez-en un nouveau.",
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B8E7A)),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Créer « $nomSaisi »',
            style: const TextStyle(color: Color(0xFF6B8E7A)),
          ),
        ),
      ],
    );
  }
}

class _CarteFournisseur extends StatelessWidget {
  final Fournisseur fournisseur;
  final VoidCallback onTap;

  const _CarteFournisseur({required this.fournisseur, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final region = fournisseur.region;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kChipBgGreen,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: kGreen.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fournisseur.nom,
                    style: GoogleFonts.alegreya(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kDark,
                    ),
                  ),
                  // The region is what tells two similar names apart — it is the
                  // deciding detail, not decoration.
                  if (region != null && region.isNotEmpty)
                    Text(
                      region,
                      style: GoogleFonts.alegreya(
                        fontSize: 12,
                        color: const Color(0xFF6B8E7A),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.check_circle_outline, size: 18, color: kGreen),
          ],
        ),
      ),
    );
  }
}
