// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/widgets/historique_modifications.dart
// PURPOSE : Shows the edit trail of one sample — every change since it was
//           physically received, with the value before and after.
//
//           Shared by all roles: the rule is that everyone sees the old and the
//           new value, so there is one widget, not one per module.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/modification_champ.dart';
import '../theme/app_colors.dart';

/// Collapsed by default, with the number of changes visible.
///
/// A details page is for the sample as it stands now; the trail answers a
/// different question ("how did it get here") and should not crowd the page
/// until someone asks for it.
class HistoriqueModifications extends StatefulWidget {
  /// Oldest first, as stored. The widget displays the most recent change first —
  /// the usual question is "what changed?", not "how did this start?".
  final List<ModificationChamp> historique;

  const HistoriqueModifications({super.key, required this.historique});

  @override
  State<HistoriqueModifications> createState() =>
      _HistoriqueModificationsState();
}

class _HistoriqueModificationsState extends State<HistoriqueModifications> {
  bool _ouvert = false;

  @override
  Widget build(BuildContext context) {
    // A sample that was never edited says so plainly. An empty box would read
    // as a loading failure.
    if (widget.historique.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Aucune modification depuis la réception.',
          style: GoogleFonts.alegreya(
            fontSize: 13,
            color: const Color(0xFF6B8E7A),
          ),
        ),
      );
    }

    final recentDAbord = widget.historique.reversed.toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: kCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _ouvert = !_ouvert),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.history, size: 16, color: kOlive),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _titre(widget.historique.length),
                      style: GoogleFonts.domine(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kDark,
                      ),
                    ),
                  ),
                  Icon(
                    _ouvert ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: kOlive,
                  ),
                ],
              ),
            ),
          ),
          if (_ouvert)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Column(
                children: [
                  for (var i = 0; i < recentDAbord.length; i++) ...[
                    if (i > 0)
                      Divider(
                        height: 16,
                        thickness: 1,
                        color: Colors.black.withValues(alpha: 0.06),
                      ),
                    _LigneModification(modification: recentDAbord[i]),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _titre(int n) =>
      n == 1 ? '1 modification' : '$n modifications';
}

class _LigneModification extends StatelessWidget {
  final ModificationChamp modification;

  const _LigneModification({required this.modification});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          modification.libelleChamp,
          style: GoogleFonts.alegreya(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kOlive,
          ),
        ),
        const SizedBox(height: 4),
        // Old value muted, arrow, new value in full contrast. The arrow carries
        // the direction — no strikethrough, which would read as "deleted"
        // rather than "replaced".
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Text(
              modification.ancienneValeurAffichee,
              style: GoogleFonts.alegreya(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
              ),
            ),
            const Icon(Icons.arrow_forward, size: 13, color: Color(0xFF9E9E9E)),
            Text(
              modification.nouvelleValeurAffichee,
              style: GoogleFonts.alegreya(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          _signature(),
          style: GoogleFonts.alegreya(
            fontSize: 11,
            color: const Color(0xFF6B8E7A),
          ),
        ),
      ],
    );
  }

  /// `15/03/2026 · Sonia (Chef dégustateur)` — the author is dropped from the
  /// line rather than shown as "inconnu" when the backend did not supply it.
  String _signature() {
    final buffer = StringBuffer(modification.dateAffichee);
    final nom = modification.auteurNom;
    if (nom != null && nom.trim().isNotEmpty) {
      buffer.write(' · ${nom.trim()}');
      final role = modification.auteurRole;
      if (role != null && role.trim().isNotEmpty) {
        buffer.write(' (${role.trim()})');
      }
    }
    return buffer.toString();
  }
}
