import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';

const Color _dark = Color(0xFF1A2E1F);
const Color _red = Color(0xFFC0392B);
const Color _amber = Color(0xFFD07B2F);
const Color _white = Color(0xFFFFFFFF);

/// Red-bordered panel listing samples that need an urgent CEO decision.
/// Tapping any row navigates to AnalyseOrganoleptiqueCeoPage via [onTap].
class UrgentPanel extends StatelessWidget {
  final List<UrgentDecision> items;
  final VoidCallback onTap;

  const UrgentPanel({super.key, required this.items, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.15)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          _header(),
          ...List.generate(items.length, (i) => _row(items[i], i)),
          _hint(),
        ],
      ),
    );
  }

  Widget _header() => Container(
    color: const Color(0xFFFDF4F3),
    padding: const EdgeInsets.fromLTRB(14, 11, 14, 11),
    child: Row(
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: _red, shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: _red.withValues(alpha: 0.3), blurRadius: 6, spreadRadius: 2)],
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Décisions en attente',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _red),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: _red, borderRadius: BorderRadius.circular(6)),
          child: Text(
            '${items.length}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ],
    ),
  );

  Widget _row(UrgentDecision u, int i) {
    final isLate = u.joursEnAttente >= 3;
    final badgeColor = isLate ? _red : _amber;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade50),
            bottom: i < items.length - 1 ? BorderSide(color: Colors.grey.shade50) : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(u.ref, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark)),
                  const SizedBox(height: 3),
                  Text(
                    '${u.collecteur}  ·  ${u.fournisseur}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: badgeColor.withValues(alpha: 0.18)),
              ),
              child: Text(
                isLate ? '${u.joursEnAttente}j — urgent' : '${u.joursEnAttente}j en attente',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, size: 15, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _hint() => Container(
    color: const Color(0xFFF8F8F8),
    padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
    child: SizedBox(
      width: double.infinity,
      child: Text(
        'Appuyez pour voir l\'évaluation organoleptique',
        textAlign: TextAlign.center,
        softWrap: true,
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontStyle: FontStyle.italic),
      ),
    ),
  );
}
