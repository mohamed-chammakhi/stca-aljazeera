// ═════════════════════════════════════════════════════════════════════════════
// FILE : 1_ceo/notifications/widgets/notification_header.dart
// ═════════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project3/core/theme/app_colors.dart';
import '../models/notification_ceo.dart';

// ── Group header ──────────────────────────────────────────────────────────────
class NotifGroupHeader extends StatelessWidget {
  final String label;
  const NotifGroupHeader(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6, top: 2),
    child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: Colors.grey.shade500, letterSpacing: 0.5,
        )),
  );
}

// ── Filter chip ───────────────────────────────────────────────────────────────
class NotifFilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const NotifFilterChip({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? kGreen : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? [BoxShadow(color: kGreen.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : Colors.grey.shade600,
            )),
      ),
    );
  }
}
