// ═════════════════════════════════════════════════════════════════════════════
// FILE    : core/theme/app_colors.dart
// PURPOSE : Single source of truth for all brand colors.
//           Import this file instead of redeclaring colors in every widget.
//
// Usage:
//   import 'package:project3/core/theme/app_colors.dart';
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

/// Primary brand green — buttons, accents, active states.
const Color kGreen = Color(0xFF38835A);

/// AppBar / header zone background — light green wash.
const Color kHeaderBg = Color.fromARGB(255, 220, 233, 226);

/// Page scaffold background — pure white.
const Color kBg = Color.fromARGB(255, 255, 255, 255);

/// Primary dark text color.
const Color kDark = Color(0xFF1A2E1F);

/// Olive green — secondary labels, quantity pills, field labels.
const Color kOlive = Color(0xFF6B8143);

/// Cream — expandable panel backgrounds, detail sheets.
const Color kCream = Color(0xFFF9F6EF);

// ── Per-status accent colors (shared chip/badge palette) ─────────────────────

/// "Tous" chip / neutral.
const Color kStatusGrey = Color(0xFF616161);

/// "En attente" / "Réceptionné" — blue.
const Color kStatusBlue = Color(0xFF3A6EA5);

/// "En cours" / "En négociation" — orange.
const Color kStatusOrange = Color(0xFFD07B2F);

/// "Soumis" / "Achat confirmé" — green (same as kGreen).
const Color kStatusGreen = Color(0xFF38835A);

// ── Inactive chip background pastels ─────────────────────────────────────────
const Color kChipBgGrey   = Color(0xFFF0F0F0);
const Color kChipBgBlue   = Color(0xFFE8F1FB);
const Color kChipBgOrange = Color(0xFFFEF3E8);
const Color kChipBgGreen  = Color(0xFFE6F4ED);

// ── Card background tints ─────────────────────────────────────────────────────
const Color kCardBgBlue   = Color(0xFFE8F1FB);
const Color kCardBgOrange = Color(0xFFFEF3E8);
const Color kCardBgGreen  = Color(0xFFE6F4ED);

// ── Additional accent colors ──────────────────────────────────────────────────
const Color kRed    = Color(0xFFC0392B);
const Color kPurple = Color(0xFF7B3FC4);
