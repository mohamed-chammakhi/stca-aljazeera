// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire_decorations.dart
// PURPOSE : Shared constants, decorations, and micro-widgets used by the
//           collecteur form dialog and its section widgets.
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Brand constants ────────────────────────────────────────────────────────────
const Color kGreen    = Color(0xFF38835A);
const Color kDarkText = Color(0xFF1A2E1F);
const Color kOlive    = Color(0xFF6B8143);
const Color kFieldFill = Color(0xFFF7FAF8);
final Color kFieldHint = Colors.grey.shade600;
final Color kInlineLabel = Colors.grey.shade800;

// ── Section label widget ───────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      label,
      style: GoogleFonts.domine(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: kDarkText,
      ),
    ),
  );
}

// ── Dropdown decoration ────────────────────────────────────────────────────────
InputDecoration dropdownDeco(IconData icon, {bool disabled = false}) =>
    InputDecoration(
      prefixIcon: Icon(
        icon,
        color: disabled ? Colors.grey.shade300 : kGreen,
        size: 18,
      ),
      filled: true,
      fillColor: disabled ? Colors.grey.shade50 : kFieldFill,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: kGreen, width: 1.8),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
    );

// ── Multi-line text-area decoration ───────────────────────────────────────────
InputDecoration textAreaDeco(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: TextStyle(color: kFieldHint, fontSize: 13),
  filled: true,
  fillColor: kFieldFill,
  contentPadding: const EdgeInsets.all(12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: kGreen, width: 1.8),
  ),
);

// ── Date text-field decoration ─────────────────────────────────────────────────
InputDecoration dateDeco() => InputDecoration(
  hintText: 'JJ/MM/AAAA',
  hintStyle: TextStyle(color: kFieldHint, fontSize: 13),
  prefixIcon: const Icon(
    Icons.calendar_today_outlined,
    color: kGreen,
    size: 16,
  ),
  counterText: '',
  filled: true,
  fillColor: kFieldFill,
  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: Colors.grey.shade200),
  ),
  focusedBorder: const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    borderSide: BorderSide(color: kGreen, width: 1.8),
  ),
);
