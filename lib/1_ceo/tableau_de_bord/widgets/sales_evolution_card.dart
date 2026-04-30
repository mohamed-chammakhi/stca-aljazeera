import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_models.dart';
import 'dash_line_painter.dart';

const Color _green = Color(0xFF38835A);
const Color _dark = Color(0xFF1A2E1F);
const Color _white = Color(0xFFFFFFFF);

/// Line chart comparing current vs previous olive oil purchase season.
/// Data is hardcoded here until the Django API endpoint is wired.
class SalesEvolutionCard extends StatelessWidget {
  final CardDateRange dateRange;
  final Widget Function(CardDateRange, VoidCallback) dateChipBuilder;
  final void Function(CardDateRange) onRangeChanged;

  const SalesEvolutionCard({
    super.key,
    required this.dateRange,
    required this.dateChipBuilder,
    required this.onRangeChanged,
  });

  static const _salesMonths = ['Oct', 'Nov', 'Déc', 'Jan', 'Fév', 'Mar', 'Avr'];
  static const _salesCurrent = [18000.0, 32000.0, 55000.0, 68000.0, 72000.0, 54000.0, 38000.0];
  static const _salesPrev = [12000.0, 25000.0, 42000.0, 55000.0, 60000.0, 48000.0, 30000.0];

  @override
  Widget build(BuildContext context) {
    final maxVal = _salesCurrent.fold(0.0, (a, b) => a > b ? a : b) * 1.25;

    Widget legendLine({required Color color, bool dashed = false}) => SizedBox(
      width: 20, height: 12,
      child: CustomPaint(painter: DashLinePainter(color: color, dashed: dashed)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _sectionLabel('Évolution des achats', Icons.show_chart_outlined)),
              dateChipBuilder(dateRange, () {}),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              legendLine(color: _green),
              const SizedBox(width: 6),
              const Text('Saison 25/26', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _dark)),
              const SizedBox(width: 14),
              legendLine(color: Color(0xFFB8DCC8), dashed: true),
              const SizedBox(width: 6),
              Text('Saison 24/25', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxVal / 3,
                getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.shade100, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 22,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= _salesMonths.length) return const SizedBox();
                      return Text(
                        _salesMonths[i],
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.w600),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0, maxX: (_salesCurrent.length - 1).toDouble(),
              minY: 0, maxY: maxVal,
              lineBarsData: [
                LineChartBarData(
                  spots: List.generate(_salesCurrent.length, (i) => FlSpot(i.toDouble(), _salesCurrent[i])),
                  isCurved: true, curveSmoothness: 0.3, color: _green, barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (p, x, bar, i) => FlDotCirclePainter(
                      radius: 3.5, color: _green, strokeColor: Colors.white, strokeWidth: 1.5,
                    ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [_green.withValues(alpha: 0.18), _green.withValues(alpha: 0)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                LineChartBarData(
                  spots: List.generate(_salesPrev.length, (i) => FlSpot(i.toDouble(), _salesPrev[i])),
                  isCurved: true, curveSmoothness: 0.3,
                  color: const Color(0xFFB8DCC8), barWidth: 2,
                  dashArray: [5, 3],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            )),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05)))),
            child: Row(
              children: [
                Expanded(child: _kpiMini('8.4', 'TND/L · en cours', _green)),
                Container(width: 1, height: 32, color: Colors.grey.shade100),
                Expanded(child: _kpiMini('7.1', 'TND/L · saison préc.', const Color(0xFFB8DCC8))),
                Container(width: 1, height: 32, color: Colors.grey.shade100),
                Expanded(child: _kpiMini('432k L', 'Qté totale achetée', _dark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _kpiMini(String value, String label, Color color) => Column(
    children: [
      Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
    ],
  );
}

Widget _sectionLabel(String text, IconData icon) => Row(
  children: [
    Container(
      width: 3, height: 16,
      decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(2)),
    ),
    const SizedBox(width: 8),
    Icon(icon, size: 14, color: _green),
    const SizedBox(width: 6),
    Flexible(child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _dark))),
  ],
);

BoxDecoration _cardDeco() => BoxDecoration(
  color: _white,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
  boxShadow: [
    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
  ],
);
