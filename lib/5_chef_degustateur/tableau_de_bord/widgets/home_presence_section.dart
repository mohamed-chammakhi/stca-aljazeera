import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';

class PresenceSection extends StatelessWidget {
  final PresenceChefData? presence;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onDateTap;

  const PresenceSection({
    super.key,
    required this.presence,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = presence;
    return fixedCard(
      height: 260,
      header: sectionBar(
        title: 'Présence aux séances',
        icon: Icons.people_outline_rounded,
        dateDebut: dateDebut,
        dateFin: dateFin,
        onDateTap: onDateTap,
        chipLabel: ({required debut, required fin}) {
          if (debut == null) return '';
          final mois = [
            'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun',
            'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
          ];
          if (fin == null ||
              (debut.year == fin.year &&
                  debut.month == fin.month &&
                  debut.day == fin.day)) {
            return '${debut.day.toString().padLeft(2, '0')}/${debut.month.toString().padLeft(2, '0')}/${debut.year}';
          }
          return '${debut.day} ${mois[debut.month - 1]} → ${fin.day} ${mois[fin.month - 1]}';
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(100, 100),
                      painter: DonutPainter(value: p?.taux ?? 0),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${((p?.taux ?? 0) * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: chefGreenLocal,
                          ),
                        ),
                        const Text(
                          'présence',
                          style: TextStyle(
                            fontSize: 9,
                            color: Color(0xFFAAAAAA),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    _attStat(
                      chefGreenLocal,
                      'Séances présent',
                      '${p?.present ?? 0}',
                      chefGreenLocal,
                    ),
                    const SizedBox(height: 7),
                    _attStat(
                      chefRed,
                      'Séances manquées',
                      '${p?.manquee ?? 0}',
                      chefRed,
                    ),
                    const SizedBox(height: 7),
                    _attStat(
                      const Color(0xFFE5E7E5),
                      'Total',
                      '${p?.total ?? 0}',
                      chefDarkLocal,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (p?.prochaineDate != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: chefGreenLocal.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_outlined,
                    size: 14,
                    color: chefGreenLocal,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prochaine séance : ${p!.prochaineDate}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: chefDarkLocal,
                          ),
                        ),
                        if (p.prochaineLieu != null)
                          Text(
                            p.prochaineLieu!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (p.prochaineCountdown != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: chefGreenLocal.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        p.prochaineCountdown!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: chefGreenLocal,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _attStat(Color dot, String label, String value, Color valueColor) =>
      Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      );
}

// ── Fat donut ring painter ────────────────────────────────────────────────────
class DonutPainter extends CustomPainter {
  final double value;
  const DonutPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 12.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -1.5707963,
      6.2831853,
      false,
      Paint()
        ..color = const Color(0xFFF1F4F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    if (value > 0) {
      canvas.drawArc(
        rect,
        -1.5707963,
        6.2831853 * value,
        false,
        Paint()
          ..color = const Color(0xFF38835A)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(DonutPainter old) => old.value != value;
}
