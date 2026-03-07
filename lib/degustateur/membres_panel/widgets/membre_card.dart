// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/widgets/membre_card.dart
// PURPOSE : displays ONE member as a card
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/membre_panel.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

class MembreCard extends StatelessWidget {
  final MembrePanel membre;

  const MembreCard({super.key, required this.membre});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:      _green.withOpacity(0.07),
            blurRadius: 10,
            offset:     const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [

            // ── AVATAR ──────────────────────────────────────────────────────
            Stack(
              children: [
                Container(
                  width:  50,
                  height: 50,
                  decoration: BoxDecoration(
                    color:        _green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(25),
                    border:       Border.all(
                      color: _green.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      membre.initiales,
                      style: GoogleFonts.domine(
                        fontSize:   16,
                        fontWeight: FontWeight.w700,
                        color:      _green,
                      ),
                    ),
                  ),
                ),

                // online indicator
                Positioned(
                  bottom: 1,
                  right:  1,
                  child: Container(
                    width:  12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:        membre.estEnLigne
                          ? Colors.green.shade400
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // ── INFO ─────────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Name
                  Text(
                    membre.nomComplet,
                    style: GoogleFonts.domine(
                      fontSize:   15,
                      fontWeight: FontWeight.w700,
                      color:      _darkText,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical:   3,
                    ),
                    decoration: BoxDecoration(
                      color:        _oliveGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      membre.role,
                      style: TextStyle(
                        fontSize:   11,
                        color:      _oliveGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Membre depuis
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size:  12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Membre depuis ${membre.membreDepuis}',
                        style: TextStyle(
                          fontSize: 11,
                          color:    Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── STATUS TEXT ──────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  membre.estEnLigne ? 'En ligne' : 'Hors ligne',
                  style: TextStyle(
                    fontSize:   11,
                    color:      membre.estEnLigne
                        ? Colors.green.shade400
                        : Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}