import 'package:flutter/material.dart';

// Dashboard color palette (home_body only – different from shared deg_colors)
const Color homeGreen = Color(0xFF38835A);
const Color homeDark = Color(0xFF1A2E1F);
const Color homeWhite = Color(0xFFFFFFFF);
const Color homeAmber = Color(0xFFD07B2F);
const Color homeBlue = Color(0xFF3A6EA5);
const Color homeRed = Color(0xFFC0392B);
const Color homeOlive = Color(0xFF6B8143);
const Color homePurple = Color(0xFF7B3FC4);
const Color homeHeaderBg = Color(0xFFDCE9E2);

const List<String> homeMoisAbr = [
  'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
  'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
];

String homeFmtDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

String homeChipLabel({required DateTime? debut, required DateTime? fin}) {
  if (debut == null) return '';
  if (fin == null ||
      (debut.year == fin.year &&
          debut.month == fin.month &&
          debut.day == fin.day)) {
    return homeFmtDate(debut);
  }
  return '${debut.day} ${homeMoisAbr[debut.month - 1]} → ${fin.day} ${homeMoisAbr[fin.month - 1]}';
}

// ── Section header bar ────────────────────────────────────────────────────
Widget homeSectionBar({
  required String title,
  required IconData icon,
  DateTime? dateDebut,
  DateTime? dateFin,
  VoidCallback? onDateTap,
}) {
  final active = dateDebut != null;
  return Container(
    color: homeHeaderBg,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: homeGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Icon(icon, size: 13, color: homeDark),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: homeDark,
            ),
          ),
        ),
        if (onDateTap != null)
          GestureDetector(
            onTap: onDateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: active ? homeGreen : homeGreen.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? homeGreen : homeGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: active ? homeWhite : homeDark,
                  ),
                  if (active) ...[
                    const SizedBox(width: 5),
                    Text(
                      homeChipLabel(debut: dateDebut, fin: dateFin),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: homeWhite,
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

// ── Shared card shell ─────────────────────────────────────────────────────
Widget homeFixedCard({
  required double height,
  required Widget header,
  required Widget body,
  Widget? footer,
}) => Container(
  height: height,
  decoration: BoxDecoration(
    color: homeWhite,
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
      if (footer != null) footer,
    ],
  ),
);
