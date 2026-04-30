import 'package:flutter/material.dart';

import '../../widgets/chef_colors.dart';

// ── Section header bar ────────────────────────────────────────────────────────
Widget sectionBar({
  required String title,
  required IconData icon,
  required String Function({required DateTime? debut, required DateTime? fin})
  chipLabel,
  DateTime? dateDebut,
  DateTime? dateFin,
  VoidCallback? onDateTap,
}) {
  final active = dateDebut != null;
  return Container(
    color: chefHeaderBg,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: chefGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Icon(icon, size: 13, color: chefDark),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: chefDark,
            ),
          ),
        ),
        if (onDateTap != null)
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? chefGreen
                    : chefGreen.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active
                      ? chefGreen
                      : chefGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: active ? chefWhite : chefDark,
                  ),
                  if (active) ...[
                    const SizedBox(width: 5),
                    Text(
                      chipLabel(debut: dateDebut, fin: dateFin),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: chefWhite,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    ),
  );
}

// ── Fixed-height card shell ───────────────────────────────────────────────────
Widget fixedCard({
  required double height,
  required Widget header,
  required Widget body,
  Widget? footer,
}) => Container(
  height: height,
  decoration: BoxDecoration(
    color: chefWhite,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  clipBehavior: Clip.hardEdge,
  child: Column(
    children: [
      header,
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          child: body,
        ),
      ),
      ?footer,
    ],
  ),
);

// ── Scrollable rows widget (délai / alignement) ───────────────────────────────
Widget buildScrollableRows<T>({
  required List<T> items,
  required double Function(T) getValue,
  required double Function(T) getMax,
  required Color Function(T) getColor,
  required String Function(T) getLabel,
  required String Function(T) getName,
}) {
  final maxVal = getMax(items.first);
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (_, i) {
      final item = items[i];
      final val = getValue(item);
      final color = getColor(item);
      final ratio = maxVal == 0 ? 0.0 : (val / maxVal).clamp(0.0, 1.0);
      final isRed = color == chefRed;
      final isOrange = color == chefAmber;
      return Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        decoration: BoxDecoration(
          color: isRed
              ? const Color(0xFFFFF8F6)
              : isOrange
              ? const Color(0xFFFFFAF5)
              : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isRed
                ? const Color(0xFFFFD5CC)
                : isOrange
                ? const Color(0xFFFFE8CC)
                : const Color(0xFFEEEEEE),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              child: Text(
                getName(item),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(
                getLabel(item),
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ── Subsection header (urgentes) ──────────────────────────────────────────────
Widget subsectionHeader(String label, Color color, int count) => Padding(
  padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
  child: Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '$count',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    ],
  ),
);

// ── Subsection divider (urgentes) ─────────────────────────────────────────────
Widget subsectionDivider() => Container(
  height: 1,
  color: const Color(0xFFF0F0F0),
  margin: const EdgeInsets.symmetric(horizontal: 14),
);

// ── Legend dot (classifications) ──────────────────────────────────────────────
Widget legendDot(Color color, String label) => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    ),
    const SizedBox(width: 4),
    Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: chefDark,
      ),
    ),
  ],
);
