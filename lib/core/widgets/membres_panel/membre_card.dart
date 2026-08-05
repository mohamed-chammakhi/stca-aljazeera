// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/widgets/membre_card.dart
// PURPOSE : displays ONE panel member — clean, minimal card
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/models/membre_panel.dart';

const Color _green = Color(0xFF38835A);
const Color _darkText = Color(0xFF1A2E1F);

class MembreCard extends StatelessWidget {
  final MembrePanel membre;

  const MembreCard({super.key, required this.membre});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // AVATAR — initials circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: _green.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  membre.initiales,
                  style: GoogleFonts.domine(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _green,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            // INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    membre.nomComplet,
                    style: GoogleFonts.domine(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Membre depuis ${membre.membreDepuis}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
