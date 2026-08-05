import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import 'package:project3/core/utils/montant_achat.dart';

/// Confirmation step before a purchase is validated.
///
/// Validating a purchase cannot be undone, so it gets the same protection the
/// refusal already had. The dialog restates the figures being committed —
/// a dialog that only asks "are you sure?" teaches the reader to click through it.
///
/// Pops `true` when the CEO confirms, `null` otherwise.
class ConfirmerAchatDialog extends StatelessWidget {
  final String referenceBouteille;
  final String? budgetNegociation;
  final String? quantite;

  const ConfirmerAchatDialog({
    super.key,
    required this.referenceBouteille,
    this.budgetNegociation,
    this.quantite,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      title: Column(
        children: [
          Text(
            "Confirmer l'achat",
            textAlign: TextAlign.center,
            style: GoogleFonts.domine(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            referenceBouteille,
            textAlign: TextAlign.center,
            style: GoogleFonts.alegreya(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kOlive,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // One figure per line, labels left and values right, so the eye runs
          // straight down the values instead of hunting across a grid.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: kChipBgGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _LigneRecap(label: 'Prix négocié', value: budgetNegociation),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 14,
                  endIndent: 14,
                  color: kGreen.withValues(alpha: 0.15),
                ),
                _LigneRecap(label: 'Quantité', value: quantite),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 14,
                  endIndent: 14,
                  color: kGreen.withValues(alpha: 0.15),
                ),
                // The figure actually being committed. Same helper as the
                // proposal details, so the two can never disagree.
                _LigneRecap(
                  label: 'Montant total',
                  value: MontantAchat.formater(budgetNegociation, quantite),
                  fort: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Cette décision est définitive.',
            textAlign: TextAlign.center,
            style: GoogleFonts.alegreya(
              fontSize: 12,
              color: const Color(0xFF6B8E7A),
            ),
          ),
        ],
      ),
      actions: [
        // Equal widths: neither choice is nudged by being the wider target.
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6B8E7A),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
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
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Confirmer'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// One figure of the purchase recap. A missing value shows "—" rather than
/// disappearing: the CEO should see that a figure was never filled in before
/// committing, not be shown a tidier dialog.
class _LigneRecap extends StatelessWidget {
  final String label;
  final String? value;

  /// The line that carries the decision — larger, so the eye lands on it.
  final bool fort;

  const _LigneRecap({
    required this.label,
    required this.value,
    this.fort = false,
  });

  @override
  Widget build(BuildContext context) {
    final rempli = value != null && value!.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.alegreya(
              fontSize: 13,
              color: const Color(0xFF6B8E7A),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              rempli ? value!.trim() : '—',
              textAlign: TextAlign.end,
              style: GoogleFonts.alegreya(
                fontSize: fort ? 16 : 14,
                fontWeight: rempli ? FontWeight.w700 : FontWeight.w400,
                color: rempli
                    ? (fort ? kGreen : kDark)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
