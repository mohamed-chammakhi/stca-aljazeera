import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/dashboard_chef_degustateur.dart';
import 'home_shared.dart';

class ClassificationsSection extends StatelessWidget {
  final List<ClassificationPoint> classifications;
  final DateTime? dateDebut;
  final DateTime? dateFin;
  final VoidCallback onDateTap;

  const ClassificationsSection({
    super.key,
    required this.classifications,
    required this.dateDebut,
    required this.dateFin,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return fixedCard(
      height: 300,
      header: sectionBar(
        title: 'Classifications du panel',
        icon: Icons.bar_chart_outlined,
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
        children: [
          SizedBox(
            height: 180,
            child: classifications.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune donnée',
                      style: TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: classifications
                              .map(
                                (p) =>
                                    (p.extraVierge + p.vierge + p.lampante)
                                        .toDouble(),
                              )
                              .fold(0.0, (a, b) => a > b ? a : b) +
                          1,
                      barGroups: List.generate(classifications.length, (i) {
                        final p = classifications[i];
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: p.extraVierge.toDouble(),
                              color: chefGreenLocal,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: p.vierge.toDouble(),
                              color: chefOlive,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            BarChartRodData(
                              toY: p.lampante.toDouble(),
                              color: chefAmber,
                              width: 10,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }),
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              legendDot(chefGreenLocal, 'Extra Vierge'),
              const SizedBox(width: 12),
              legendDot(chefOlive, 'Vierge'),
              const SizedBox(width: 12),
              legendDot(chefAmber, 'Lampante'),
            ],
          ),
        ],
      ),
    );
  }
}
