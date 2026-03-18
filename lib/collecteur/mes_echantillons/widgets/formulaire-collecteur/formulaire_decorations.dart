// ═════════════════════════════════════════════════════════════════════════════
// FILE : collecteur/mes_echantillons/widgets/dialogs/formulaire/formulaire_decorations.dart
//
// Shared visual primitives used across all formulaire sections:
//   • App color constants
//   • InputDecoration factories
//   • _SectionLabel, _FormDivider, _IconTextField
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
const Color kGreen     = Color(0xFF38835A);
const Color kOlive     = Color(0xFF6B8143);
const Color kDarkText  = Color(0xFF1A2E1F);
const Color kFieldFill = Color(0xFFF7FAF8);

// ── InputDecoration: standard text field with prefix icon ────────────────────
InputDecoration iconFieldDeco({
  required String hint,
  required IconData icon,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      prefixIcon: Icon(icon, color: kGreen, size: 20),
      filled: true,
      fillColor: kFieldFill,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGreen, width: 1.8),
      ),
    );

// ── InputDecoration: compact field used inside the bottle table rows ──────────
InputDecoration bottleFieldDeco({required String hint, String? suffix}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      suffixText: suffix,
      suffixStyle: const TextStyle(
        color: kOlive,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
      filled: true,
      fillColor: kFieldFill,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreen, width: 1.5),
      ),
    );

// ── InputDecoration: cascade dropdown — supports disabled state ───────────────
InputDecoration dropdownDeco(IconData icon, {bool disabled = false}) =>
    InputDecoration(
      prefixIcon: Icon(
        icon,
        color: disabled ? Colors.grey.shade300 : kGreen,
        size: 20,
      ),
      filled: true,
      fillColor: disabled ? Colors.grey.shade50 : kFieldFill,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade100),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGreen, width: 1.8),
      ),
    );

// ── InputDecoration: inline date field ───────────────────────────────────────
InputDecoration dateDeco() => InputDecoration(
      counterText: '',
      hintText: 'JJ/MM/AAAA',
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      filled: true,
      fillColor: kFieldFill,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: kGreen, width: 1.5),
      ),
    );

// ── InputDecoration: multi-line text area (remarques) ────────────────────────
InputDecoration textAreaDeco(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kGreen, width: 1.5),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// TINY SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// Olive-green label above each form field
class SectionLabel extends StatelessWidget {
  final String label;
  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kOlive,
          ),
        ),
      );
}

/// Thin horizontal rule between form sections
class FormDivider extends StatelessWidget {
  const FormDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      Divider(color: Colors.grey.shade100, height: 1);
}

/// Standard text field with a leading icon — used for Fournisseur etc.
class IconTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final String hint;

  const IconTextField({
    super.key,
    required this.controller,
    required this.icon,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: kDarkText),
        decoration: iconFieldDeco(hint: hint, icon: icon),
      );
}
