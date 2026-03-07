// ─────────────────────────────────────────────────────────────────────────────
// FILE : homepage/widgets/home_body.dart
// PURPOSE : the center content of the homepage
// receives : onSimulerNotification callback FROM the page
// the actual setState is called in homepage_page.dart via the callback
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _green      = Color(0xFF38835A);
const Color _oliveGreen = Color(0xFF6B8143);
const Color _darkText   = Color(0xFF1A2E1F);

class HomeBody extends StatelessWidget {
  final VoidCallback onSimulerNotification;

  const HomeBody({super.key, required this.onSimulerNotification});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: _green.withOpacity(0.3)),
          const SizedBox(height: 20),
          Text(
            "Bienvenue à l'accueil",
            style: GoogleFonts.domine(
              fontSize:   28,
              fontWeight: FontWeight.w700,
              color:      _darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Appuyez sur l'icône de menu pour naviguer",
            style: GoogleFonts.alegreya(fontSize: 16, color: _oliveGreen),
          ),
          const SizedBox(height: 40),

          // Test button — simulates a new notification arriving
          ElevatedButton.icon(
            onPressed: onSimulerNotification, // setState called in the PAGE
            icon:  const Icon(Icons.add_alert_outlined, size: 18),
            label: const Text('Simuler une notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
