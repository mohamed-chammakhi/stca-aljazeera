import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_degustateur.dart';
import 'home_shared.dart';

class HomeDelaiSection extends StatelessWidget {
  const HomeDelaiSection({
    super.key,
    required this.delai,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
  });
  final DelaiSummary? delai;
  final DateTime dateDebut;
  final DateTime dateFin;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    final d = delai;
    final diff = d != null ? d.monDelaiMoyen - d.panelMoyen : 0.0;
    final isBetter = diff <= 0;
    return homeFixedCard(
      height: 290,
      header: homeSectionBar(
        title: 'Délai de soumission',
        icon: Icons.timer_outlined,
        dateDebut: dateDebut,
        dateFin: dateFin,
        onDateTap: onDateTap,
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _summaryItem(
                  label: 'MON DÉLAI MOY.',
                  value: d != null
                      ? '${d.monDelaiMoyen.toStringAsFixed(1)}j'
                      : '—',
                  valueColor: homeAmber,
                  sub: diff == 0.0
                      ? null
                      : (isBetter
                            ? '↑ −${diff.abs().toStringAsFixed(1)}j vs panel'
                            : '↓ +${diff.toStringAsFixed(1)}j vs panel'),
                  subColor: isBetter ? homeGreen : homeRed,
                ),
                Container(
                  width: 2,
                  height: 42,
                  color: Colors.black.withValues(alpha: 0.07),
                ),
                _summaryItem(
                  label: 'MOY. PANEL',
                  value: d != null
                      ? '${d.panelMoyen.toStringAsFixed(1)}j'
                      : '—',
                  valueColor: homeGreen,
                  sub: 'sur la période',
                ),
                Container(
                  width: 2,
                  height: 42,
                  color: Colors.black.withValues(alpha: 0.07),
                ),
                _summaryItem(
                  label: 'ÉVALS.',
                  value: '${d?.nbEvals ?? 0}',
                  valueColor: homeDark,
                  sub: 'comptées',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 100,
            child: d == null || d.points.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée',
                      style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 4,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => const FlLine(
                          color: Color(0x0D000000),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 24,
                            getTitlesWidget: (v, _) => v % 1 == 0
                                ? Text(
                                    '${v.toInt()}j',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      color: Color(0xFFCCCCCC),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i < 0 ||
                                  i >= d.points.length ||
                                  i % (d.points.length > 6 ? 2 : 1) != 0) {
                                return const SizedBox();
                              }
                              final dt = d.points[i].date;
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${dt.day} ${homeMoisAbr[dt.month - 1]}',
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFAAAAAA),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(
                            d.points.length,
                            (i) => FlSpot(i.toDouble(), d.points[i].monDelai),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: homeAmber,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (p, x, bar, i) => FlDotCirclePainter(
                              radius: 3,
                              color: homeAmber,
                              strokeColor: homeWhite,
                              strokeWidth: 1.5,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                homeAmber.withValues(alpha: 0.12),
                                homeAmber.withValues(alpha: 0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        LineChartBarData(
                          spots: List.generate(
                            d.points.length,
                            (i) => FlSpot(i.toDouble(), d.points[i].panelMoyen),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: const Color(0xFFB8DCC8),
                          barWidth: 1.5,
                          dashArray: [5, 4],
                          dotData: const FlDotData(show: false),
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (spots) => spots
                              .map(
                                (s) => LineTooltipItem(
                                  '${s.y.toStringAsFixed(1)}j',
                                  TextStyle(
                                    color: s.bar.color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 16, height: 2, color: homeAmber),
              const SizedBox(width: 5),
              const Text(
                'Mon délai',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: homeDark,
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                width: 16,
                height: 12,
                child: CustomPaint(painter: _DashPainter()),
              ),
              const SizedBox(width: 5),
              const Text(
                'Moy. panel',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: homeDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
    required Color valueColor,
    String? sub,
    Color? subColor,
  }) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Color(0xFFAAAAAA),
              letterSpacing: 0.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
              height: 1,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 3),
            Text(
              sub,
              style: TextStyle(
                fontSize: 9,
                color: subColor ?? const Color(0xFFAAAAAA),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    ),
  );
}

// ── Dashed line painter (délai legend) ──────────────────────────────────────
class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8DCC8)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 4).clamp(0.0, size.width), size.height / 2),
        paint,
      );
      x += 7;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
