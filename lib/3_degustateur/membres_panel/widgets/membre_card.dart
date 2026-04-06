// ─────────────────────────────────────────────────────────────────────────────
// FILE : membres_panel/widgets/membre_card.dart
// PURPOSE : displays ONE member as an elegant card with left accent bar
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
    final barColor = membre.estEnLigne
        ? _green
        : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color:      barColor.withValues(alpha: 0.13),
            blurRadius: 10,
            offset:     const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Left accent bar
            Container(width: 4, color: barColor),

            // Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      barColor.withValues(alpha: 0.05),
                      Colors.white,
                    ],
                    begin: Alignment.centerLeft,
                    end:   Alignment.centerRight,
                  ),
                ),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [

                    // AVATAR
                    Stack(
                      children: [
                        Container(
                          width:  50,
                          height: 50,
                          decoration: BoxDecoration(
                            color:        _green.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: _green.withValues(alpha: 0.3),
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
                        // Online indicator
                        Positioned(
                          bottom: 1,
                          right:  1,
                          child: Container(
                            width:  12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: membre.estEnLigne
                                  ? Colors.green.shade400
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
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
                              fontSize:   15,
                              fontWeight: FontWeight.w700,
                              color:      _darkText,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Role badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color:        _oliveGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: _oliveGreen.withValues(alpha: 0.2)),
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
                              Icon(Icons.calendar_today_outlined,
                                  size:  12,
                                  color: Colors.grey.shade400),
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

                    // STATUS PILL
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: membre.estEnLigne
                            ? Colors.green.shade50
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: membre.estEnLigne
                              ? Colors.green.shade200
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        membre.estEnLigne ? 'En ligne' : 'Hors ligne',
                        style: TextStyle(
                          fontSize:   11,
                          color:      membre.estEnLigne
                              ? Colors.green.shade600
                              : Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
