import 'package:flutter/material.dart';

/// Shared filter chip used across all chef-dégustateur pages (gestion,
/// évaluation, analyse labo, sessions). The [hasActivity] flag, used only
/// by the sessions page, keeps the tinted state even when unselected.
class StatutChip extends StatelessWidget {
  final String label;
  final Color activeColor;
  final Color inactiveColor;
  final Color inactiveTextColor;
  final bool selected;
  final bool hasActivity;
  final VoidCallback onTap;

  const StatutChip({
    super.key,
    required this.label,
    required this.activeColor,
    required this.inactiveColor,
    required this.inactiveTextColor,
    required this.selected,
    required this.onTap,
    this.hasActivity = false,
  });

  static const Color _inactiveBg = Color(0xFFF0F0F0);
  static const Color _inactiveFg = Color(0xFF9E9E9E);
  static const Color _inactiveBorder = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    final bool isTous = label == 'Tous';
    final Color bg;
    final Color fg;
    final Color border;

    if (!selected) {
      if (hasActivity) {
        bg = inactiveColor;
        fg = inactiveTextColor;
        border = inactiveTextColor.withValues(alpha: 0.35);
      } else {
        bg = _inactiveBg;
        fg = _inactiveFg;
        border = _inactiveBorder;
      }
    } else if (isTous) {
      bg = const Color(0xFF757575);
      fg = Colors.white;
      border = const Color(0xFF757575);
    } else {
      bg = inactiveColor;
      fg = inactiveTextColor;
      border = inactiveTextColor.withValues(alpha: 0.45);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.2),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: (isTous ? const Color(0xFF757575) : inactiveTextColor)
                        .withValues(alpha: 0.22),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}
