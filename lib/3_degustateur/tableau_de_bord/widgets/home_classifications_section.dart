import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_degustateur.dart';
import 'home_shared.dart';

class HomeClassificationsSection extends StatelessWidget {
  const HomeClassificationsSection({
    super.key,
    required this.classifications,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
  });
  final List<ClassificationPoint> classifications;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onDateTap;

  @override
  Widget build(BuildContext context) {
    return homeFixedCard(
      height: 260,
      header: homeSectionBar(
        title: 'Mes classifications',
        icon: Icons.bar_chart_outlined,
        dateDebut: dateDebut,
        dateFin: dateFin,
        onDateTap: onDateTap,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 150,
            child: classifications.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée',
                      style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 22),
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY:
                                  classifications
                                      .map(
                                        (p) =>
                                            (p.extraVierge +
                                                    p.vierge +
                                                    p.lampante)
                                                .toDouble(),
                                      )
                                      .fold(0.0, (a, b) => a > b ? a : b) +
                                  1,
                              barGroups: List.generate(
                                classifications.length,
                                (i) {
                                  final p = classifications[i];
                                  return BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: p.extraVierge.toDouble(),
                                        color: homeGreen,
                                        width: 10,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                      BarChartRodData(
                                        toY: p.vierge.toDouble(),
                                        color: homeOlive,
                                        width: 10,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                      BarChartRodData(
                                        toY: p.lampante.toDouble(),
                                        color: homeAmber,
                                        width: 10,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(4),
                                            ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) {
                                      final i = v.toInt();
                                      if (i < 0 || i >= classifications.length) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          classifications[i].label,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFAAAAAA),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) => v % 1 == 0
                                        ? Text(
                                            v.toInt().toString(),
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Color(0xFFCCCCCC),
                                            ),
                                          )
                                        : const SizedBox(),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (_) => const FlLine(
                                  color: Color(0x0D000000),
                                  strokeWidth: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(homeGreen, 'Extra Vierge'),
              const SizedBox(width: 12),
              _legendDot(homeOlive, 'Vierge'),
              const SizedBox(width: 12),
              _legendDot(homeAmber, 'Lampante'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) => Row(
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
          color: homeDark,
        ),
      ),
    ],
  );
}
